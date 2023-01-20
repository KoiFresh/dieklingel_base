import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';

import 'mqtt_uri.dart';

part 'home.g.dart';

@HiveType(typeId: 1)
class Home extends HiveObject with ChangeNotifier {
  static Box<Home> get boxx {
    Box<Home> box = Hive.box((Home).toString());
    return box;
  }

  @HiveField(0)
  String name;

  @HiveField(1)
  MqttUri uri;

  @HiveField(2)
  String? username;

  @HiveField(3)
  String? password;

  Home({
    required this.name,
    required this.uri,
    this.username,
    this.password,
  });

  @override
  Future<void> save() async {
    if (isInBox) {
      await super.save();
      return;
    }
    await boxx.add(this);
  }

  Home copy() {
    return copyWith();
  }

  Home copyWith({
    String? name,
    MqttUri? uri,
    String? username,
    String? password,
  }) =>
      Home(
        name: name ?? this.name,
        uri: uri ?? this.uri,
        username: username ?? this.username,
        password: this.password,
      );

  @override
  bool operator ==(Object other) {
    if (other is! Home) {
      return false;
    }
    return name == other.name &&
        uri == other.uri &&
        username == other.username &&
        password == other.password;
  }

  @override
  int get hashCode => Object.hash(name, uri, username, password);
}
