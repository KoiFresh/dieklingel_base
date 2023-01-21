import 'package:dieklingel_base/views/components/sign.dart';
import 'package:flutter/cupertino.dart';

class SignViewModel extends ChangeNotifier {
  Map<String, dynamic> config = {};

  List<Sign> signs = [];

  void init({required Map<String, dynamic> config}) {
    this.config = config;

    List<dynamic> signs = config["signs"] ?? [];
    this.signs.clear();
    for (dynamic sign in signs) {
      Sign s = Sign(sign["text"], sign["hash"]);
      this.signs.add(s);
    }

    notifyListeners();
  }
}
