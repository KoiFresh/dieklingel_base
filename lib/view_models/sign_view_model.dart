import 'package:dieklingel_base/models/sign_options.dart';
import 'package:dieklingel_base/views/components/sign.dart';
import 'package:flutter/cupertino.dart';

class SignViewModel extends ChangeNotifier {
  Map<String, dynamic> config = {};

  List<SignOptions> options = [];

  void init({required Map<String, dynamic> config}) {
    this.config = config;

    List<dynamic> configuarations = config["signs"] ?? [];
    options.clear();
    /* for (dynamic conf in configuarations) {
      SignOptions option = SignOptions.fromMap(conf);
      options.add(option);
    }*/

    notifyListeners();
  }
}
