import 'dart:convert';
import 'package:mqtt_client/mqtt_browser_client.dart';
import 'package:mqtt_client/mqtt_client.dart';

import '../event/event_emitter.dart';
import 'signaling_message.dart';

class SignalingClient extends EventEmitter {
  MqttClient? client;
  @override
  String identifier = "";
  final String _topic;
  final String _mqttIdentifiert;

  SignalingClient(
      {String topic = "com.dieklingel.app/default",
      String mqttIdentifier = "com.dieklingel.base.instance"})
      : _topic = topic,
        _mqttIdentifiert = mqttIdentifier;

  Future<MqttClient> createSocket(String url, int port) async {
    MqttBrowserClient client = MqttBrowserClient(url, _mqttIdentifiert);

    client.port = port;
    client.keepAlivePeriod = 20;
    client.setProtocolV311();
    //cant connect without next line
    client.websocketProtocols = MqttClientConstants.protocolsSingleDefault;

    client.onConnected = () {
      print("connected");
    };

    client.onDisconnected = () {
      print("disconnected");
      /*Future.delayed(const Duration(seconds: 5), () {
        print("reconnect");
        client.connect();
      });*/
    };
    try {
      await client.connect();
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
    } catch (e) {
      print("error connecting");
    }

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

  @override
  void disconnect() {
    throw UnimplementedError("disconnect is not implemented yet");
  }
}
