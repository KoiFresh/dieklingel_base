import 'dart:convert';
import 'package:mqtt_client/mqtt_browser_client.dart';
import 'package:mqtt_client/mqtt_client.dart';

import '../event/event_emitter.dart';
import 'signaling_client.dart';
import 'signaling_message.dart';

class SignalingClientMqtt extends EventEmitter implements SignalingClient {
  MqttClient? client;
  @override
  String identifier = "";
  final String _topic;

  SignalingClientMqtt({String topic = "com.dieklingel.app/default"})
      : _topic = topic;

  Future<MqttClient> createSocket(String url, int port) async {
    MqttBrowserClient client = MqttBrowserClient(
        "ws://dieklingel.com", "com.dieklingel.base.instance");

    client.port = 9001;
    client.keepAlivePeriod = 20;
    client.setProtocolV311();
    //cant connect without next line
    client.websocketProtocols = MqttClientConstants.protocolsSingleDefault;

    await client.connect();
    print("connected");
    client.subscribe("com.dieklingel.app/default", MqttQos.exactlyOnce);

    client.updates?.listen((List<MqttReceivedMessage<MqttMessage>>? c) {
      MqttPublishMessage rec = c![0].payload as MqttPublishMessage;
      //String topic = c[0].topic;
      String raw =
          MqttPublishPayload.bytesToStringAsString(rec.payload.message);
      SignalingMessage message = SignalingMessage.fromJson(jsonDecode(raw));
      if (message.to == "") {
        emit("broadcast", message);
      } else if (message.to == identifier) {
        emit("message", message);
      }
    });

    return client;
  }

  @override
  void connect(String url, int port) async {
    client?.disconnect();
    client = await createSocket(url, port);
  }

  @override
  void send(SignalingMessage message) {
    String raw = jsonEncode(message.toJson());
    MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(raw);
    client?.publishMessage(_topic, MqttQos.exactlyOnce, builder.payload!);
  }
}