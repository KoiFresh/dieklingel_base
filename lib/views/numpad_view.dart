import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

class NumpadView extends StatefulWidget {
  const NumpadView({
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
  State<NumpadView> createState() => _NumpadView();
}

class _NumpadView extends State<NumpadView> {
  List<int> _passcode = List.filled(6, 0);

  @override
  void initState() {
    Future.delayed(const Duration(milliseconds: 500), () {
      _randomize();
    });
    super.initState();
  }

  String get passcode {
    return _passcode.join();
  }

  void _randomize() {
    Random random = Random();
    List<int> randomized = List.generate(
      _passcode.length,
      ((index) => random.nextInt(10)),
    );
    setState(() {
      _passcode = randomized;
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
