import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dieklingel_base/crypto/sha2562.dart';
import 'package:dieklingel_base/messaging/messaging_client.dart';
import 'package:dieklingel_base/rtc/rtc_connection_state.dart';
import 'package:dieklingel_base/views/screensaver.dart';
import 'package:dieklingel_base/views/signs.dart';
import './numpad.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

import '../signaling/signaling_message.dart';
import '../signaling/signaling_message_type.dart';
import '../views/components/sign.dart';
import '../rtc/rtc_client.dart';
import '../signaling/signaling_client.dart';
import '../media/media_ressource.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _Home();
}

const String configPath = "resources/config/config.json";

class _Home extends State<Home> {
  late final MessagingClient _messagingClient;
  late final SignalingClient _signalingClient;
  final List<RtcClient> _rtcClients = [];
  String uid = "notReadyUid";
  dynamic _config;

  bool _displayIsOn = false;

  @override
  void initState() {
    init();
    super.initState();
  }

  void init() async {
    // init configuration
    String rawConfig = await rootBundle.loadString(configPath);
    setState(() {
      _config = jsonDecode(rawConfig);
    });

    _messagingClient = MessagingClient(
      _config["mqtt"]["address"] as String,
      _config["mqtt"]["port"] as int,
    );
    await _messagingClient.connect();
    uid = _config["uid"] ?? "none";
    _registerListerners();
    _messagingClient.send(
      "${uid}system/log",
      "system initialized with uid: $uid",
    );
    _messagingClient.send(
      "${uid}io/display/state",
      "on",
    );
    _messagingClient.addEventListener(
      "message:${uid}firebase/notification/token/add",
      (raw) async {
        Map<String, dynamic> message = jsonDecode(raw);
        if (null == message["hash"] || null == message["token"]) return;
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String hash = message["hash"];
        String token = message["token"];
        List<String>? tokens = prefs.getStringList("sign/$hash");
        tokens ??= List<String>.empty(growable: true);
        if (!tokens.contains(token)) tokens.add(token);
        prefs.setStringList("sign/$hash", tokens);
        _messagingClient.send(
          "${uid}system/log",
          "token for hash '$hash' set",
        );
      },
    );
    // init signaling client
    _signalingClient = SignalingClient.fromMessagingClient(
      _messagingClient,
      "${uid}rtc/signaling",
      uid,
    );

    _signalingClient.addEventListener("message", (message) {
      if (message is! SignalingMessage) return;
      switch (message.type) {
        case SignalingMessageType.candidate:
          break;
        case SignalingMessageType.offer:
          SignalingMessage m = SignalingMessage.fromJson(message.toJson());
          createRtcClient(m);
          break;
        default:
          break;
      }
    });
  }

  void _registerListerners() {
    _messagingClient.addEventListener(
      "message:${uid}io/display/state",
      (data) {
        setState(() {
          _displayIsOn = (data as String) == "on";
        });
      },
    );
  }

  void _onUnlock(String passcode) {
    String passcodeHash = sha2562.convert(utf8.encode(passcode)).toString();
    _messagingClient.send("${uid}io/action/unlock", passcodeHash);
  }

  void _onSignTap(String hash) async {
    _messagingClient.send(
      "${uid}system/log",
      "the sign was clicked",
    );
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? tokens = prefs.getStringList("sign/$hash");
    if (null == tokens) {
      print("no tokens");
      return;
    }
    String snapshot =
        _config["notification"]["snapshot"] == true ? await takePicture() : "";
    Map<String, dynamic> message = {
      "tokens": tokens,
      "title": "Jemand steht vor deiner Tuer ($uid)",
      "body": "https://dieklingel.com/",
      "image": snapshot,
    };
    _messagingClient.send(
      "${uid}firebase/notification/send",
      jsonEncode(message),
    );
    _messagingClient.send(
      "${uid}system/log",
      "notification send",
    );
  }

  void _onScreensaverTap() {
    _messagingClient.send("${uid}io/display/state", "on");
  }

  void createRtcClient(SignalingMessage offerMessage) async {
    Map<String, dynamic> iceServers = _config["webrtc"]["ice"];
    MediaRessource mediaRessource = MediaRessource();
    RtcClient client = RtcClient(_signalingClient, mediaRessource, iceServers);
    client.recipient = offerMessage.sender;

    _messagingClient.send(
      "${uid}system/log",
      "request to start rtc acknowledged for ${client.recipient}",
    );

    /*client.addEventListener("mediatrack-received", (track) {
      _renderer.srcObject = track;
    }); */
    client.addEventListener("state-changed", (state) {
      if (state is! RtcConnectionState) return;
      switch (state) {
        case RtcConnectionState.disconnected:
          _rtcClients.remove(client);
          break;
        default:
          break;
      }
      _messagingClient.send(
        "${uid}rtc/call/state",
        state.toString(),
      );
    });
    await mediaRessource.open(true, true);
    client.answer(offerMessage);
    _rtcClients.add(client);
  }

  Future<String> takePicture() async {
    final List<CameraDescription> cameras = await availableCameras();
    if (cameras.isEmpty) {
      return "";
    }
    final CameraDescription camera = cameras.first;
    final CameraController controller = CameraController(
      camera,
      ResolutionPreset.medium,
    );
    await controller.initialize();
    XFile image = await controller.takePicture();
    List<int> bytes = await image.readAsBytes();
    String base64 = base64Encode(bytes);
    await controller.dispose();
    return "data:image/png;base64,$base64";
  }

  Widget _awake(
    BuildContext context, {
    required double width,
    required double height,
    required List<Sign> signs,
  }) {
    return CarouselSlider(
      items: [
        Signs(
          signs: signs,
        ),
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment(0.8, 1),
              colors: <Color>[
                Color(0xff1f005c),
                Color(0xff5b0060),
                Color(0xff870160),
                Color(0xffac255e),
                Color(0xffca485c),
                Color(0xffe16b5c),
                Color(0xfff39060),
                Color(0xffffb56b),
              ], // Gradient from https://learnui.design/tools/gradient-generator.html
              tileMode: TileMode.mirror,
            ),
          ),
          child: Numpad(
            width: width,
            height: height,
            textStyle: const TextStyle(color: Colors.white),
            onUnlock: _onUnlock,
          ),
        ),
      ],
      options: CarouselOptions(
        height: height,
        viewportFraction: 1,
        enableInfiniteScroll: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (null == _config) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    final double clipLeft = _config["viewport"]["clip"]["left"] ?? 0;
    final double clipTop = _config["viewport"]["clip"]["top"] ?? 0;
    final double clipRight = _config["viewport"]["clip"]["right"] ?? 0;
    final double clipBottom = _config["viewport"]["clip"]["bottom"] ?? 0;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double width = screenWidth - clipLeft - clipRight;
    final double height = screenHeight - clipTop - clipBottom;

    List<Sign> signs = (_config["signs"] as List<dynamic>).map(
      (element) {
        return Sign(
          element["text"],
          element["hash"],
          height,
          onTap: _onSignTap,
        );
      },
    ).toList();

    return _displayIsOn
        ? _awake(
            context,
            width: width,
            height: height,
            signs: signs,
          )
        : Screensaver(
            text: _config["viewport"]?["screensaver"]?["text"] ?? "",
            width: width,
            height: height,
            onTap: _onScreensaverTap,
          );
  }
}
