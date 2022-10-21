import 'dart:convert';

import 'package:dieklingel_base/components/app_settings.dart';
import 'package:dieklingel_base/media/media_ressource.dart';
import 'package:dieklingel_base/rtc/mqtt_rtc_client.dart';
import 'package:dieklingel_base/rtc/mqtt_rtc_description.dart';
import 'package:dieklingel_base/rtc/rtc_connection_state.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:objectdb/objectdb.dart';

import 'event/event_monitor.dart';
import 'extensions/get_mclient.dart';
import 'messaging/mclient.dart';
import 'messaging/mclient_topic_message.dart';

typedef JSON = Map<dynamic, dynamic>;

void registerListeners({
  required MClient mClient,
  required EventMonitor eventMonitor,
  required AppSettings appSettings,
  required ObjectDB databse,
}) {
  Future(() async {});

  // listen for request to all system events
  mClient.listen(
    "request/events/",
    (message) async => jsonEncode(eventMonitor.events),
  );

  mClient.listen(
    "request/ping/",
    (message) async => "pong",
  );

  mClient.listen(
    "request/register/",
    (message) async {
      JSON json = jsonDecode(message);
      if (json["hash"] == null || json["hash"] == "") {
        return "ERROR";
      }
      int updated = await databse.update(
        {
          "hash": json["hash"],
          "payload": json["payload"],
        },
        {
          "timestamp": DateTime.now().toUtc().toIso8601String(),
        },
      );
      if (updated < 1) {
        await databse.insert(
          {
            "hash": json["hash"],
            "payload": json["hash"],
            "timestamp": DateTime.now().toUtc().toIso8601String(),
          },
        );
      }
      return "OK";
    },
  );

  /// listen for system events to publish
  eventMonitor.addListener(() {
    if (mClient.connectionState != MqttConnectionState.connected) return;
    MClientTopicMessage message = MClientTopicMessage(
      topic: "system/event/",
      message: jsonEncode(eventMonitor.events.last),
    );
    mClient.publish(message);
  });

  List<MqttRtcClient> clients = [];

  print("listen");
  mClient.listen("request/rtc/test/", (message) async {
    print("request to open rtc");
    MqttRtcDescription rec = MqttRtcDescription.fromJson(
      jsonDecode(message),
    ).copyWith(
      host: "server.dieklingel.com",
      port: 9002,
      ssl: true,
      websocket: true,
    );

    MqttRtcClient m = MqttRtcClient.answer(
      MqttRtcDescription.parse(
          Uri.parse("ws://server.dieklingel.com:9001/${rec.channel}")),
      MediaRessource(),
    );
    await m.mediaRessource.open(true, true);
    await m.init(
      iceServers: {
        "iceServers": [
          {"url": "stun:stun1.l.google.com:19302"},
          {
            "urls": "turn:dieklingel.com:3478",
            "username": "guest",
            "credential": "12345"
          },
          {"urls": "stun:openrelay.metered.ca:80"},
          {
            "urls": "turn:openrelay.metered.ca:80",
            "username": "openrelayproject",
            "credential": "openrelayproject"
          },
          {
            "urls": "turn:openrelay.metered.ca:443",
            "username": "openrelayproject",
            "credential": "openrelayproject"
          },
          {
            "urls": "turn:openrelay.metered.ca:443?transport=tcp",
            "username": "openrelayproject",
            "credential": "openrelayproject"
          }
        ],
        "sdpSemantics": "unified-plan" // important to work
      },
    );
    Future.delayed(const Duration(minutes: 2), () {
      if (m.rtcConnectionState != RtcConnectionState.connected) {
        m.close();
      }
    });
    clients.add(m);
    return "OK";
  });

  /// listen for change of the display state
  mClient.subscribe("io/display/state", (message) {
    appSettings.displayIsActive.value = message.message == "on";
  });

  /// listen for changes of display state
  appSettings.displayIsActive.addListener(() {
    if (mClient.connectionState != MqttConnectionState.connected) {
      return;
    }
    MClientTopicMessage message = MClientTopicMessage(
      topic: "io/display/state",
      message: appSettings.displayIsActive.value ? "on" : "off",
    );
    mClient.publish(message);
  });

  /// listen for new notification token
  mClient.subscribe(
    "firebase/notification/token/add",
    (event) {
      Map<String, dynamic> message = jsonDecode(event.message);
      if (null == message["hash"] || null == message["token"]) return;
      String hash = message["hash"];
      String token = message["token"];
      List<String> hashs = appSettings.signHashs[hash] ?? [];
      if (!hashs.contains(token)) {
        hashs.add(token);
        appSettings.signHashs[hash] = hashs;
      }
    },
  );
}
