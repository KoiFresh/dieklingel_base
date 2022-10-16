enum SystemEventType {
  image("image"),
  text("text"),
  notification("notification"),
  warning("warning");

  final String type;
  const SystemEventType(this.type);

  static SystemEventType fromString(String value) {
    switch (value) {
      case "image":
        return SystemEventType.image;
      case "notification":
        return SystemEventType.notification;
      case "warning":
        return SystemEventType.warning;
    }
    return SystemEventType.text;
  }

  @override
  String toString() {
    return type;
  }
}
