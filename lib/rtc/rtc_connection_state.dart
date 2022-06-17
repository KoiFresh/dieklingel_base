enum RtcConnectionState {
  invited("invited"),
  connecting("connecting"),
  connected("connected"),
  disconnected("disconnected");

  const RtcConnectionState(this.value);
  final String value;

  @override
  String toString() {
    return value;
  }
}
