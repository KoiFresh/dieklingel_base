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
    //WidgetsFlutterBinding.ensureInitialized();

    /*_signalingClient.identifier = "core";
    _signalingClient.connect("ws://dieklingel.com", 9001);
    _signalingClient.addEventListener(
      "message",
      (message) => {
        if (message is SignalingMessage) {onMessageReceived(message)}
      },
    );
    var ice = <String, dynamic>{
      "iceServers": [
        {"url": "stun:stun1.l.google.com:19302"},
        {
          'url': 'turn:dieklingel.com:3478',
          'credential': '12345',
          'username': 'guest'
        },
      ]
    };
    /*var ice = {
      "urls": ["stun:stun2.l.google.com:19302"]
    };*/
    _rtcClient = RtcClient(_signalingClient, _mediaResource, ice);
    _rtcClient?.addEventListener(RtcClient.mediaReceived,
        (track) => {/*renderer.srcObject = track*/ print("track received")});
    super.initState();
  */
    //client.addEventListener("message:test/", (data) => print(data));
    //
    //client.addEventListener("message", (data) => print(data));
  }

  void init() async {
    // init configuration
    String configPath = "assets/config/config.json";
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
      "com.dieklingel/$uid/system/log",
      "system initialized with uid: $uid",
    );
    _messagingClient.send(
      "com.dieklingel/$uid/io/display/state",
      "on",
    );
    _messagingClient.addEventListener(
      "message:com.dieklingel/$uid/firebase/notification/token/add",
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
          "com.dieklingel/$uid/system/log",
          "token for hash '$hash' set",
        );
      },
    );
    // init signaling client
    _signalingClient = SignalingClient.fromMessagingClient(
      _messagingClient,
      "com.dieklingel/$uid/rtc/signaling",
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
        "com.dieklingel/$uid/system/log",
        "request to start rtc acknowledged",
      );
      _rtcClient.answer(offer);
    });
    _rtcClient.addEventListener("mediatrack-received", (track) {
      _renderer.srcObject = track;
    });
    _rtcClient.addEventListener("state-changed", (state) {
      _messagingClient.send(
        "com.dieklingel/$uid/rtc/call/state",
        state.toString(),
      );
    });
    // init camera
    //
    //final CameraDescription camera = cameras.first;
    /*_controller = CameraController(
      camera,
      ResolutionPreset.medium,
    );*/
    //await _controller.initialize();
    //_controller.
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
        return Sign(
          _signs[index]["text"],
          _signs[index]["hash"],
          onTap: (String hash) async {
            _messagingClient.send(
              "com.dieklingel/$uid/system/log",
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
              "com.dieklingel/$uid/firebase/notification/send",
              jsonEncode(message),
            );
            _messagingClient.send(
              "com.dieklingel/$uid/system/log",
              "notification send",
            );
          },
        );
      },
    );
  }
}
