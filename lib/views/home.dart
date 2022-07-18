import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:dieklingel_base/messaging/messaging_client.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

import '../views/components/sign.dart';
import '../rtc/rtc_client.dart';
import '../signaling/signaling_client.dart';
import '../media/media_ressource.dart';
import '../messaging/messaging_client.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _Home();
}

class _Home extends State<Home> {
  late final MessagingClient _messagingClient;
  late final SignalingClient _signalingClient;
  late final RtcClient _rtcClient;
  late final String uid;
  late final dynamic config;
  final MediaRessource _mediaResource = MediaRessource();
  final List<dynamic> _signs = List.empty(growable: true);

  final RTCVideoRenderer _renderer = RTCVideoRenderer();

  @override
  void initState() {
    _renderer.initialize();
    init();
    super.initState();
  }

  void init() async {
    // init configuration
    String configPath = "resources/config/config.json";
    String rawConfig = await rootBundle.loadString(configPath);
    config = jsonDecode(rawConfig);
    setState(() {
      _signs.addAll(config["signs"]);
    });
    // init messaging client
    _messagingClient = MessagingClient(
      config["mqtt"]["address"] as String,
      config["mqtt"]["port"] as int,
    );
    await _messagingClient.connect();
    uid = config["uid"] ?? "none";
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
    // init rtc client
    _rtcClient = RtcClient(
      _signalingClient,
      _mediaResource,
      config["webrtc"]["ice"],
    );
    _rtcClient.addEventListener("offer-received", (offer) async {
      await _mediaResource.open(true, true);
      _messagingClient.send(
        "${uid}system/log",
        "request to start rtc acknowledged",
      );
      _rtcClient.answer(offer);
    });
    _rtcClient.addEventListener("mediatrack-received", (track) {
      _renderer.srcObject = track;
    });
    _rtcClient.addEventListener("state-changed", (state) {
      _messagingClient.send(
        "${uid}rtc/call/state",
        state.toString(),
      );
    });
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

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _signs.length,
      itemBuilder: (context, index) {
        final double screenHeight = MediaQuery.of(context).size.height;
        final double clipTop = config["viewport"]["clip"]["top"];
        final double clipBottom = config["viewport"]["clip"]["bottom"];
        final double signHeigh = screenHeight - clipTop - clipBottom;
        return Sign(
          _signs[index]["text"],
          _signs[index]["hash"],
          signHeigh,
          onTap: (String hash) async {
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
            String snapshot = config["notification"]["snapshot"] == true
                ? await takePicture()
                : "";
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
          },
        );
      },
    );
  }
}
