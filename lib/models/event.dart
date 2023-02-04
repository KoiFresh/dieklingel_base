import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';

part 'event.g.dart';

@HiveType(typeId: 4)
class Event extends HiveObject with ChangeNotifier {
  static Box<Event> get boxx {
    Box<Event> box = Hive.box((Event).toString());
    return box;
  }

  @HiveField(0)
  final DateTime time;

  @HiveField(1)
  final String data;

  Event({required this.data, DateTime? time}) : time = time ?? DateTime.now();

  @override
  Future<void> save() async {
    if (isInBox) {
      await super.save();
      return;
    }
    await boxx.add(this);
  }

  Map<String, dynamic> toJson() {
    return {
      "time": time.toIso8601String(),
      "data": data,
    };
  }

  @override
  String toString() {
    return "Time: $time; Data: $data;";
  }
}
