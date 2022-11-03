import 'package:flutter/material.dart';

class PasscodeIndicator extends StatelessWidget {
  final int itemCount;
  final int maxItems;

  const PasscodeIndicator({
    super.key,
    required this.itemCount,
    required this.maxItems,
  });

  Color _color() {
    return Colors.grey.shade300;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        maxItems,
        (index) {
          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: index < itemCount ? _color() : null,
                border: Border.all(color: _color()),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          );
        },
      ),
    );
  }
}
