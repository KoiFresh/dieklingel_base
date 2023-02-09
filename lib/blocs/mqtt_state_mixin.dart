import 'dart:async';

import 'package:dieklingel_base/bloc/stream_event.dart';
import 'package:dieklingel_base/messaging/mqtt_client_bloc.dart';
import 'package:get_it/get_it.dart';

mixin MqttStateMixin {
  Stream<ActivityState> get activity {
    return GetIt.I.get<MqttClientBloc>().watch("system/activity").map(
      (event) {
        return event.toLowerCase().trim() == "inactive"
            ? InactiveState()
            : ActiveState();
      },
    );
  }

  Stream<DisplayState> get display {
    return GetIt.I.get<MqttClientBloc>().watch("display/state").map(
      (event) {
        return event.toLowerCase().trim() == "off"
            ? DisplayOffState()
            : DisplayOnState();
      },
    );
  }
}
