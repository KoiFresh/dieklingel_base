import './signaling_message_type.dart';

class SignalingMessage {
  String sender = '';
  String recipient = '';
  SignalingMessageType type = SignalingMessageType.error;
  Map<String, dynamic> data = {};

  SignalingMessage();

  SignalingMessage.fromJson(Map<String, dynamic> json)
      : sender = json['sender'],
        recipient = json['recipient'],
        type = SignalingMessageType.fromString(json['type']),
        data = json['data'];

  Map<String, dynamic> toJson() => {
        'sender': sender,
        'recipient': recipient,
        'type': type.toString(),
        'data': data,
      };
}
