import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttClientFactory {
  static MqttClient create(
    String server,
    String clientIdentifier, {
    int maxConnectionAttempts = 3,
  }) {
    MqttClient client = MqttServerClient(
      server,
      clientIdentifier,
      maxConnectionAttempts: maxConnectionAttempts,
    );
    return client;
  }
}
