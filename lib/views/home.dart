import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:dieklingel_base/messaging/messaging_client.dart';
import 'package:dieklingel_base/rtc/rtc_connection_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
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

class _Home extends State<Home> {
  late final MessagingClient _messagingClient;
  late final SignalingClient _signalingClient;
  late final String uid;
  late final dynamic config;
  final List<dynamic> _signs = [];
  final List<RtcClient> _rtcClients = [];

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

  void createRtcClient(SignalingMessage offerMessage) async {
    Map<String, dynamic> iceServers = config["webrtc"]["ice"];
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
