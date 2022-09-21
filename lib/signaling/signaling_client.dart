import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'signaling_message.dart';
import '../messaging/messaging_client.dart';

class SignalingClient extends ChangeNotifier {
  final MessagingClient _messagingClient;
  String signalingTopic;
  String uid;
  final StreamController<SignalingMessage> broadcastController =
      StreamController<SignalingMessage>.broadcast();
  final StreamController<SignalingMessage> messageController =
      StreamController<SignalingMessage>.broadcast();

  SignalingClient.fromMessagingClient(
    this._messagingClient, {
    this.signalingTopic = "",
    this.uid = "",
  }) {
    _messagingClient.messageController.stream.listen((event) {
      if ("${_messagingClient.prefix}$signalingTopic" != event.topic) return;
      try {
        SignalingMessage message =
            SignalingMessage.fromJson(jsonDecode(event.message));
        if ("" == message.recipient) {
          broadcastController.add(message);
        } else if (uid == message.recipient) {
          messageController.add(message);
        }
      } catch (exception) {
        print(
          "could not convert the message into a signaling message;$exception",
        );
      }
    });
    /*_messagingClient.addEventListener("message:$_signalingTopic", (raw) {
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
    });*/
  }

  void send(SignalingMessage message) {
    if (signalingTopic == "") {
      throw Exception("the signaling topic cannot be ''");
    }
    String raw = jsonEncode(message.toJson());
    _messagingClient.send(signalingTopic, raw);
  }
}
