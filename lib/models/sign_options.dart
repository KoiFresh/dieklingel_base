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
  final String filepath;

  @HiveField(2)
  final String color;

  SignOptions({
    required this.identifier,
    required this.filepath,
    required this.color,
  });

  factory SignOptions.fromMap(Map<String, dynamic> json) {
    return SignOptions(
      identifier: json["identifier"],
      filepath: json["filepath"],
      color: json["color"] ?? "#000000",
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
    return "identifier: $identifier; filepath: $filepath; color: $color;";
  }
}
