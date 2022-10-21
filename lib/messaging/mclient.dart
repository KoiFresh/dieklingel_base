import 'dart:convert';
import 'dart:io';

import '../rtc/mqtt_rtc_description.dart';

import 'mclient_subscribtion.dart';
import 'mclient_topic_message.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'mqtt_server_client_factory.dart'
    if (dart.library.js) 'mqtt_browser_client_factory.dart';

class MClient extends ChangeNotifier {
  final List<MClientSubscribtion> _subscribtions = [];
  MqttRtcDescription? mqttRtcDescription;
  MqttClient? _mqttClient;

  MClient({this.mqttRtcDescription});

  String get _prefix {
    MqttRtcDescription? description = mqttRtcDescription;
    if (null == description) {
      return "";
    }
    return description.channel;
  }

  MqttConnectionState get connectionState {
    return _mqttClient?.connectionStatus?.state ??
        MqttConnectionState.disconnected;
  }

  bool isConnected() {
    return connectionState == MqttConnectionState.connected;
  }

  bool isNotConnected() {
    return !isConnected();
  }

  Future<MqttClientConnectionStatus?> connect({
    String? username,
    String? password,
  }) async {
    MqttRtcDescription? description = mqttRtcDescription;
    if (description == null) {
      throw "cannot connect mclient without mqtt-rtc-descitpion";
    }
    _mqttClient?.disconnect();

    String scheme = "";
    if (description.websocket) {
      scheme = description.ssl ? "wss://" : "ws://";
    }
    _mqttClient = MqttClientFactory.create("$scheme${description.host}", "");
    _mqttClient!.port = description.port;
    _mqttClient!.keepAlivePeriod = 20;
    _mqttClient!.setProtocolV311();
    _mqttClient!.autoReconnect = true;
    _mqttClient!.onConnected = () {
      print("connected");
      notifyListeners();
    };
    _mqttClient!.onDisconnected = () {
      print("disconnected");
      notifyListeners();
    };
    _mqttClient!.onAutoReconnect = () {
      print("reconnect");
      notifyListeners();
    };

    //await _mqttClient!.connect(username, password);

    try {
      await _mqttClient!.connect(username, password);
    } on SocketException {
      rethrow;
    }

    for (MClientSubscribtion sub in _subscribtions) {
      String prefix = description.channel;
      _mqttClient!.subscribe("$prefix${sub.topic}", MqttQos.exactlyOnce);
    }
    _mqttClient!.updates!.listen((List<MqttReceivedMessage<MqttMessage>>? c) {
      MqttPublishMessage rec = c![0].payload as MqttPublishMessage;
      String topic = c[0].topic;
      if (topic.startsWith(_prefix)) {
        topic = topic.replaceFirst(_prefix, "");
      }
      List<int> messageAsBytes = rec.payload.message;
      String raw = utf8.decode(messageAsBytes);
      MClientTopicMessage message = MClientTopicMessage(
        topic: topic,
        message: raw,
      );
      for (MClientSubscribtion sub in _subscribtions) {
        if (sub.regExp.hasMatch(topic)) {
          sub.listener(message);
        }
      }
    });

    return _mqttClient!.connectionStatus;
  }

  void publish(MClientTopicMessage message) {
    if (connectionState != MqttConnectionState.connected) {
      throw "the mqtt client has to be connected, before publish";
    }
    MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addUTF8String(message.message);
    _mqttClient!.publishMessage(
      "$_prefix${message.topic}",
      MqttQos.exactlyOnce,
      builder.payload!,
    );
  }

  MClientSubscribtion subscribe(
    String topic,
    void Function(MClientTopicMessage message) listener,
  ) {
    RegExp regExp =
        RegExp(topic..replaceAll("\\+", "[^/]+").replaceAll("#", ".+"));
    MClientSubscribtion subscribtion =
        MClientSubscribtion(topic, listener: listener, regExp: regExp);
    _subscribtions.add(subscribtion);
    if (isNotConnected()) return subscribtion;
    _mqttClient?.subscribe("$_prefix$topic", MqttQos.exactlyOnce);
    return subscribtion;
  }

  void unsubscribe(MClientSubscribtion subscribtion) {
    _subscribtions.remove(subscribtion);
    for (int i = 0; i < _subscribtions.length; i++) {
      if (_subscribtions[i].topic == subscribtion.topic) {
        return;
      }
    }
    _mqttClient?.unsubscribe(subscribtion.topic);
  }

  void disconnect() {
    _mqttClient?.disconnect();
    _mqttClient = null;
  }
}
