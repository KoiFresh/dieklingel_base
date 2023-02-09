import 'dart:async';

import 'package:dieklingel_base/bloc/stream_event.dart';
import 'package:dieklingel_base/blocs/mqtt_state_mixin.dart';
import 'package:dieklingel_base/messaging/mqtt_client_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '/bloc/bloc_provider.dart';
import 'package:dieklingel_base/blocs/sign_view_bloc.dart';
import 'package:dieklingel_base/models/sign_options.dart';
import 'package:flutter/material.dart';

import 'components/sign.dart';

class SignView extends StatefulWidget {
  const SignView({super.key});

  @override
  State<StatefulWidget> createState() => _SignView();
}

class _SignView extends State<SignView>
    with AutomaticKeepAliveClientMixin, MqttStateMixin {
  final _controller = ScrollController();

  @override
  void initState() {
    activityStream(context).listen((event) {
      print("aa");
    });

    /* Stream<ActivityStreamEvent> stream = context.bloc<SignViewBloc>().activity;
    _subscription = stream.listen((event) {
      if (!event.isActive) {
        _controller.jumpTo(0);
      }
    });*/

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return StreamBuilder(
      stream: context.bloc<SignViewBloc>().options,
      builder: (
        BuildContext context,
        AsyncSnapshot<List<SignOptions>> snapshot,
      ) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        List<SignOptions> options = snapshot.data!;

        return ListView.builder(
          controller: _controller,
          itemCount: options.length,
          itemBuilder: (BuildContext context, int index) {
            return Sign(
              options: options[index],
              onTap: (hash) {
                context.bloc<SignViewBloc>().click.add(options[index]);
              },
            );
          },
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    super.dispose();
  }
}
