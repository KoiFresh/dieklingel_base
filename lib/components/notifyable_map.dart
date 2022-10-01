import 'package:flutter/material.dart';

class NotifyableMap<K, V> extends ChangeNotifier with Map<K, V> {
  final Map<K, V> _map = {};

  void replace(Map<K, V> map) {
    _map.clear();
    _map.addAll(map);
    notifyListeners();
  }

  Map<K, V> asMap() {
    return Map.from(_map);
  }

  @override
  V? operator [](Object? key) {
    return _map[key];
  }

  @override
  void operator []=(K key, V value) {
    _map[key] = value;
    notifyListeners();
  }

  @override
  void addAll(Map<K, V> other) {
    _map.addAll(other);
    notifyListeners();
  }

  @override
  void addEntries(Iterable<MapEntry<K, V>> newEntries) {
    _map.addEntries(newEntries);
    notifyListeners();
  }

  @override
  Map<RK, RV> cast<RK, RV>() {
    // TODO: implement cast
    throw UnimplementedError();
  }

  @override
  void clear() {
    _map.clear();
    notifyListeners();
  }

  @override
  bool containsKey(Object? key) {
    return _map.containsKey(key);
  }

  @override
  bool containsValue(Object? value) {
    return _map.containsValue(value);
  }

  @override
  Iterable<MapEntry<K, V>> get entries => _map.entries;

  @override
  void forEach(void Function(K key, V value) action) {
    _map.forEach(action);
    // TODO: check when to notify listeners
    notifyListeners();
  }

  @override
  bool get isEmpty => _map.isEmpty;

  @override
  bool get isNotEmpty => _map.isNotEmpty;

  @override
  Iterable<K> get keys => _map.keys;

  @override
  int get length => _map.length;
  @override
  Map<K2, V2> map<K2, V2>(MapEntry<K2, V2> Function(K key, V value) convert) {
    // TODO: implement map
    throw UnimplementedError();
  }

  @override
  V putIfAbsent(K key, V Function() ifAbsent) {
    // TODO: implement putIfAbsent
    throw UnimplementedError();
  }

  @override
  V? remove(Object? key) {
    V? removed = _map.remove(key);
    notifyListeners();
    return removed;
  }

  @override
  void removeWhere(bool Function(K key, V value) test) {
    _map.removeWhere(test);
    notifyListeners();
  }

  @override
  V update(K key, V Function(V value) update, {V Function()? ifAbsent}) {
    // TODO: implement update
    throw UnimplementedError();
  }

  @override
  void updateAll(V Function(K key, V value) update) {
    _map.updateAll(update);
    notifyListeners();
  }

  @override
  Iterable<V> get values => _map.values;
}
