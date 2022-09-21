import 'package:dieklingel_base/messaging/messaging_client.dart';
import 'package:flutter/material.dart';

class AppSettings extends ChangeNotifier {
  final MessagingClient messagingClient;

  AppSettings.fromMessagingClient(this.messagingClient) {
    messagingClient.messageController.stream.listen((event) {
      if (event.topic == "${messagingClient.prefix}io/display/state") {
        displayIsActive = event.message == "on";
      }
    });
  }

  bool _displayIsActive = false;

  bool get displayIsActive {
    return _displayIsActive;
  }

  set displayIsActive(bool value) {
    if (value == displayIsActive) return;
    _displayIsActive = value;
    notifyListeners();
    messagingClient.send("io/display/state", displayIsActive ? "on" : "off");
  }
}
