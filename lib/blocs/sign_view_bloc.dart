import 'dart:async';
import 'dart:convert';

import 'package:dieklingel_base/bloc/bloc.dart';
import 'package:dieklingel_base/blocs/mqtt_channel_constants.dart';
import 'package:dieklingel_base/messaging/mqtt_client_bloc.dart';
import 'package:dieklingel_base/models/sign_options.dart';
import 'package:dieklingel_base/models/sign_payload.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

class SignViewBloc extends Bloc {
  final _mqttblock = GetIt.I.get<MqttClientBloc>();
  final _options = BehaviorSubject<List<SignOptions>>();
  final _click = StreamController<SignOptions>();

  Stream<List<SignOptions>> get options => _options.stream;
  Sink<SignOptions> get onClick => _click.sink;

  SignViewBloc() {
    _options.add(SignOptions.boxx.values.toList());
    SignOptions.boxx.watch().listen((event) {
      _options.add(SignOptions.boxx.values.toList());
    });

    _click.stream.listen(
      (event) {
        // TODO: delete old SignPayloads

        final payloads = SignPayload.boxx.values
            .where((element) => element.identifier == event.identifier)
            .map((e) => e.payload)
            .toList();

        final json = <String, dynamic>{
          "identifier": event.identifier,
          "payload": payloads,
        };

        _mqttblock.message.add(
          MapEntry(
            kIoActionSignClicked,
            jsonEncode(json),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _options.close();
    _click.close();
  }
}
