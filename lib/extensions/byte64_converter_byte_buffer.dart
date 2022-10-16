import 'dart:convert';
import 'dart:typed_data';

extension Converter on ByteBuffer {
  Future<String> asB64String({String data = ""}) async {
    List<int> bytes = asUint8List();
    String base64 = base64Encode(bytes);
    if (data.isEmpty) {
      return base64;
    }
    return "data:$data;$base64";
  }
}
