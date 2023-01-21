import 'package:dieklingel_base/view_models/sign_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignView extends StatefulWidget {
  final SignViewModel vm;
  final Map<String, dynamic> config;

  SignView({
    required this.vm,
    this.config = const {},
    super.key,
  }) {
    vm.init(config: config);
  }

  @override
  State<StatefulWidget> createState() => _SignView();
}

class _SignView extends State<SignView> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: widget.vm,
      builder: (context, child) => PageView(
        scrollDirection: Axis.vertical,
        children: context.watch<SignViewModel>().signs,
      ),
    );
  }
}
