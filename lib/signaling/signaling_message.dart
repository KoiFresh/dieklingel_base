class SignalingMessage {
  String from = '';
  String to = '';
  String type = '';
  Map<String, dynamic> data = {};

  SignalingMessage();

  SignalingMessage.fromJson(Map<String, dynamic> json)
      : from = json['from'],
        to = json['to'],
        type = json['type'],
        data = json['data'];

  Map<String, dynamic> toJson() => {
        'from': from,
        'to': to,
        'type': type,
        'data': data,
      };
}
