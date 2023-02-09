import 'package:dieklingel_base/bloc/bloc.dart';
import 'package:dieklingel_base/models/screensaver_options.dart';
import 'package:hive/hive.dart';
import 'package:rxdart/rxdart.dart';

class ScreensaverViewBloc extends Bloc {
  final _file = BehaviorSubject<String>.seeded("");

  Stream<ScreensaverOptions> get options => _file.stream.map(
        (event) => ScreensaverOptions(file: event),
      );

  ScreensaverViewBloc() {
    Box settings = Hive.box("settings");

    _file.add(settings.get("screensaver.file"));
    settings.watch(key: "screensaver.file").listen((event) {
      _file.add(event.value);
    });
  }

  @override
  void dispose() {
    _file.close();
  }
}
