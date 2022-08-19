import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ErrorViewPage extends StatelessWidget {
  ErrorViewPage({super.key, this.message = ""});

  String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("an error occured " + message),
            MaterialButton(
              child: Text("Reload"),
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ],
        ),
      ),
    );
  }
}
