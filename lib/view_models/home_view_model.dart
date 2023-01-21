import 'dart:convert';

import 'package:dieklingel_base/media/media_ressource.dart';
import 'package:dieklingel_base/messaging/mclient.dart';
import 'package:dieklingel_base/rtc/mqtt_rtc_client.dart';
import 'package:dieklingel_base/rtc/rtc_connection_state.dart';
import 'package:flutter/cupertino.dart';

import '../models/ice_server.dart';
import '../models/mqtt_uri.dart';

class HomeViewModel extends ChangeNotifier {
  final Map<String, dynamic> config;
  MClient client = MClient();

  HomeViewModel({this.config = const {}}) {
    init();
  }

  MqttRtcClient? artcClient;

  void init() async {
    client.listen("request/rtc/", (message) async {
      print("rtc requested");

      MqttUri uri = MqttUri.fromMap(
        jsonDecode(message),
      ).copyWith(
        host: "server.dieklingel.com",
        port: 1883,
        ssl: false,
        websocket: false,
      );

      IceServer.boxx.clear();
      await IceServer(urls: "stun:stun1.l.google.com:19302").save();
      await IceServer(urls: "stun:openrelay.metered.ca:80").save();
      await IceServer(
        urls: "turn:openrelay.metered.ca:80",
        username: "openrelayproject",
        credential: "openrelayproject",
      ).save();
      await IceServer(
        urls: "turn:openrelay.metered.ca:443",
        username: "openrelayproject",
        credential: "openrelayproject",
      ).save();
      await IceServer(
        urls: "turn:openrelay.metered.ca:443?transport=tcp",
        username: "openrelayproject",
        credential: "openrelayproject",
      ).save();

      MqttRtcClient rtcClient = MqttRtcClient.answer(uri, MediaRessource());
      await rtcClient.mediaRessource.open(true, true);
      await rtcClient.init(
        iceServers: IceServer.boxx.values.toList(),
      );

      Future.delayed(const Duration(seconds: 30), () {
        if (rtcClient.rtcConnectionState != RtcConnectionState.connected &&
            rtcClient.rtcConnectionState != RtcConnectionState.disconnected) {
          rtcClient.close();
          print("close rtc request after 30 sec no connection");
        }
      });

      return "Ok";
    });
  }
}
