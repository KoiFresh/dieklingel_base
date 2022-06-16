import 'dart:convert';

import 'package:dieklingel_base/messaging/messaging_client.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../views/components/sign.dart';
import '../rtc/rtc_client.dart';
import '../signaling/signaling_client.dart';
import '../media/media_ressource.dart';
import '../signaling/signaling_message.dart';
import '../signaling/signaling_message_type.dart';
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
  final MediaRessource _mediaResource = MediaRessource();
  final List<dynamic> _signs = List.empty(growable: true);

  final RTCVideoRenderer _renderer = RTCVideoRenderer();

  @override
  void initState() {
    _renderer.initialize();
    init();
    super.initState();

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
    dynamic config = jsonDecode(rawConfig);
    setState(() {
      _signs.addAll(config["signs"]);
    });
    // init messaging client
    _messagingClient = MessagingClient("127.0.0.1", 9001);
    await _messagingClient.connect();
    String uid = config["uid"] ?? "none";
    _messagingClient.send(
      "com.dieklingel/$uid/system/log",
      "system initialized with uid: $uid",
    );
    _messagingClient.send(
      "com.dieklingel/$uid/io/display/state",
      "on",
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
      config["webrtc"]["ico"],
    );
    _rtcClient.addEventListener("offer-received", (offer) async {
      await _mediaResource.open(true, true);
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
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _signs.length,
      itemBuilder: (context, index) {
        return Sign(
          _signs[index]["text"],
        );
      },
    );
  }
}
