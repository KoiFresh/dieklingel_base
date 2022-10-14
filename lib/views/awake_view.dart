import 'dart:convert';

import 'package:dieklingel_base/event/event_monitor.dart';
import 'package:dieklingel_base/event/system_event.dart';
import 'package:dieklingel_base/event/system_event_type.dart';
import 'package:dieklingel_base/messaging/mclient_topic_message.dart';
import 'package:mqtt_client/mqtt_client.dart';

import '../components/app_settings.dart';
import '../messaging/mclient.dart';
import '../views/components/sign.dart';
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

    SystemEvent unlockEvent = SystemEvent(
      type: SystemEventType.text,
      payload: "Someone enterd a passcode.",
    );
    context.read<EventMonitor>().add(unlockEvent);

    String passcodeHash = sha2562.convert(utf8.encode(passcode)).toString();
    if (context.read<MClient>().connectionState !=
        MqttConnectionState.connected) return;
    MClientTopicMessage message = MClientTopicMessage(
      topic: "io/action/unlock/passcode",
      message: passcodeHash,
    );
    context.read<MClient>().publish(message);
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
