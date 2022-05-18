import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../views/components/sign.dart';
import '../rtc/rtc_client.dart';
import '../signaling/signaling_client.dart';
import '../signaling/signaling_client_mqtt_web.dart';
import '../media/media_ressource.dart';
import '../signaling/signaling_message.dart';
import '../signaling/signaling_message_type.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _Home();
}

class _Home extends State<Home> {
  final SignalingClient _signalingClient = SignalingClientMqtt();
  final MediaRessource _mediaResource = MediaRessource();
  final List<dynamic> _signs = List.empty(growable: true);
  RtcClient? _rtcClient;
  RTCVideoRenderer renderer = RTCVideoRenderer();

  @override
  void initState() {
    renderer.initialize();
    _signalingClient.identifier = "flutterbase";
    _signalingClient.connect("ws://85.214.41.43", 9001);
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
    _rtcClient?.addEventListener(
        RtcClient.mediaReceived, (track) => {renderer.srcObject = track});
    super.initState();

    rootBundle.loadString("config/config.json").then((value) {
      final dynamic config = jsonDecode(value);
      setState(() {
        _signs.addAll(config["signs"]);
      });
    });
  }

  void onMessageReceived(SignalingMessage message) async {
    switch (message.type) {
      case SignalingMessageType.offer:
        await _mediaResource.open(true, true);
        print("answer");
        _rtcClient?.answer(message);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: _signs.length,
        itemBuilder: ((context, index) {
          return Sign(_signs[index]["text"]);
        }));
    /*ListView(
      children: const [
        /*CupertinoButton(
          child: const Text("Hallo welt2"),
          onPressed: () async {
            print("Hallo");
            /*await mediaResource.open(true, true);
            renderer.srcObject = mediaResource.stream; */
            SignalingMessage message = SignalingMessage();
            message.from = "Base";
            message.to = "";
            message.type = SignalingMessageType.error;
            _signalingClient.send(message);
          },
        )*/
        Sign("Kai\nKai", height: 50),
        Sign("Kai"),
      ],
    ); */
  }
}
