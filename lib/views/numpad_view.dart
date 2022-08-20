import 'dart:math';
import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

class Numpad extends StatefulWidget {
  const Numpad({
    super.key,
    required this.width,
    required this.height,
    this.onPasscodeChanged,
    this.onUnlock,
    this.onLongUnlock,
    this.randomizePasscodeAfterUnlock = true,
    this.textStyle,
    this.selectedTextStyle,
  });
  final double width;
  final double height;
  final bool randomizePasscodeAfterUnlock;
  final Function(String passcode)? onPasscodeChanged;
  final Function(String passcode)? onUnlock;
  final Function(String passcode)? onLongUnlock;
  final TextStyle? textStyle;
  final TextStyle? selectedTextStyle;

  @override
  State<Numpad> createState() => _Numpad();
}

class _Numpad extends State<Numpad> {
  List<int> _passcode = List.filled(6, 0);

  @override
  void initState() {
    Future(() {
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
                onLongPress: () {
                  widget.onLongUnlock?.call(passcode);
                },
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
