import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Sign extends StatelessWidget {
  final String name;
  final int height;
  final Color color;

  const Sign(this.name,
      {Key? key, this.height = 100, this.color = Colors.amber})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        color: color,
        height: MediaQuery.of(context).size.height * height / 100,
        padding: EdgeInsets.all(
            MediaQuery.of(context).size.height * height / 100 / 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Image.asset(
              "assets/images/bell.png",
              fit: BoxFit.fitHeight,
              height: MediaQuery.of(context).size.height * height / 250,
            ),
            Text(
              name,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize:
                      MediaQuery.of(context).size.height * height / 100 / 12),
            ),
          ],
        ));
  }
}
