import 'package:dieklingel_base/messaging/mqtt_client_bloc.dart';
import 'package:get_it/get_it.dart';

import '../bloc/bloc.dart';

class RtcClientBloc extends Bloc {
  RtcClientBloc() {
    MqttClientBloc mqttbloc = GetIt.I<MqttClientBloc>();
  }

  @override
  void dispose() {
    // TODO: implement dispose
  }
}
