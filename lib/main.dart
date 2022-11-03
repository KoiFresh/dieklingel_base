import 'dart:convert';

import 'package:dieklingel_base/database/objectdb_factory.dart';
import 'package:dieklingel_base/event/event_monitor.dart';
import 'package:dieklingel_base/register_listeners.dart';
import 'package:dieklingel_base/touch_scroll_behavior.dart';
import 'package:dieklingel_base/views/home_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:provider/provider.dart';
import 'components/app_settings.dart';
import 'globals.dart' as app;
import 'messaging/mclient.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await app.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: ((context) => MClient()),
        ),
        ChangeNotifierProvider(
          create: (context) => AppSettings(),
        ),
        ChangeNotifierProvider(
          create: (context) => EventMonitor(),
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
  late final Map<String, dynamic> config;

  AppSettings get appSettings {
    return Provider.of<AppSettings>(context, listen: false);
  }

  @override
  void initState() {
    super.initState();
    _rtcVideoRenderer.initialize();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      initialize();
    });
  }

  void initialize() {
    registerListeners(
      mClient: context.read<MClient>(),
      eventMonitor: context.read<EventMonitor>(),
      appSettings: context.read<AppSettings>(),
      databse: ObjectDBFactory.get(),
    );

    String rawSignHashs =
        app.preferences.getString("dieklingel.signhashs") ?? "{}";
    Map<String, dynamic> json = jsonDecode(rawSignHashs);
    Map<String, List<String>> signHashs = <String, List<String>>{};
    json.forEach((key, value) {
      List<String> list = List.castFrom(value);
      signHashs[key] = list;
    });

    context.read<AppSettings>().signHashs.replace(signHashs);

    context.read<AppSettings>().signHashs.addListener(() {
      app.preferences.setString(
        "dieklingel.signhashs",
        jsonEncode(context.read<AppSettings>().signHashs.asMap()),
      );
    });
  }

  Future<Map<String, dynamic>> _config() async {
    String configPath = "resources/config/config.json";
    String raw = await rootBundle.loadString(configPath);
    Map<String, dynamic> config = jsonDecode(raw);
    return config;
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _config(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CupertinoApp(
              theme: const CupertinoThemeData().copyWith(
                brightness: Brightness.light,
              ),
              home: const CupertinoPageScaffold(
                child: Center(
                  child: Text(
                    "setup in progress",
                  ),
                ),
              ),
            ),
          );
        }

        Map<String, dynamic> config = snapshot.data!;
        EdgeInsets insets = EdgeInsets.fromLTRB(
          config["viewport"]?["clip"]?["left"] ?? 0.0,
          config["viewport"]?["clip"]?["top"] ?? 0.0,
          config["viewport"]?["clip"]?["right"] ?? 0.0,
          config["viewport"]?["clip"]?["bottom"] ?? 0.0,
        );

        return Container(
          color: Colors.black,
          padding: insets,
          child: ClipRRect(
            clipBehavior: Clip.antiAliasWithSaveLayer,
            borderRadius: BorderRadius.circular(20),
            child: CupertinoApp(
              scrollBehavior: TouchScrollBehavior(),
              home: HomePage(config: config),
            ),
          ),
        );
      },
    );
  }
}
