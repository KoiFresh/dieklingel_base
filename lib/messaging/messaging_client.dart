import 'package:dieklingel_base/event/event_emitter.dart';
import 'package:mqtt_client/mqtt_browser_client.dart';
import 'package:mqtt_client/mqtt_client.dart';

class MessagingClient extends EventEmitter {
  final String hostname;
  final int port;
  MqttBrowserClient? _client;

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

  Future<void> connect() async {
    if (null != _client) {
      throw Exception(
        "the client has to be disconnected, before in can be connected",
      );
    }
    MqttBrowserClient client = MqttBrowserClient("ws://$hostname", "");
    client.port = port;
    client.keepAlivePeriod = 20;
    client.setProtocolV311();
    client.websocketProtocols = MqttClientConstants.protocolsSingleDefault;
    client.onConnected = () {};
    client.onDisconnected = () {};
    try {
      await client.connect();
      client.subscribe("test/", MqttQos.atLeastOnce);
      client.updates?.listen((List<MqttReceivedMessage<MqttMessage>>? c) {
        MqttPublishMessage rec = c![0].payload as MqttPublishMessage;
        String topic = c[0].topic;
        String raw =
            MqttPublishPayload.bytesToStringAsString(rec.payload.message);
        emit("message", raw);
        emit("message:$topic", raw);
      });
    } catch (exception) {
      print("could not connect tho the broker $hostname:$port; $exception");
    }
    _client = client;
  }

  void disconnect() {
    _client?.disconnect();
    _client = null;
  }
}
