import 'dart:io';

import 'package:dieklingel_base/bloc/bloc_provider.dart';
import 'package:dieklingel_base/blocs/app_view_bloc.dart';
import 'package:dieklingel_base/messaging/mqtt_client_bloc.dart';
import 'package:dieklingel_base/models/sign_options.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:yaml/yaml.dart';
import 'bloc/multi_bloc_provider.dart';
import 'messaging/mclient.dart';
import 'models/ice_server.dart';
import 'models/mqtt_uri.dart';
import 'views/app_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive
    ..registerAdapter(MqttUriAdapter())
    ..registerAdapter(SignOptionsAdapter())
    ..registerAdapter(IceServerAdapter());

  await Future.wait([
    Hive.openBox<IceServer>((IceServer).toString()),
    Hive.openBox<SignOptions>((SignOptions).toString()),
    Hive.openBox("settings"),
  ]);

  await configure(await getConfig());

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: ((context) => MClient()),
        ),
      ],
      child: MutliBlocProvider(
        blocs: [
          BlocProvider(bloc: AppViewBloc()),
          BlocProvider(bloc: MqttClientBloc()),
        ],
        child: MyApp(),
      ),
    ),
  );
}

Future<YamlMap> getConfig() async {
  YamlMap result = YamlMap();
  try {
    final configFile = File("/etc/dieklingel/config.yaml");
    result = await loadYaml(
      await configFile.readAsString(),
    );
  } catch (exception) {
    // could not load, do nothing
  }
  return result;
}

Future<void> configure(YamlMap config) async {
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

  await SignOptions.boxx.clear();
  for (YamlMap sign in config["signs"]) {
    SignOptions options;

    try {
      options = SignOptions.fromYaml(sign);
    } catch (exception) {
      stdout.writeln("Skip Sign: $exception");
      continue;
    }

    await options.save();
  }

  await IceServer.boxx.clear();
  for (YamlMap server in config["webrtc"]["ice"]["ice-servers"]) {
    IceServer iceServer = IceServer.fromYaml(server);
    await iceServer.save();
  }
}
