import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class Sign extends StatefulWidget {
  final String name;
  final String hash;
  final double height;
  final Color color;
  final Function(String hash)? onTap;

  const Sign(
    this.name,
    this.hash,
    this.height, {
    Key? key,
    this.color = Colors.amber,
    this.onTap,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _Sign();
}

class _Sign extends State<Sign> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  );
  final AudioCache player = AudioCache(prefix: "resources/");

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        widget.onTap?.call(widget.hash);
        player.play("audio/doorbell.wav");
        await _animationController.forward();
        await _animationController.reverse();
      },
      child: Container(
        width: double.infinity,
        color: widget.color,
        height: widget.height,
        padding: EdgeInsets.all(
          widget.height / 100,
          //MediaQuery.of(context).size.height * widget.height / 100 / 10,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: widget.height / 35,
                  child: RotationTransition(
                    alignment: Alignment.topCenter,
                    turns: Tween(begin: 0.0, end: -0.02)
                        .chain(CurveTween(curve: Curves.elasticIn))
                        .animate(_animationController),
                    child: Image.asset(
                      "resources/images/clapper.png",
                      fit: BoxFit.fitHeight,
                      height: widget.height / 4,
                    ),
                  ),
                ),
                Positioned(
                  child: RotationTransition(
                    alignment: Alignment.topCenter,
                    turns: Tween(begin: 0.0, end: 0.03)
                        .chain(CurveTween(curve: Curves.elasticIn))
                        .animate(_animationController),
                    child: Image.asset(
                      "resources/images/bell.png",
                      fit: BoxFit.fitHeight,
                      height: widget.height / 4,
                    ),
                  ),
                ),
              ],
            ),
            Html(
              data: """
                  <div style='text-align: center; font-size: 56px'>
                  ${widget.name}
                  </div>
                  """,
            ),
          ],
        ),
      ),
    );
  }
}
