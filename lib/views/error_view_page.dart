import 'package:flutter/material.dart';

class ErrorViewPage extends StatelessWidget {
  const ErrorViewPage({super.key, this.message = ""});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("an error occured $message"),
            MaterialButton(
              child: const Text("Reload"),
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
