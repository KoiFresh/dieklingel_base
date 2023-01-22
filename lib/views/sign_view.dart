import 'dart:io';

import 'package:dieklingel_base/models/sign_options.dart';
import 'package:dieklingel_base/view_models/sign_view_model.dart';
import 'package:dieklingel_base/views/components/sign.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
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

class _SignView extends State<SignView> with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: widget.vm,
      builder: (context, child) => PageView(
        scrollDirection: Axis.vertical,
        children: List.generate(
          context.watch<SignViewModel>().options.length,
          (index) {
            SignOptions option = context.watch<SignViewModel>().options[index];

            return Sign(options: option);
          },
        ),
      ),
    );
  }
}
