import 'dart:convert';

import 'package:dieklingel_base/components/app_settings.dart';
import 'package:dieklingel_base/messaging/messaging_client.dart';
import 'package:dieklingel_base/views/components/sign.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../crypto/sha2562.dart';
import 'menue_view_page.dart';
import 'numpad_view.dart';
import 'signs_view.dart';

class AwakeView extends StatelessWidget {
  final double width;
  final double height;
  final List<Sign> signs;

  const AwakeView({
    Key? key,
    required this.width,
    required this.height,
    required this.signs,
  }) : super(key: key);

  void _onUnlock(BuildContext context, String passcode) {
    context.read<AppSettings>().log("The unlock button was tapped");
    String passcodeHash = sha2562.convert(utf8.encode(passcode)).toString();
    if (!context.read<MessagingClient>().isConnected()) return;
    context.read<MessagingClient>().send(
          "io/action/unlock/passcode",
          passcodeHash,
        );
  }

  @override
  Widget build(BuildContext context) {
    double width = this.width - 0.5;
    return PageView(
      controller: PageController(
        viewportFraction: 0.99999, // preload next page
      ),
      children: [
        SizedBox(
          width: width,
          child: Signs(signs: signs),
        ),
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment(0.8, 1),
              colors: <Color>[
                Color(0xff1f005c),
                Color(0xff5b0060),
                Color(0xff870160),
                Color(0xffac255e),
                Color(0xffca485c),
                Color(0xffe16b5c),
                Color(0xfff39060),
                Color(0xffffb56b),
              ], // Gradient from https://learnui.design/tools/gradient-generator.html
              tileMode: TileMode.mirror,
            ),
          ),
          child: Numpad(
            width: width,
            height: height,
            textStyle: const TextStyle(color: Colors.white),
            onUnlock: (passcode) => _onUnlock(context, passcode),
            onLongUnlock: (passcode) {
              if (passcode != "000000") return;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: ((context) => const MenueViewPage()),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
