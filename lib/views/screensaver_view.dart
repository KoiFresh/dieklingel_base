import 'dart:io';

import 'package:dieklingel_base/bloc/bloc_provider.dart';
import 'package:dieklingel_base/blocs/screensaver_view_bloc.dart';
import 'package:dieklingel_base/messaging/mqtt_client_bloc.dart';
import 'package:dieklingel_base/models/screensaver_options.dart';
import 'package:dieklingel_base/models/sign_options.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:lottie/lottie.dart';

class ScreensaverView extends StatelessWidget {
  const ScreensaverView({super.key});

  Widget _lottie(BuildContext context, String path) {
    File lottiefile = File(path);

    return Lottie.file(lottiefile);
  }

  Widget _html(BuildContext context, String path) {
    File htmlfile = File(path);

    return FutureBuilder(
      future: htmlfile.readAsString(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return Html(
          data: snapshot.data.toString(),
          style: {
            "body": Style(
              padding: EdgeInsets.zero,
              margin: EdgeInsets.zero,
            )
          },
        );
      },
    );
  }

  Widget _image(BuildContext context, String path) {
    return Image.file(
      File(path),
    );
  }

  Widget _text(BuildContext context, String path) {
    return Center(
      child: Text("Missconfigured: $path"),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return GestureDetector(
      onTap: () {
        context
            .bloc<MqttClientBloc>()
            .message
            .add(const MapEntry("display/state", "on"));
      },
      child: StreamBuilder(
        stream: context.bloc<ScreensaverViewBloc>().options,
        builder: (context, AsyncSnapshot<ScreensaverOptions> snapshot) {
          if (!snapshot.hasData || snapshot.data?.type == SignType.none) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          ScreensaverOptions options = snapshot.data!;

          switch (options.type) {
            case SignType.lottie:
              return _lottie(context, options.file);
            case SignType.html:
              return _html(context, options.file);
            case SignType.image:
              return _image(context, options.file);
            default:
              return _text(context, options.file);
          }
        },
      ),
    );
  }
}
