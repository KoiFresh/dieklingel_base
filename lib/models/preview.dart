import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

@HiveType(typeId: 4)
class Preview extends HiveObject {
  @HiveField(0)
  Image? image;

  @HiveField(1)
  DateTime? timestamp;

  Preview({
    this.image,
    this.timestamp,
  });
}
