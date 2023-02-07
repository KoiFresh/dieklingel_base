import 'dart:convert';
import 'dart:io';

import 'package:dieklingel_base/bloc/bloc_provider.dart';
import 'package:dieklingel_base/blocs/app_bloc.dart';
import 'package:dieklingel_base/touch_scroll_behavior.dart';
import 'package:dieklingel_base/view_models/home_view_model.dart';
import 'package:dieklingel_base/views/home_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'messaging/mclient.dart';
import 'models/ice_server.dart';
import 'models/mqtt_uri.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Map<String, dynamic> config = await getConfig();

  //await configure(config);

  await Hive.initFlutter();
  Hive
    ..registerAdapter(MqttUriAdapter())
    ..registerAdapter(IceServerAdapter());

  await Future.wait([
    Hive.openBox<IceServer>((IceServer).toString()),
    Hive.openBox("settings"),
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: ((context) => MClient()),
        ),
      ],
      child: BlocProvider(
        bloc: AppBloc(),
        child: MyApp(
          config: config,
        ),
      ),
    ),
  );
}

Future<Map<String, dynamic>> getConfig() async {
  Map<String, dynamic> result = {};
  try {
    final configFile = File("/etc/dieklingel/config.json");
    result = await jsonDecode(
      await configFile.readAsString(),
    );
  } catch (exception) {
    // could not load, do nothing
  }
  return result;
}

Future<void> configure(Map<String, dynamic> config) async {
  Box settings = Hive.box("settings");

  settings.put(
    "mqtt.uri",
    MqttUri.fromUri(
      Uri.parse(config["mqtt"]?["uri"] ?? ""),
    ),
  );

  settings.put("mqtt.username", config["mqtt"]?["username"] ?? "");
  settings.put("mqtt.password", config["mqtt"]?["password"] ?? "");

  settings.put(
    "viewport.clip.left",
    double.parse(
      config["viewport"]?["clip"]?["left"]?.toString() ?? "0",
    ),
  );

  settings.put(
    "viewport.clip.top",
    double.parse(
      config["viewport"]?["clip"]?["top"]?.toString() ?? "0",
    ),
  );

  settings.put(
    "viewport.clip.right",
    double.parse(
      config["viewport"]?["clip"]?["right"]?.toString() ?? "0",
    ),
  );

  settings.put(
    "viewport.clip.bottom",
    double.parse(
      config["viewport"]?["clip"]?["bottom"]?.toString() ?? "0",
    ),
  );

  settings.put(
    "screensaver.enabled",
    config["screensaver"]?["enabled"] as bool? ?? true,
  );

  settings.put(
    "screensaver.file",
    config["screensaver"]?["file"] as String? ?? "",
  );
}

class MyApp extends StatefulWidget {
  final Map<String, dynamic> config;

  const MyApp({super.key, this.config = const {}});

  @override
  State<MyApp> createState() => _MyApp();
}

class _MyApp extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    EdgeInsets insets = EdgeInsets.fromLTRB(
      double.parse(
        widget.config["viewport"]?["clip"]?["left"]?.toString() ?? "0",
      ),
      double.parse(
        widget.config["viewport"]?["clip"]?["top"].toString() ?? "0",
      ),
      double.parse(
        widget.config["viewport"]?["clip"]?["right"].toString() ?? "0",
      ),
      double.parse(
        widget.config["viewport"]?["clip"]?["bottom"].toString() ?? "0",
      ),
    );

    return StreamBuilder(
      stream: context.bloc<AppBloc>().clip,
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
              home: HomeView(
                vm: HomeViewModel(),
                config: widget.config,
              ),
            ),
          ),
        );
      },
    );
  }
}
