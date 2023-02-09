import 'dart:async';

import 'package:dieklingel_base/bloc/stream_event.dart';
import 'package:dieklingel_base/blocs/mqtt_channel_constants.dart';
import 'package:dieklingel_base/messaging/mqtt_client_bloc.dart';
import 'package:get_it/get_it.dart';

mixin MqttStateMixin {
  Stream<ActivityState> get activity {
    return GetIt.I<MqttClientBloc>().watch(kIoActivityState).map(
      (event) {
        return event.toLowerCase().trim() == "inactive"
            ? InactiveState()
            : ActiveState();
      },
    );
  }

  Stream<DisplayState> get display {
    return GetIt.I<MqttClientBloc>().watch(kIoDisplayState).map(
      (event) {
        return event.toLowerCase().trim() == "off"
            ? DisplayOffState()
            : DisplayOnState();
      },
    );
  }
}
