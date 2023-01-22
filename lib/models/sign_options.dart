import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
part 'sign_options.g.dart';

@HiveType(typeId: 2)
class SignOptions extends HiveObject {
  static Box<SignOptions> get boxx {
    Box<SignOptions> box = Hive.box((SignOptions).toString());
    return box;
  }

  @HiveField(0)
  final String identifier;

  @HiveField(1)
  final String lottie;

  @HiveField(2)
  final String sound;

  @HiveField(3)
  final Color color;

  SignOptions({
    required this.identifier,
    required this.lottie,
    required this.sound,
    required this.color,
  });

  factory SignOptions.fromMap(Map<String, dynamic> json) {
    return SignOptions(
      identifier: json["identifier"] ?? "",
      lottie: json["lottie"] ?? "",
      sound: json["sound"] ?? "",
      color: Colors.black,
    );
  }

  @override
  Future<void> save() async {
    if (isInBox) {
      super.save();
      return;
    }
    await boxx.add(this);
  }

  @override
  String toString() {
    return "identifier: $identifier; lottie: $lottie; sound: $sound, color: $color;";
  }
}
