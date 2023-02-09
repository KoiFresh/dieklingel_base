import 'package:dieklingel_base/models/sign_options.dart';

class ScreensaverOptions {
  final String file;

  SignType get type {
    if (file.endsWith(".lottie") || file.endsWith(".json")) {
      return SignType.lottie;
    } else if (file.endsWith(".html")) {
      return SignType.html;
    } else if (file.endsWith(".png") ||
        file.endsWith(".jpeg") ||
        file.endsWith(".jpg")) {
      return SignType.image;
    }
    return SignType.none;
  }

  ScreensaverOptions({required this.file});
}
