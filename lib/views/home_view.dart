import 'dart:io';

import 'package:dieklingel_base/view_models/home_view_model.dart';
import 'package:dieklingel_base/view_models/sign_view_model.dart';
import 'package:dieklingel_base/views/passcode_view.dart';
import 'package:flutter/cupertino.dart';

import '../models/mqtt_uri.dart';
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
    init();
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
      child: PageView(
        children: [
          SignView(
            vm: SignViewModel(),
            config: widget.config,
          ),
          const PasscodeView(),
        ],
      ),
    );
  }
}
