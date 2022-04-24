import 'package:dieklingel_base/media/media_ressource.dart';
import 'package:dieklingel_base/views/home.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import 'signaling/signaling_client.dart';
import 'signaling/signaling_client_mqtt.dart';
import 'package:flutter/material.dart';

import 'signaling/signaling_message.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Home(), 
      ),
    );
  }
}
