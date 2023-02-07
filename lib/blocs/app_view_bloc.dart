import 'dart:async';

import 'package:hive/hive.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter/painting.dart';

import '../bloc/bloc.dart';

class AppViewBloc extends Bloc {
  final _clip = BehaviorSubject<EdgeInsets>();

  Stream<EdgeInsets> get clip => _clip.stream;

  AppViewBloc() {
    Box settings = Hive.box("settings");

    _clip.add(EdgeInsets.fromLTRB(
      settings.get("viewport.clip.left", defaultValue: 0.0),
      settings.get("viewport.clip.top", defaultValue: 0.0),
      settings.get("viewport.clip.right", defaultValue: 0.0),
      settings.get("viewport.clip.bottom", defaultValue: 0.0),
    ));

    settings.watch(key: "viewport.clip.left").listen((event) {
      EdgeInsets insets = _clip.value.copyWith(left: event.value);
      _clip.add(insets);
    });
    settings.watch(key: "viewport.clip.top").listen((event) {
      EdgeInsets insets = _clip.value.copyWith(top: event.value);
      _clip.add(insets);
    });
    settings.watch(key: "viewport.clip.right").listen((event) {
      EdgeInsets insets = _clip.value.copyWith(right: event.value);
      _clip.add(insets);
    });
    settings.watch(key: "viewport.clip.bottom").listen((event) {
      EdgeInsets insets = _clip.value.copyWith(bottom: event.value);
      _clip.add(insets);
    });
  }

  @override
  void dispose() {
    _clip.close();
  }
}
