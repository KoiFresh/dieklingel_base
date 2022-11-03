import 'package:dieklingel_base/views/home/passcode/passcode_button.dart';
import 'package:dieklingel_base/views/home/passcode/passcode_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PasscodePage extends StatefulWidget {
  const PasscodePage({super.key});

  @override
  State<PasscodePage> createState() => _PasscodePage();
}

class _PasscodePage extends State<PasscodePage> {
  final int _passcodeLength = 6;
  String _numbers = "1234567890";
  String _passcode = "";

  @override
  void initState() {
    _numbers = String.fromCharCodes(_numbers.runes.toList()..shuffle());
    super.initState();
  }

  void _onPasscodeBtnTapped(String text) {
    setState(() {
      _passcode += text;
    });

    if (_passcode.length == _passcodeLength) {
      // TODO: send passcode over mqtt
      Future.delayed(const Duration(milliseconds: 200), () {
        setState(() {
          _passcode = "";
          _numbers = String.fromCharCodes(_numbers.runes.toList()..shuffle());
        });
      });
    }
  }

  void _onRemoveBtnTapped() {
    setState(() {
      _passcode = _passcode.substring(0, _passcode.length - 1);
    });
  }

  Widget _numpad(BuildContext context) {
    return SizedBox(
      width: 304,
      height: 412,
      child: GridView.count(
        crossAxisCount: 3,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        children: [
          PasscodeButton(
            text: _numbers[0],
            onTapped: _onPasscodeBtnTapped,
          ),
          PasscodeButton(
            text: _numbers[1],
            onTapped: _onPasscodeBtnTapped,
          ),
          PasscodeButton(
            text: _numbers[2],
            onTapped: _onPasscodeBtnTapped,
          ),
          PasscodeButton(
            text: _numbers[3],
            onTapped: _onPasscodeBtnTapped,
          ),
          PasscodeButton(
            text: _numbers[4],
            onTapped: _onPasscodeBtnTapped,
          ),
          PasscodeButton(
            text: _numbers[5],
            onTapped: _onPasscodeBtnTapped,
          ),
          PasscodeButton(
            text: _numbers[6],
            onTapped: _onPasscodeBtnTapped,
          ),
          PasscodeButton(
            text: _numbers[7],
            onTapped: _onPasscodeBtnTapped,
          ),
          PasscodeButton(
            text: _numbers[8],
            onTapped: _onPasscodeBtnTapped,
          ),
          Container(),
          PasscodeButton(
            text: _numbers[9],
            onTapped: _onPasscodeBtnTapped,
          ),
          CupertinoButton(
            onPressed: _passcode.isEmpty ? null : _onRemoveBtnTapped,
            child: Text(
              "remove",
              style: TextStyle(
                color: _passcode.isEmpty ? Colors.grey : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dots(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        PasscodeIndicator(itemCount: _passcode.length, maxItems: 6),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment(0.8, 1),
            colors: <Color>[
              Color(0xff060606),
              Color(0xff2a2a2a),
              Color(0xff4c4c4c),
              Color(0xff717171),
            ], // Gradient from https://learnui.design/tools/gradient-generator.html
            tileMode: TileMode.mirror,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                bottom: kMinInteractiveDimensionCupertino * 3,
              ),
              child: _dots(context),
            ),
            _numpad(context),
          ],
        ),
      ),
    );
  }
}
