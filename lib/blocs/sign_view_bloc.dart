import 'dart:async';

import 'package:dieklingel_base/bloc/bloc.dart';
import 'package:dieklingel_base/models/sign_options.dart';
import 'package:rxdart/rxdart.dart';

class SignViewBloc extends Bloc {
  final _options = BehaviorSubject<List<SignOptions>>();
  final _click = StreamController<SignOptions>();

  Stream<List<SignOptions>> get options => _options.stream;
  Sink<SignOptions> get click => _click.sink;

  SignViewBloc() {
    _options.add(SignOptions.boxx.values.toList());
    SignOptions.boxx.watch().listen((event) {
      _options.add(SignOptions.boxx.values.toList());
    });

    _click.stream.listen((event) {
      print("sign clicked: ${event.identifier}");
    });
  }

  @override
  void dispose() {
    _options.close();
    _click.close();
  }
}
