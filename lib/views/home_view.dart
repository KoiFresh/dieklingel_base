import 'package:flutter/cupertino.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<StatefulWidget> createState() => _HomeView();
}

class _HomeView extends State {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("home"),
    );
  }
}
