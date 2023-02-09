import 'dart:async';

import 'package:dieklingel_base/bloc/bloc_provider.dart';
import 'package:dieklingel_base/blocs/home_view_bloc.dart';
import 'package:dieklingel_base/messaging/mqtt_client_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../blocs/app_view_bloc.dart';
import '../models/mqtt_uri.dart';
import '../touch_scroll_behavior.dart';
import '../view_models/home_view_model.dart';
import 'home_view.dart';

class MyApp extends StatefulWidget {
  final Map<String, dynamic> config;

  const MyApp({super.key, this.config = const {}});

  @override
  State<MyApp> createState() => _MyApp();
}

class _MyApp extends State<MyApp> {
  @override
  void initState() {
    MqttClientBloc mqtt = context.bloc<MqttClientBloc>();
    mqtt.uri.add(
      MqttUri(
        host: "server.dieklingel.com",
        port: 1883,
        channel: "com.dieklingel/",
      ),
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: context.bloc<AppViewBloc>().clip,
      builder: (
        BuildContext context,
        AsyncSnapshot<EdgeInsets> snapshot,
      ) {
        return Container(
          color: Colors.black,
          padding: snapshot.data,
          child: ClipRRect(
            clipBehavior: Clip.antiAliasWithSaveLayer,
            borderRadius: BorderRadius.circular(20),
            child: CupertinoApp(
              scrollBehavior: TouchScrollBehavior(),
              home: BlocProvider(
                bloc: HomeViewBloc(),
                child: HomeView(
                  vm: HomeViewModel(),
                  config: widget.config,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
