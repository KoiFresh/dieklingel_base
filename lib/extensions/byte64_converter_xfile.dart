import 'dart:convert';

import 'package:camera/camera.dart';

extension Converter on XFile {
  Future<String> asB64String({String data = ""}) async {
    List<int> bytes = await readAsBytes();
    String base64 = base64Encode(bytes);
    if (data.isEmpty) {
      return base64;
    }
    return "data:$data;$base64";
  }
}
