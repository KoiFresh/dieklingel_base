import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class ScreensaverPage extends StatelessWidget {
  const ScreensaverPage({
    super.key,
    required this.text,
    this.onTap,
  });

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
