import '../components/sign.dart';
import 'package:flutter/widgets.dart';

class SignsView extends StatelessWidget {
  const SignsView({
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
