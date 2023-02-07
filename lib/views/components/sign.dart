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

  late final bool _isLottie;
  late final bool _isHtml;
  late final bool _hasSound;

  @override
  void initState() {
    super.initState();

    _isLottie = widget.options.lottie.isNotEmpty;
    _isHtml = !_isLottie && widget.options.html.isNotEmpty;
    _hasSound = widget.options.sound.isNotEmpty;

    if (_hasSound) {
      Future(() async {
        await _player.setReleaseMode(ReleaseMode.stop);
        await _player.setSourceDeviceFile(widget.options.sound);
      });
    }
  }

  Widget _lottie(BuildContext context) {
    File lottiefile = File(widget.options.lottie);

    return Lottie.file(
      lottiefile,
      controller: _controller,
      onLoaded: (composition) {
        _controller.duration = composition.duration;
      },
    );
  }

  Widget _html(BuildContext context) {
    File htmlfile = File(widget.options.html);

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

  Widget _text(BuildContext context) {
    return Center(
      child: Text(widget.options.identifier),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        widget.onTap?.call(widget.options.identifier);
        if (_hasSound) {
          await _player.stop();
          await _player.resume();
          //await _player.play(DeviceFileSource(widget.options.sound));
        }
        if (_isLottie) {
          await _controller.forward(from: 0);
        }
      },
      child: Container(
        color: Colors.red, //widget.options.color,
        child: _isLottie
            ? _lottie(context)
            : _isHtml
                ? _html(context)
                : _text(context),
      ),
    );
  }
}
