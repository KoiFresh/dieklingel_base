import 'package:mqtt_client/mqtt_client.dart';
import 'mqtt_server_client_factory.dart'
    if (dart.library.js) 'mqtt_browser_client_factory.dart';
import '../event/event_emitter.dart';

class MessagingClient extends EventEmitter {
  String hostname;
  int port;
  MqttClient? _client;

  MessagingClient(this.hostname, this.port);

  @override
  void addEventListener(String event, Function(dynamic data) callback) {
    if (null == _client) {
      throw Exception(
        "the mqtt client has to be connected to a broker, befor listening for messages",
      );
    }
    if (event.startsWith("message:")) {
      String topic = event.replaceFirst("message:", "");
      _client!.subscribe(topic, MqttQos.exactlyOnce);
    }
    super.addEventListener(event, callback);
  }

  void send(String topic, String message) {
    if (null == _client) {
      throw Exception(
        "the client has to be connected, before a message could be send",
      );
    }
    MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(message);
    _client!.publishMessage(topic, MqttQos.exactlyOnce, builder.payload!);
  }

  Future<void> connect({String? username, String? password}) async {
    if (null != _client) {
      throw Exception(
        "the client has to be disconnected, before in can be connected",
      );
    }
    MqttClient client = MqttClientFactory.create(hostname, "");
    client.port = port;
    client.keepAlivePeriod = 20;
    client.setProtocolV311();
    client.onConnected = () {};
    client.onDisconnected = () {};

    await client.connect(username, password);
    client.updates?.listen((List<MqttReceivedMessage<MqttMessage>>? c) {
      MqttPublishMessage rec = c![0].payload as MqttPublishMessage;
      String topic = c[0].topic;
      String raw =
          MqttPublishPayload.bytesToStringAsString(rec.payload.message);
      emit("message", raw);
      emit("message:$topic", raw);
    });

    _client = client;
  }

  void disconnect() {
    _client?.disconnect();
    _client = null;
  }

  bool isConnected() {
    return _client?.connectionStatus?.state == MqttConnectionState.connected;
  }
}
