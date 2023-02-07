import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:flutter/painting.dart';

import '../bloc/bloc.dart';

class AppBloc extends Bloc {
  final _clip = BehaviorSubject<EdgeInsets>();

  Stream<EdgeInsets> get clip => _clip.stream;

  AppBloc() {
    // TODO: listen to hive settings box
  }

  @override
  void dispose() {
    _clip.close();
  }
}
