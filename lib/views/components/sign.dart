import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class Sign extends StatefulWidget {
  final String name;
  final int height;
  final Color color;

  const Sign(this.name,
      {Key? key, this.height = 100, this.color = Colors.amber})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _Sign();
}

class _Sign extends State<Sign> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  );
  final AudioCache player = AudioCache();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        player.play("audio/doorbell.wav");
        await _animationController.forward();
        await _animationController.reverse();
      },
      child: Container(
        width: double.infinity,
        color: widget.color,
        height: MediaQuery.of(context).size.height * widget.height / 100,
        padding: EdgeInsets.all(
          MediaQuery.of(context).size.height * widget.height / 100 / 10,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: 24,
                  child: RotationTransition(
                    alignment: Alignment.topCenter,
                    turns: Tween(begin: 0.0, end: -0.02)
                        .chain(CurveTween(curve: Curves.elasticIn))
                        .animate(_animationController),
                    child: Image.asset(
                      "assets/images/clapper.png",
                      fit: BoxFit.fitHeight,
                      height: MediaQuery.of(context).size.height *
                          widget.height /
                          100 /
                          4,
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
                      "assets/images/bell.png",
                      fit: BoxFit.fitHeight,
                      height: MediaQuery.of(context).size.height *
                          widget.height /
                          100 /
                          4,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              widget.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.height *
                    widget.height /
                    100 /
                    12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
