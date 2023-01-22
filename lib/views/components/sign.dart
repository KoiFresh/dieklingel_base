import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:dieklingel_base/models/sign_options.dart';
import 'package:flutter/material.dart';
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
  late final AudioPlayer _player = AudioPlayer()
    ..setSourceDeviceFile(widget.options.sound);

  @override
  Widget build(BuildContext context) {
    File lottiefile = File(widget.options.lottie);

    return GestureDetector(
      onTap: () async {
        widget.onTap?.call(widget.options.identifier);
        await _player.stop();
        await _player.resume();
        await _controller.forward(from: 0);
      },
      child: Container(
        color: widget.options.color,
        child: Lottie.file(
          lottiefile,
          controller: _controller,
          onLoaded: (composition) {
            _controller.duration = composition.duration;
          },
        ),
      ),
    );
  }
}
