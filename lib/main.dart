import 'dart:convert';
import 'dart:ffi';

import 'package:dieklingel_base/event/event_monitor.dart';
import 'package:dieklingel_base/register_listeners.dart';
import 'package:dieklingel_base/touch_scroll_behavior.dart';
import 'package:dieklingel_base/views/home_page.dart';
import 'package:dieklingel_base/views/home_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'components/app_settings.dart';
import 'messaging/mclient.dart';
import 'models/ice_server.dart';
import 'models/mqtt_uri.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive
    ..registerAdapter(MqttUriAdapter())
    ..registerAdapter(IceServerAdapter());

  await Hive.openBox("settings");

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: ((context) => MClient()),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyApp();
}

class _MyApp extends State<MyApp> {
  EdgeInsetsGeometry geometry = const EdgeInsets.all(0);
  final RTCVideoRenderer _rtcVideoRenderer = RTCVideoRenderer();

  @override
  void initState() {
    super.initState();
    _rtcVideoRenderer.initialize();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => initialize());
  }

  void initialize() {}

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    /* EdgeInsets insets = EdgeInsets.fromLTRB(
          config["viewport"]?["clip"]?["left"] ?? 0.0,
          config["viewport"]?["clip"]?["top"] ?? 0.0,
          config["viewport"]?["clip"]?["right"] ?? 0.0,
          config["viewport"]?["clip"]?["bottom"] ?? 0.0,
        );*/

    EdgeInsets insets = EdgeInsets.all(10);

    return Container(
      color: Colors.black,
      padding: insets,
      child: ClipRRect(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        borderRadius: BorderRadius.circular(20),
        child: CupertinoApp(
          scrollBehavior: TouchScrollBehavior(),
          home: HomeView(),
        ),
      ),
    );
  }
}
