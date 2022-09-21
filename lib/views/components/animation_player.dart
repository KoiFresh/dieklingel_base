import 'package:flutter/material.dart';

class AnimationPlayer extends StatefulWidget {
  final Widget Function(
    AnimationController controller,
  ) controller;

  final AnimationController Function(
    SingleTickerProviderStateMixin stateMixin,
  ) create;

  const AnimationPlayer(
      {Key? key, required this.create, required this.controller})
      : super(key: key);

  @override
  State<AnimationPlayer> createState() => _AnimationPlayer();
}

class _AnimationPlayer extends State<AnimationPlayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller = widget.create(this);

  @override
  Widget build(BuildContext context) {
    return widget.controller(controller);
  }
}
