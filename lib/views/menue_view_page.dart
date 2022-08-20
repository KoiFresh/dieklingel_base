import 'package:flutter/material.dart';

class MenueViewPage extends StatefulWidget {
  const MenueViewPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MenueViewPage();
}

class _MenueViewPage extends State<MenueViewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Menue")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text("foce reload"),
            ),
          ],
        ),
      ),
    );
  }
}
