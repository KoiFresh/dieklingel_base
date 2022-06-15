import './signaling_message_type.dart';

class SignalingMessage {
  String from = '';
  String to = '';
  SignalingMessageType type = SignalingMessageType.error;
  Map<String, dynamic> data = {};

  SignalingMessage();

  SignalingMessage.fromJson(Map<String, dynamic> json)
      : from = json['sender'],
        to = json['recipient'],
        type = SignalingMessageType.fromString(json['type']),
        data = json['data'];

  Map<String, dynamic> toJson() => {
        'sender': from,
        'recipient': to,
        'type': type.toString(),
        'data': data,
      };
}
