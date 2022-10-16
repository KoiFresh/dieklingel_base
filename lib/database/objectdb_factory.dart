import 'package:objectdb/objectdb.dart';

import 'objectdb_mobile_storage_factory.dart'
    if (dart.library.js) 'objectdb_web_factory.dart';

typedef JSON = Map<dynamic, dynamic>;

class ObjectDBFactory {
  static ObjectDB get({String? path}) {
    path ??= ObjectDBStorageFactory.defaultPath;
    return ObjectDB(ObjectDBStorageFactory.get(path));
  }
}
