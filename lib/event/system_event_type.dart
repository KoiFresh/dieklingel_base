enum SystemEventType {
  image("image"),
  text("text"),
  notification("notification");

  final String type;
  const SystemEventType(this.type);

  static SystemEventType fromString(String value) {
    switch (value) {
      case "image":
        return SystemEventType.image;
      case "notification":
        return SystemEventType.notification;
    }
    return SystemEventType.text;
  }
}
