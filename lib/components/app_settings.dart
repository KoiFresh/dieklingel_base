import 'package:flutter/material.dart';

import '../messaging/messaging_client.dart';

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
    if (!messagingClient.isConnected()) return;
    messagingClient.send("io/display/state", displayIsActive ? "on" : "off");
  }

  String _log = "nothing logged";

  String get log {
    return _log;
  }

  set log(String value) {
    _log = value;
    notifyListeners();
    if (!messagingClient.isConnected()) return;
    messagingClient.send("system/log", _log);
  }
}
