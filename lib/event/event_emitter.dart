import 'package:synchronized/synchronized.dart';

class EventEmitter {
  final Map<String, List<Function(dynamic data)>> _callbacks = {};
  final Lock _lock = Lock();

  void addEventListener(String event, Function(dynamic data) callback) {
    _lock.synchronized(() {
      if (null == _callbacks[event]) {
        _callbacks[event] = <Function(dynamic data)>[];
      }
      if (_callbacks[event] != null && !_callbacks[event]!.contains(callback)) {
        _callbacks[event]?.add(callback);
      }
    });
  }

  void removeEventListener(String event, Function(dynamic data) callback) {
    _lock.synchronized(() {
      _callbacks[event]?.remove(callback);
    });
  }

  void emit(String event, dynamic data) {
    _lock.synchronized(() {
      List<Function(dynamic data)>? callbacks = _callbacks[event];
      callbacks?.forEach((callback) {
        callback(data);
      });
    });
  }
}
