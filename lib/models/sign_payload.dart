import 'package:hive/hive.dart';

part 'sign_payload.g.dart';

@HiveType(typeId: 5)
class SignPayload extends HiveObject {
  static Box<SignPayload> get boxx {
    Box<SignPayload> box = Hive.box((SignPayload).toString());
    return box;
  }

  @HiveField(0)
  DateTime _timestamp = DateTime.now();

  DateTime get timestamp => _timestamp;

  @HiveField(1)
  String identifier;

  @HiveField(2)
  String device;

  @HiveField(3)
  String payload;

  SignPayload({
    required this.identifier,
    required this.device,
    required this.payload,
  });

  @override
  Future<void> save() async {
    _timestamp = DateTime.now();
    if (isInBox) {
      super.save();
      return;
    }
    await boxx.add(this);
  }

  @override
  bool operator ==(Object other) {
    if (other is! SignPayload) {
      return false;
    }
    return other.identifier == identifier && other.device == device;
  }

  @override
  String toString() {
    return "identifier: $identifier; device: $device; payload: $payload; timestamp: $timestamp";
  }

  @override
  int get hashCode => Object.hash(identifier, device);
}
