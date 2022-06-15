import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../views/components/sign.dart';
import '../rtc/rtc_client.dart';
import '../signaling/signaling_client.dart';
import '../media/media_ressource.dart';
import '../signaling/signaling_message.dart';
import '../signaling/signaling_message_type.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _Home();
}

class _Home extends State<Home> {
  final SignalingClient _signalingClient = SignalingClient();
  final MediaRessource _mediaResource = MediaRessource();
  final List<dynamic> _signs = List.empty(growable: true);
  RtcClient? _rtcClient;
  RTCVideoRenderer renderer = RTCVideoRenderer();

  @override
  void initState() {
    renderer.initialize();
    _signalingClient.identifier = "core";
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

    rootBundle.loadString("assets/config/config.json").then((value) {
      final dynamic config = jsonDecode(value);
      setState(() {
        _signs.addAll(config["signs"]);
      });
    });
  }

  void onMessageReceived(SignalingMessage message) async {
    print("message");
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
      }),
    );
  }
}
