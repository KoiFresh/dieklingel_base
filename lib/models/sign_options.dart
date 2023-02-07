import 'dart:io';

import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:yaml/yaml.dart';
part 'sign_options.g.dart';

enum SignType {
  none,
  lottie,
  html,
  image;
}

@HiveType(typeId: 2)
class SignOptions extends HiveObject {
  static Box<SignOptions> get boxx {
    Box<SignOptions> box = Hive.box((SignOptions).toString());
    return box;
  }

  @HiveField(0)
  final String identifier;

  @HiveField(1)
  final String file;

  @HiveField(2)
  final String? sound;

  @HiveField(3)
  int _type = SignType.none.index;

  SignType get type => SignType.values.firstWhere(
        (element) => element.index == _type,
        orElse: () => SignType.none,
      );

  SignOptions({
    required this.identifier,
    required this.file,
    required this.sound,
  }) {
    if (identifier.isEmpty) {
      throw "Cannot create Sign with an empty identifier";
    }
    if (file.isEmpty) {
      throw "Cannot create Sign $identifier with an empty file";
    }

    if (file.endsWith(".lottie") || file.endsWith(".json")) {
      _type = SignType.lottie.index;
    } else if (file.endsWith(".html")) {
      _type = SignType.html.index;
    } else if (file.endsWith(".png") ||
        file.endsWith(".jpeg") ||
        file.endsWith(".jpg")) {
      _type = SignType.image.index;
    } else {
      _type = SignType.none.index;
      throw "Cannot create Sign $identifier with file $file, extension is not supportet. Supportet extionses are: .lottie, .json, .html, .png, .jpeg, .jpg";
    }
  }

  factory SignOptions.fromYaml(YamlMap yaml) {
    return SignOptions(
      identifier: yaml["identifier"] ?? "",
      file: yaml["file"] ?? "",
      sound: yaml["sound"] ?? "",
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
    return "identifier: $identifier; file: $file; sound: $sound;";
  }
}
