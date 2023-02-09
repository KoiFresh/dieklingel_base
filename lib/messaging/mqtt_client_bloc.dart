import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

import '../bloc/bloc.dart';
import 'mclient_state.dart';

import 'mqtt_server_client_factory.dart'
    if (dart.library.js) 'mqtt_browser_client_factory.dart';
import '../models/mqtt_uri.dart';

typedef Filter = String? Function(String);

class MqttClientBloc extends Bloc {
  final Map<String, BehaviorSubject<String>> _subscribtions = {};
  final Map<String, String? Function(String)> _filters = {};

  final _uri = BehaviorSubject<MqttUri?>();
  final _username = BehaviorSubject<String>.seeded("");
  final _password = BehaviorSubject<String>.seeded("");
  final _state = BehaviorSubject<MClientState>();
  final _message = StreamController<MapEntry<String, String>>.broadcast();

  Sink<MqttUri?> get uri => _uri.sink;
  Stream<MClientState> get state => _state.stream;
  Sink<MapEntry<String, String>> get message => _message.sink;

  MqttClient? _client;

  MqttClientBloc() {
    _uri.stream.listen((event) {
      _connect();
    });

    _username.stream.listen((event) {
      _connect();
    });

    _password.stream.listen((event) {
      _connect();
    });

    _message.stream.listen((event) {
      _publish(event.key, event.value);
    });
  }

  Future<void> _connect() async {
    _client?.disconnect();

    MqttUri uri;
    if (!_uri.hasValue || _uri.value == null) {
      return;
    }
    uri = _uri.value!;

    String scheme = uri.websocket
        ? uri.ssl
            ? "wss://"
            : "ws://"
        : "";

    _client = MqttClientFactory.create("$scheme${uri.host}", const Uuid().v4())
      ..port = uri.port
      ..keepAlivePeriod = 20
      ..setProtocolV311()
      ..autoReconnect = true
      ..onConnected = () {
        _state.add(MClientState.connected);
      }
      ..onDisconnected = () {
        _state.add(MClientState.disconnected);
      };

    try {
      await _client?.connect(_username.value, _password.value);
    } on SocketException {
      rethrow;
    }

    _client?.updates!.listen((event) {
      MqttPublishMessage rec = event[0].payload as MqttPublishMessage;
      String topic = event[0].topic;
      List<int> messageAsBytes = rec.payload.message;
      String message = utf8.decode(messageAsBytes);

      for (MapEntry<String, Filter> entry in _filters.entries) {
        List<String> channels =
            "${_uri.value!.channel}/${entry.key}".split("/");
        channels.removeWhere((element) => element.isEmpty);
        String channel = channels.join("/");

        RegExp regExp = RegExp(
          channel.replaceAll("\\+", "[^/]+").replaceAll("#", ".+"),
        );

        if (!regExp.hasMatch(topic)) {
          continue;
        }

        String? modified = entry.value(message);
        if (modified == null) {
          return;
        }
        message = modified;
      }

      _subscribtions.forEach((key, value) {
        List<String> channels = "${_uri.value!.channel}/$key".split("/");
        channels.removeWhere((element) => element.isEmpty);
        String channel = channels.join("/");

        RegExp regExp = RegExp(
          channel.replaceAll("\\+", "[^/]+").replaceAll("#", ".+"),
        );

        if (regExp.hasMatch(topic)) {
          if (!value.hasValue || value.value != message) {
            value.add(message);
          }
        }
      });
    });

    _client?.subscribe("${uri.channel}#", MqttQos.exactlyOnce);
  }

  void filter(String channel, String? Function(String) filter) {
    _filters[channel] = filter;
  }

  Stream<String> watch(String channel) {
    StreamController<String> controller = _subscribtions.putIfAbsent(
      channel,
      () => BehaviorSubject(),
    );

    return controller.stream;
  }

  void _publish(String topic, String message) {
    if (_state.value != MClientState.connected) {
      throw "the mclient has to be connected, before publish";
    }

    List<String> topics = "${_uri.value?.channel}$topic".split("/");
    topics.removeWhere((element) => element.isEmpty);
    topic = topics.join("/");

    MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addUTF8String(message);

    _client!.publishMessage(
      topic,
      MqttQos.exactlyOnce,
      builder.payload!,
      retain: true,
    );
  }

  Future<void> disconnect() async {
    _client?.disconnect();
    _client = null;
  }

  @override
  void dispose() {
    _uri.close();
    _username.close();
    _password.close();
    _state.close();
    _message.close();
    _subscribtions.forEach((key, value) {
      value.close();
    });
  }
}
