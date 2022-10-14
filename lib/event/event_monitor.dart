import 'system_event.dart';
import 'package:flutter/material.dart';

const int maxCachedEvents = 10;

class EventMonitor extends ChangeNotifier {
  final List<SystemEvent> _events = [];

  List<SystemEvent> get events {
    return _events.toList(growable: false);
  }

  void add(SystemEvent event) {
    _events.add(event);
    if (_events.length > maxCachedEvents) {
      _events.remove(_events.first);
    }
    notifyListeners();
  }
}
