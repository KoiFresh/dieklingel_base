import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_browser_client.dart';
import 'package:mqtt_client/mqtt_client.dart';

class MqttClientFactory {
  static MqttClient create(
    String server,
    String clientIdentifier, {
    int maxConnectionAttempts = 3,
  }) {
    MqttClient client = MqttBrowserClient(
      server,
      clientIdentifier,
      maxConnectionAttempts: maxConnectionAttempts,
    );
    if (kIsWeb) {
      //cant connect without next line
      client.websocketProtocols = MqttClientConstants.protocolsSingleDefault;
    }
    return client;
  }
}
