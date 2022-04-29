import 'package:dieklingel_base/rtc/rtc_client.dart';
import 'package:dieklingel_base/signaling/signaling_client.dart';
import 'package:dieklingel_base/signaling/signaling_client_mqtt.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

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
  MediaRessource _mediaResource = MediaRessource();
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
          'url': 'turn:192.158.29.39:3478?transport=tcp',
          'credential': 'JZEOEt2V3Qb0y27GRntt2u2PAYA=',
          'username': '28224511:1379330808'
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
    return Stack(
      children: [
        CupertinoButton(
          child: const Text("Hallo welt1"),
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
        ),
        RTCVideoView(renderer),
      ],
    );
  }
}
