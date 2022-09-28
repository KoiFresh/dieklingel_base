import 'package:dieklingel_base/components/notifyable_value.dart';
import 'package:flutter/material.dart';

class AppSettings extends ChangeNotifier {
  NotifyableValue<String> lastLog = NotifyableValue(value: "No Log");
  NotifyableValue<String> snapshot = NotifyableValue(value: "");
  NotifyableValue<bool> displayIsActive = NotifyableValue(value: false);

  AppSettings() {
    lastLog.addListener(notifyListeners);
    snapshot.addListener(notifyListeners);
    displayIsActive.addListener(notifyListeners);
  }

  void log(String message) {
    lastLog.value = message;
  }
}
