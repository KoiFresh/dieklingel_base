import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PasscodeButton extends StatefulWidget {
  final String text;
  final void Function(String text)? onTapped;

  const PasscodeButton({
    super.key,
    required this.text,
    this.onTapped,
  });

  @override
  State<PasscodeButton> createState() => _PasscodeButton();
}

class _PasscodeButton extends State<PasscodeButton> {
  bool _isTapped = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) => setState(() {
        _isTapped = true;
      }),
      onTapUp: (details) {
        Future.delayed(const Duration(milliseconds: 100), () {
          setState(() {
            _isTapped = false;
          });
        });
      },
      onTap: () {
        widget.onTapped?.call(widget.text);
      },
      child: Container(
        width: kMinInteractiveDimensionCupertino * 2,
        height: kMinInteractiveDimensionCupertino * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey.withOpacity(_isTapped ? 0.1 : 0.2),
        ),
        child: Center(
          child: Text(
            widget.text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
            ),
          ),
        ),
      ),
    );
  }
}
