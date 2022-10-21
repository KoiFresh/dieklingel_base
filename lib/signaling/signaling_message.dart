import 'dart:convert';

import './signaling_message_type.dart';

class SignalingMessage {
  SignalingMessageType type = SignalingMessageType.error;
  Map<String, dynamic> data = {};

  SignalingMessage();

  SignalingMessage.fromJson(Map<String, dynamic> json)
      : type = SignalingMessageType.fromString(json['type']),
        data = json['data'];

  Map<String, dynamic> toJson() => {
        'type': type.toString(),
        'data': data,
      };

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}
