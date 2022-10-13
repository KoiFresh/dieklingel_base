import 'package:dieklingel_base/event/system_event_type.dart';

class SystemEvent {
  final DateTime timestamp;
  final SystemEventType type;
  final String payload;

  SystemEvent({
    required this.type,
    required this.payload,
  }) : timestamp = DateTime.now().toUtc();

  SystemEvent.fromJson(Map<String, dynamic> json)
      : timestamp = DateTime.parse(json["timestamp"]),
        type = SystemEventType.fromString(json["type"]),
        payload = json["payload"];
}
