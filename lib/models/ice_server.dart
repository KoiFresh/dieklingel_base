import 'package:hive/hive.dart';
import 'package:yaml/yaml.dart';
part 'ice_server.g.dart';

@HiveType(typeId: 3)
class IceServer extends HiveObject {
  static Box<IceServer> get boxx {
    Box<IceServer> box = Hive.box((IceServer).toString());
    return box;
  }

  @HiveField(0)
  String urls;

  @HiveField(1)
  String username;

  @HiveField(2)
  String credential;

  IceServer({
    required this.urls,
    this.username = "",
    this.credential = "",
  });

  factory IceServer.fromYaml(YamlMap yaml) {
    return IceServer(
      urls: yaml["urls"] ?? "",
      username: yaml["username"] ?? "",
      credential: yaml["credential"] ?? "",
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
    return "urls: $urls; username: $username; credential: $credential";
  }

  @override
  bool operator ==(Object other) {
    if (other is! IceServer) {
      return false;
    }
    return urls == other.urls &&
        username == other.username &&
        credential == other.credential;
  }

  @override
  int get hashCode => Object.hash(urls, username, credential);
}
