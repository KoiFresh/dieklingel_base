import 'dart:collection';

import 'package:dieklingel_base/event/system_event.dart';
import 'package:flutter/material.dart';

const int maxCachedEvents = 30;

class EventMonitor extends ChangeNotifier {
  final List<SystemEvent> _events = [];

  List<SystemEvent> get event {
    return UnmodifiableListView(_events);
  }

  void add(SystemEvent event) {
    _events.add(event);
    if (_events.length > maxCachedEvents) {
      _events.remove(_events.first);
    }
    notifyListeners();
  }
}
