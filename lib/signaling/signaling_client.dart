import 'dart:convert';
import 'package:dieklingel_base/event/event_emitter.dart';

import 'signaling_message.dart';
import '../messaging/messaging_client.dart';

class SignalingClient extends EventEmitter {
  final MessagingClient _messagingClient;
  final String _signalingTopic;
  final String _uid;

  String get uid {
    return _uid;
  }

  SignalingClient.fromMessagingClient(
    this._messagingClient,
    this._signalingTopic,
    this._uid,
  ) {
    _messagingClient.addEventListener("message:$_signalingTopic", (raw) {
      try {
        SignalingMessage message = SignalingMessage.fromJson(jsonDecode(raw));
        if ("" == message.recipient) {
          emit("broadcast", message);
        } else if (_uid == message.recipient) {
          emit("message", message);
        }
      } catch (exception) {
        emit(
          "error",
          "could not convert the message into a signaling message;$exception",
        );
        print(
          "could not convert the message into a signaling message;$exception",
        );
      }
    });
  }

  void send(SignalingMessage message) {
    String raw = jsonEncode(message.toJson());
    _messagingClient.send(_signalingTopic, raw);
  }
}
