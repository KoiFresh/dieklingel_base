import 'dart:async';

import 'package:dieklingel_base/bloc/bloc.dart';
import 'package:dieklingel_base/models/sign_options.dart';
import 'package:rxdart/rxdart.dart';

class SignViewBloc extends Bloc {
  final _options = BehaviorSubject<List<SignOptions>>();

  Stream<List<SignOptions>> get options => _options.stream;

  SignViewBloc() {
    _options.add(SignOptions.boxx.values.toList());
    SignOptions.boxx.watch().listen((event) {
      _options.add(SignOptions.boxx.values.toList());
    });
  }

  @override
  void dispose() {
    _options.close();
  }
}
