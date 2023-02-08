import 'package:dieklingel_base/bloc/bloc_provider.dart';
import 'package:dieklingel_base/messaging/mqtt_client_bloc.dart';
import 'package:flutter/cupertino.dart';

class ScreensaverView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return GestureDetector(
      onTap: () {
        context
            .bloc<MqttClientBloc>()
            .message
            .add(const MapEntry("display/state", "on"));
      },
      child: Center(
        child: Text("Screensaver"),
      ),
    );
  }
}
