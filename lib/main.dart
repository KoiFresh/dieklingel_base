import 'package:flutter/material.dart';
import 'globals.dart' as app;
import 'views/loading_view_page.dart';

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
    super.initState();
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
          home: Container(
            color: Colors.black,
            padding: geometry,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Scaffold(
                body: LoadingViewPage(
                  onLoad: (config) {
                    EdgeInsets insets = EdgeInsets.fromLTRB(
                      config["viewport"]["clip"]["left"] ?? 0.0,
                      config["viewport"]["clip"]["left"] ?? 0.0,
                      config["viewport"]["clip"]["left"] ?? 0.0,
                      config["viewport"]["clip"]["left"] ?? 0.0,
                    );
                    setState(() {
                      geometry = insets;
                    });
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
