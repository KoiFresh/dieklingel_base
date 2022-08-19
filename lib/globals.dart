library dieklingel_base.globals;

import 'package:shared_preferences/shared_preferences.dart';

late SharedPreferences _preferences;

Future<void> init() async {
  _preferences = await SharedPreferences.getInstance();
}

SharedPreferences get preferences {
  return _preferences;
}
