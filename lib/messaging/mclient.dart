import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:uuid/uuid.dart';

import 'mclient_state.dart';
import 'mclient_subscribtion.dart';

import 'mqtt_server_client_factory.dart'
    if (dart.library.js) 'mqtt_browser_client_factory.dart';
import '../models/mqtt_uri.dart';

class MClient extends ChangeNotifier {
  final List<MClientSubscribtion> _subscribtions = [];
  MqttUri? _uri;
  MClientState _state = MClientState.disconnected;
  MqttClient? _client;

  String get _prefix => uri?.channel ?? "";

  MqttUri? get uri => _uri;

  MClientState get state => _state;

  Future<MClientState> connect(
    MqttUri uri, {
    String? username,
    String? password,
  }) async {
    _uri = uri;
    _client?.disconnect();
    String scheme = "";
    if (uri.websocket) {
      scheme = uri.ssl ? "wss://" : "ws://";
    }
    _client = MqttClientFactory.create("$scheme${uri.host}", "")
      ..port = uri.port
      ..keepAlivePeriod = 20
      ..setProtocolV311()
      ..autoReconnect = true
      ..onConnected = () {
        _state = MClientState.connected;
        notifyListeners();
      }
      ..onDisconnected = () {
        _state = MClientState.disconnected;
        notifyListeners();
      }
      ..onAutoReconnect = () {};

    _state = MClientState.connecting;
    notifyListeners();

    MqttClientConnectionStatus? status;
    try {
      status = await _client?.connect(username, password);
    } on SocketException {
      rethrow;
    } finally {
      _state = status?.state == MqttConnectionState.connected
          ? MClientState.connected
          : MClientState.disconnected;
      notifyListeners();
    }

    for (MClientSubscribtion sub in _subscribtions) {
      String prefix = uri.channel;
      _client!.subscribe("$prefix${sub.topic}", MqttQos.exactlyOnce);
    }

    _client!.updates!.listen((List<MqttReceivedMessage<MqttMessage>>? c) {
      MqttPublishMessage rec = c![0].payload as MqttPublishMessage;
      String topic = c[0].topic;
      if (topic.startsWith(_prefix)) {
        topic = topic.replaceFirst(_prefix, "");
      }
      List<int> messageAsBytes = rec.payload.message;
      String message = utf8.decode(messageAsBytes);
      for (MClientSubscribtion sub in _subscribtions) {
        if (sub.regExp.hasMatch(topic)) {
          sub.listener(topic, message);
        }
      }
    });

    return _state;
  }

  void publish(String topic, String message) {
    if (state != MClientState.connected) {
      throw "the mclient has to be connected, before publish";
    }
    MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addUTF8String(message);
    _client!.publishMessage(
      "$_prefix$topic",
      MqttQos.exactlyOnce,
      builder.payload!,
    );
  }

  MClientSubscribtion subscribe(
    String topic,
    void Function(String topic, String message) listener,
  ) {
    RegExp regExp = RegExp(
      topic..replaceAll("\\+", "[^/]+").replaceAll("#", ".+"),
    );
    MClientSubscribtion subscribtion = MClientSubscribtion(
      topic,
      listener: listener,
      regExp: regExp,
    );
    _subscribtions.add(subscribtion);
    if (state != MClientState.connected) {
      return subscribtion;
    }
    _client?.subscribe("$_prefix$topic", MqttQos.exactlyOnce);
    return subscribtion;
  }

  void unsubscribe(MClientSubscribtion subscribtion) {
    _subscribtions.remove(subscribtion);
    for (int i = 0; i < _subscribtions.length; i++) {
      if (_subscribtions[i].topic == subscribtion.topic) {
        return;
      }
    }
    _client?.unsubscribe(subscribtion.topic);
  }

  Future<String?> get(
    String topic,
    String request, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    Completer<String?> completer = Completer<String?>();
    String identifier = const Uuid().v4();
    MClientSubscribtion sub = subscribe(
      "$topic$identifier/response",
      (topic, message) {
        completer.complete(message);
      },
    );
    publish("$topic$identifier", request);
    String? result = await completer.future.timeout(
      timeout,
      onTimeout: () => null,
    );
    unsubscribe(sub);
    return result;
  }

  void listen(String topic, Future<String> Function(String message) executer) {
    subscribe("$topic+", (topic, message) async {
      String returnVal = await executer(message);
      publish("${topic}response", returnVal);
    });
  }

  Future<void> disconnect() async {
    _client?.disconnect();
    _client = null;
  }
}
