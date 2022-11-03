//import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class Sign extends StatefulWidget {
  final String name;
  final String hash;
  final Color color;
  final Function(String hash)? onTap;

  const Sign(
    this.name,
    this.hash, {
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
  //final AudioCache cache = AudioCache(prefix: "resources/");
  final AudioPlayer player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    //player.audioCache = cache;
    player.setSourceAsset("audio/doorbell.wav");
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        widget.onTap?.call(widget.hash);
        await player.stop();
        await player.resume();
        await _animationController.forward();
        await _animationController.reverse();
      },
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Container(
            color: widget.color,
            padding: EdgeInsets.all(
              constraints.maxWidth / 100,
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
                      top: constraints.maxHeight / 35,
                      child: RotationTransition(
                        alignment: Alignment.topCenter,
                        turns: Tween(begin: 0.0, end: -0.02)
                            .chain(CurveTween(curve: Curves.elasticIn))
                            .animate(_animationController),
                        child: Image.asset(
                          "images/clapper.png",
                          fit: BoxFit.fitHeight,
                          height: constraints.maxHeight / 4,
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
                          "images/bell.png",
                          fit: BoxFit.fitHeight,
                          height: constraints.maxHeight / 4,
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
          );
        },
      ),
    );
  }
}
