import 'package:flutter/cupertino.dart';

import '../components/sign.dart';

class MainPage extends StatelessWidget {
  final List<Sign> signs;

  const MainPage({super.key, required this.signs});
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return ListView.builder(
          itemCount: signs.length,
          itemBuilder: (BuildContext context, int index) {
            return SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              child: signs[index],
            );
          },
        );
      },
    );
  }
}
