abstract class StreamEvent {}

abstract class ActivityState extends StreamEvent {}

class InactiveState extends ActivityState {}

class ActiveState extends ActivityState {}

abstract class DisplayState extends StreamEvent {
  bool get isOn;
}

class DisplayOnState extends DisplayState {
  @override
  bool get isOn => true;
}

class DisplayOffState extends DisplayState {
  @override
  bool get isOn => false;
}
