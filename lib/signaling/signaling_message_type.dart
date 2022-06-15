enum SignalingMessageType {
  offer("offer"),
  answer("answer"),
  candidate("new-ice-candidate"),
  leave("leave"),
  busy("busy"),
  error("error");

  static SignalingMessageType fromString(String value) {
    switch (value) {
      case "offer":
        return SignalingMessageType.offer;
      case "answer":
        return SignalingMessageType.answer;
      case "new-ice-candidate":
        return SignalingMessageType.candidate;
      case "leave":
        return SignalingMessageType.leave;
      case "busy":
        return SignalingMessageType.busy;
      default:
        return SignalingMessageType.error;
    }
  }

  const SignalingMessageType(this.value);
  final String value;

  @override
  String toString() {
    return value;
  }
}
