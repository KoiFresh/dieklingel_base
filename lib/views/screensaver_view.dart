import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class ScreensaverView extends StatelessWidget {
  const ScreensaverView({
    super.key,
    required this.text,
    required this.width,
    required this.height,
    this.onTap,
  });

  final double width;
  final double height;
  final String text;
  final Function? onTap;

  void _onTap() {
    onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: Container(
        width: width,
        height: height,
        color: Colors.black,
        child: Center(
          child: Html(
            data: """
          <div style='text-align: center; font-size: 56px;'>
          $text
          </div>
          """,
          ),
        ),
      ),
    );
  }
}
