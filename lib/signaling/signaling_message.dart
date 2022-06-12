class SignalingMessage {
  String from = '';
  String to = '';
  String type = '';
  Map<String, dynamic> data = {};

  SignalingMessage();

  SignalingMessage.fromJson(Map<String, dynamic> json)
      : from = json['sender'],
        to = json['recipient'],
        type = json['type'],
        data = json['data'];

  Map<String, dynamic> toJson() => {
        'sender': from,
        'recipient': to,
        'type': type,
        'data': data,
      };
}
