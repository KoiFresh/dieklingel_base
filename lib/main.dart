import 'dart:convert';

import 'package:dieklingel_base/touch_scroll_behavior.dart';
import 'package:dieklingel_base/views/home_view_page.dart';
import 'globals.dart' as app;
import 'package:dieklingel_base/views/loading_view_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await app.init();
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
    String configPath = "resources/config/config.json";
    String rawConfig = await rootBundle.loadString(configPath);
    dynamic config = jsonDecode(rawConfig);

    /*EdgeInsetsGeometry insets = EdgeInsets.fromLTRB(
      double.parse(config["viewport"]["clip"]["left"]) ?? 0.0,
      config["viewport"]["clip"]["top"] ?? 0.0,
      config["viewport"]["clip"]["right"] ?? 0.0,
      config["viewport"]["clip"]["bottom"] ?? 0.0,
    ); */

    EdgeInsets insets = EdgeInsets.fromLTRB(
      0,
      0,
      0,
      0,
    );

    setState(() {
      geometry = insets;
    });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: geometry,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: MaterialApp(
          scrollBehavior: TouchScrollBehavior(),
          home: Scaffold(
            body: LoadingViewPage(),
          ),
        ),
      ),
    );
  }
}
