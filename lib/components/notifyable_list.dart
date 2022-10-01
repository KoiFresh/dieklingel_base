import 'dart:collection';

import 'package:flutter/material.dart';

class NotifyableList<T> extends ChangeNotifier {
  final List<T> _list = [];

  UnmodifiableListView<T> get list => UnmodifiableListView(_list);

  void clear() {
    _list.clear();
    notifyListeners();
  }

  void replaceList(List<T> list) {
    _list.clear();
    _list.addAll(list);
    notifyListeners();
  }

  void add(T item) {
    _list.add(item);
    notifyListeners();
  }

  void remove(T item) {
    _list.remove(item);
    notifyListeners();
  }

  void removeAt(int index) {
    _list.removeAt(index);
    notifyListeners();
  }

  void removeWhere(bool Function(T) test) {
    _list.removeWhere(test);
    notifyListeners();
  }

  void removeRange(int start, int end) {
    _list.removeRange(start, end);
    notifyListeners();
  }
}
