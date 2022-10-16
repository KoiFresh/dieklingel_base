import 'package:objectdb/objectdb.dart';
// ignore: implementation_imports
import 'package:objectdb/src/objectdb_storage_filesystem.dart';

class ObjectDBStorageFactory {
  static StorageInterface get(String path) {
    return FileSystemStorage(path);
  }

  static String get defaultPath {
    throw UnimplementedError("default path not implemented yet");
  }
}
