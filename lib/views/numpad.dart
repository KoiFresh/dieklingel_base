import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

class Numpad extends StatefulWidget {
  const Numpad({
    super.key,
    required this.width,
    required this.height,
    this.onPasscodeChanged,
    this.onUnlock,
    this.randomizePasscodeAfterUnlock = true,
    this.textStyle,
    this.selectedTextStyle,
  });
  final double width;
  final double height;
  final bool randomizePasscodeAfterUnlock;
  final Function(String passcode)? onPasscodeChanged;
  final Function(String passcode)? onUnlock;
  final TextStyle? textStyle;
  final TextStyle? selectedTextStyle;

  @override
  State<Numpad> createState() => _Numpad();
}

class _Numpad extends State<Numpad> {
  final List<int> _passcode = List.generate(6, (index) => Random().nextInt(10));

  String get passcode {
    return _passcode.join();
  }

  void _randomize() {
    Random random = Random();
    setState(() {
      for (int i = 0; i < _passcode.length; i++) {
        _passcode[i] = random.nextInt(10);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: List.generate(_passcode.length, (index) {
            return NumberPicker(
              textStyle: widget.textStyle,
              selectedTextStyle: widget.selectedTextStyle,
              itemCount: 5,
              minValue: 0,
              maxValue: 9,
              value: _passcode[index],
              itemWidth: widget.width / _passcode.length,
              infiniteLoop: true,
              onChanged: (value) {
                setState(() {
                  _passcode[index] = value;
                  widget.onPasscodeChanged?.call(passcode);
                });
              },
            );
          }),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: EdgeInsets.only(right: widget.width / 10),
              child: MaterialButton(
                onPressed: (() {
                  widget.onUnlock?.call(passcode);
                  if (widget.randomizePasscodeAfterUnlock) {
                    _randomize();
                  }
                }),
                child: const Icon(
                  Icons.vpn_key_rounded,
                  size: 32,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}
