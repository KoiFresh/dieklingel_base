import 'package:dieklingel_base/bloc/bloc_provider.dart';
import 'package:dieklingel_base/bloc/stream_event.dart';
import 'package:dieklingel_base/messaging/mqtt_client_bloc.dart';
import 'package:flutter/cupertino.dart';

mixin MqttStateMixin {
  Stream<ActivityState> activityStream(BuildContext context) {
    return context.bloc<MqttClientBloc>().watch("system/activity").map(
      (event) {
        return event.toLowerCase().trim() == "inactive"
            ? InactiveState()
            : ActiveState();
      },
    );
  }

  Stream<DisplayState> displayStream(BuildContext context) {
    return context.bloc<MqttClientBloc>().watch("display/state").map(
      (event) {
        return event.toLowerCase().trim() == "off"
            ? DisplayOffState()
            : DisplayOnState();
      },
    );
  }
}
