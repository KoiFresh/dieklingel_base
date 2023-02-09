import 'dart:async';
import 'dart:io';

import 'package:dieklingel_base/bloc/bloc_provider.dart';
import 'package:dieklingel_base/blocs/mqtt_state_mixin.dart';
import 'package:dieklingel_base/blocs/screensaver_view_bloc.dart';
import 'package:dieklingel_base/view_models/home_view_model.dart';
import 'package:dieklingel_base/views/passcode_view.dart';
import 'package:flutter/cupertino.dart';
import '../bloc/multi_bloc_provider.dart';
import '../bloc/stream_event.dart';
import '../blocs/sign_view_bloc.dart';
import '../models/mqtt_uri.dart';
import 'screensaver_view.dart';
import 'sign_view.dart';

class HomeView extends StatefulWidget {
  final HomeViewModel vm;
  final Map<String, dynamic> config;
  const HomeView({
    required this.vm,
    this.config = const {},
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _HomeView();
}

class _HomeView extends State<HomeView> with MqttStateMixin {
  late final StreamSubscription _activity;
  final _controller = PageController();

  @override
  void initState() {
    _activity = activity.listen((event) {
      if (event is InactiveState) {
        _controller.jumpToPage(0);
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _activity.cancel();
    super.dispose();
  }

  void init() async {
    try {
      MqttUri uri = MqttUri.fromUri(
        Uri.parse(widget.config["mqtt"]?["uri"] ?? ""),
      );
      await widget.vm.client.connect(uri);
    } on SocketException catch (exception) {
      stderr.writeln("Socket Exception: ${exception.message}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: MultiBlocProvider(
        blocs: [
          BlocProvider(bloc: SignViewBloc()),
          BlocProvider(bloc: ScreensaverViewBloc()),
        ],
        child: StreamBuilder(
          stream: display,
          builder: (context, AsyncSnapshot<DisplayState> snapshot) {
            if (snapshot.data is DisplayOffState) {
              return ScreensaverView();
            }
            return PageView(
              controller: _controller,
              children: const [
                SignView(),
                PasscodeView(),
              ],
            );
          },
        ),
      ),
    );
  }
}
