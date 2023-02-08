import 'dart:io';

import 'package:dieklingel_base/bloc/bloc_provider.dart';
import 'package:dieklingel_base/messaging/mqtt_client_bloc.dart';
import 'package:dieklingel_base/view_models/home_view_model.dart';
import 'package:dieklingel_base/view_models/sign_view_model.dart';
import 'package:dieklingel_base/views/passcode_view.dart';
import 'package:flutter/cupertino.dart';

import '../bloc/multi_bloc_provider.dart';
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

class _HomeView extends State<HomeView> {
  @override
  void initState() {
    //init();
    super.initState();
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
          BlocProvider(bloc: SignViewBloc()),
        ],
        child: StreamBuilder(
          stream: context.bloc<MqttClientBloc>().watch("display/state"),
          builder: (context, AsyncSnapshot<String> snapshot) {
            if (snapshot.hasData && snapshot.data == "off") {
              return ScreensaverView();
            }
            return PageView(
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
