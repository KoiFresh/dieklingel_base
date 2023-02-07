import 'package:dieklingel_base/bloc/bloc_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../blocs/app_view_bloc.dart';
import '../touch_scroll_behavior.dart';
import '../view_models/home_view_model.dart';
import 'home_view.dart';

class MyApp extends StatefulWidget {
  final Map<String, dynamic> config;

  const MyApp({super.key, this.config = const {}});

  @override
  State<MyApp> createState() => _MyApp();
}

class _MyApp extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: context.bloc<AppViewBloc>().clip,
      builder: (
        BuildContext context,
        AsyncSnapshot<EdgeInsets> snapshot,
      ) {
        return Container(
          color: Colors.black,
          padding: snapshot.data,
          child: ClipRRect(
            clipBehavior: Clip.antiAliasWithSaveLayer,
            borderRadius: BorderRadius.circular(20),
            child: CupertinoApp(
              scrollBehavior: TouchScrollBehavior(),
              home: HomeView(
                vm: HomeViewModel(),
                config: widget.config,
              ),
            ),
          ),
        );
      },
    );
  }
}
