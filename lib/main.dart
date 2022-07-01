import 'dart:convert';

import 'package:dieklingel_base/views/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyApp();
}

class _MyApp extends State<MyApp> {
  EdgeInsetsGeometry geometry = const EdgeInsets.all(0);

  @override
  void initState() {
    init();
    super.initState();
  }

  void init() async {
    String configPath = "assets/config/config.json";
    String rawConfig = await rootBundle.loadString(configPath);
    dynamic config = jsonDecode(rawConfig);

    EdgeInsetsGeometry insets = EdgeInsets.fromLTRB(
      config["viewport"]["clip"]["left"] ?? 0,
      config["viewport"]["clip"]["top"] ?? 0,
      config["viewport"]["clip"]["right"] ?? 0,
      config["viewport"]["clip"]["bottom"] ?? 0,
    );
    setState(() {
      geometry = insets;
    });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Container(
        color: Colors.black,
        padding: geometry,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: const Scaffold(
            body: Home(),
          ),
        ),
      ),
    );
  }
}
