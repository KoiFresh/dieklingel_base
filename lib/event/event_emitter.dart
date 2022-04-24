class EventEmitter {
  final Map<String, List<Function(dynamic data)>> _callbacks = {};

  void addEventListener(String event, Function(dynamic data) callback) {
    if (null == _callbacks[event]) {
      _callbacks[event] = <Function(dynamic data)>[];
    }
    if (_callbacks[event] != null && !_callbacks[event]!.contains(callback)) {
      _callbacks[event]?.add(callback);
    }
  }

  void removeEventListener(String event, Function(dynamic data) callback) {
    _callbacks[event]?.remove(callback);
  }

  void emit(String event, dynamic data) {
    _callbacks[event]?.forEach((callback) {
      callback(data);
    });
  }
}
