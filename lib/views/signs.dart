import 'package:dieklingel_base/views/components/sign.dart';
import 'package:flutter/widgets.dart';

class Signs extends StatelessWidget {
  const Signs({
    super.key,
    required this.signs,
  });

  final List<Sign> signs;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: signs,
    );
  }
}
