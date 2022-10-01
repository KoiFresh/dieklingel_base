import 'dart:convert';

import 'error_view_page.dart';
import 'home_view_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const String configPath = "resources/config/config.json";

class LoadingViewPage extends StatefulWidget {
  const LoadingViewPage({super.key, this.onLoad});

  final Function(Map<String, dynamic> config)? onLoad;

  @override
  State<LoadingViewPage> createState() => _LoadingViewPage();
}

class _LoadingViewPage extends State<LoadingViewPage> {
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    try {
      String raw = await rootBundle.loadString(configPath);
      Map<String, dynamic> config = jsonDecode(raw);
      widget.onLoad?.call(config);
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (((context) => HomeViewPage(config: config))),
        ),
      );
    } catch (exception) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: ((context) => const ErrorViewPage()),
        ),
      );
    } finally {
      init();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          CircularProgressIndicator(),
          Padding(
            padding: EdgeInsets.all(12.0),
            child: Text("Loading..."),
          ),
        ],
      )),
    );
  }
}
