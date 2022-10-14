import 'dart:convert';

import 'package:dieklingel_base/components/app_settings.dart';
import 'package:mqtt_client/mqtt_client.dart';

import 'event/event_monitor.dart';
import 'extensions/get_mclient.dart';
import 'messaging/mclient.dart';
import 'messaging/mclient_topic_message.dart';

void registerListeners({
  required MClient mClient,
  required EventMonitor eventMonitor,
  required AppSettings appSettings,
}) {
  /// listen for request to all system events
  mClient.listen(
    "request/events",
    (message) => jsonEncode(eventMonitor.events),
  );

  /// listen for system events to publish
  eventMonitor.addListener(() {
    if (mClient.connectionState != MqttConnectionState.connected) return;
    MClientTopicMessage message = MClientTopicMessage(
      topic: "system/event",
      message: jsonEncode(eventMonitor.events.last),
    );
    mClient.publish(message);
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
