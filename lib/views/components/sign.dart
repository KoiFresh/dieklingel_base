import 'package:flutter/widgets.dart';

class Sign extends StatelessWidget {
  final String name;

  const Sign(this.name, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(name);
  }
}
