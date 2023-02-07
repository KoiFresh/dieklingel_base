import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:dieklingel_base/models/sign_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:lottie/lottie.dart';

class Sign extends StatefulWidget {
  final SignOptions options;
  final Function(String hash)? onTap;

  const Sign({
    required this.options,
    this.onTap,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _Sign();
}

class _Sign extends State<Sign> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this);
  // use same player id, to only play one sound at a time
  final AudioPlayer _player = AudioPlayer(playerId: "dieklingel");
  late bool _hasSound = false;

  @override
  void initState() {
    init();
    super.initState();
  }

  void init() async {
    if ((widget.options.sound?.isNotEmpty ?? false)) {
      // should use audio
      File sound = File(widget.options.sound!);
      bool exists = await sound.exists();
      if (!exists) {
        stdout.writeln(
          "File ${sound.path} does not exists on Sign ${widget.options.identifier}",
        );
      } else {
        _hasSound = true;
        await _player.setSourceDeviceFile(widget.options.sound!);
      }
    }
  }

  Widget _lottie(BuildContext context) {
    File lottiefile = File(widget.options.file);

    return Lottie.file(
      lottiefile,
      controller: _controller,
      onLoaded: (composition) {
        _controller.duration = composition.duration;
      },
    );
  }

  Widget _html(BuildContext context) {
    File htmlfile = File(widget.options.file);

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

  Widget _image(BuildContext context) {
    return Image.file(
      File(widget.options.file),
    );
  }

  Widget _text(BuildContext context) {
    return Center(
      child: Text("Missconfigured: ${widget.options.identifier}"),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget child;

    switch (widget.options.type) {
      case SignType.lottie:
        child = _lottie(context);
        break;
      case SignType.html:
        child = _html(context);
        break;
      case SignType.image:
        child = _image(context);
        break;
      default:
        child = _text(context);
        break;
    }

    return GestureDetector(
      onTap: () async {
        widget.onTap?.call(widget.options.identifier);
        if (_hasSound) {
          await _player.setVolume(1.0);
          await _player.stop();
          await _player.resume();
        }
        if (widget.options.type == SignType.lottie) {
          await _controller.forward(from: 0);
        }
      },
      child: Container(
        color: Colors.black,
        child: child,
      ),
    );
  }
}
