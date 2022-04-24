import 'package:dieklingel_base/signaling/signaling_client.dart';
import 'package:dieklingel_base/signaling/signaling_client_mqtt.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _Home();
}

class _Home extends State<Home> {
  final SignalingClient _signalingClient = SignalingClientMqtt(); 

  @override
  void initState() {
    _signalingClient.connect("dieklingel.com");
    _signalingClient.addEventListener("broadcast", (data) => {
      print(data)
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return const Text("Hallo Welt");
  }
}
