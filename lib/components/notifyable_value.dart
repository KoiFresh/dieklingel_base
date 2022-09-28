import 'package:flutter/material.dart';

class NotifyableValue<T> extends ChangeNotifier {
  T _value;

  NotifyableValue({required T value}) : _value = value;

  T get value {
    return _value;
  }

  set value(T newValue) {
    if (newValue == _value) return;
    _value = newValue;
    notifyListeners();
  }

  void setValueAndForceNotify(T newValue) {
    _value = newValue;
    notifyListeners();
  }

  @override
  String toString() {
    return value.toString();
  }
}
