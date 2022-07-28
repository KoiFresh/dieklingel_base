import 'dart:convert';

import 'package:crypto/crypto.dart';

final Hash sha2562 = _Sha2562._();

class _Sha2562 extends Hash {
  @override
  final int blockSize = sha256.blockSize;

  _Sha2562._();

  @override
  Digest convert(List<int> input) {
    String first = super.convert(input).toString();
    return super.convert(utf8.encode(first));
  }

  @override
  ByteConversionSink startChunkedConversion(Sink<Digest> sink) =>
      sha256.startChunkedConversion(sink);
}
