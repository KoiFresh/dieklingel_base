import 'notifyable_map.dart';
import 'notifyable_value.dart';
import 'package:flutter/material.dart';

class AppSettings extends ChangeNotifier {
  final NotifyableValue<String> lastLog = NotifyableValue(value: "No Log");
  final NotifyableValue<String> snapshot = NotifyableValue(value: "");
  final NotifyableValue<bool> displayIsActive = NotifyableValue(value: false);
  final NotifyableMap<String, List<String>> signHashs =
      NotifyableMap<String, List<String>>();

  AppSettings() {
    lastLog.addListener(notifyListeners);
    snapshot.addListener(notifyListeners);
    displayIsActive.addListener(notifyListeners);
    signHashs.addListener(notifyListeners);
  }

  void log(String message) {
    lastLog.value = message;
  }
}
