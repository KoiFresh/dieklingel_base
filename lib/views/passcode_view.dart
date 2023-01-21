import 'package:flutter/cupertino.dart';

class PasscodeView extends StatefulWidget {
  const PasscodeView({super.key});

  @override
  State<StatefulWidget> createState() => _PasscodeView();
}

class _PasscodeView extends State<PasscodeView> {
  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      child: Center(
        child: Text(
            "Passcode is currently disabled, cause we are performing some major updates"),
      ),
    );
  }
}
