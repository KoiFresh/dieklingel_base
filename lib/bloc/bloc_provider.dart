import 'package:flutter/cupertino.dart';

import 'bloc.dart';

class BlocProvider<T extends Bloc> extends StatefulWidget {
  final Widget child;
  final T bloc;

  const BlocProvider({
    required this.bloc,
    required this.child,
    super.key,
  });

  static T of<T extends Bloc>(BuildContext context) {
    final BlocProvider<T> provider = context.findAncestorWidgetOfExactType()!;
    return provider.bloc;
  }

  @override
  State<StatefulWidget> createState() => _BlocProvider();
}

class _BlocProvider extends State<BlocProvider> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void dispose() {
    widget.bloc.dispose();
    super.dispose();
  }
}

extension GetBloc on BuildContext {
  T bloc<T extends Bloc>() {
    return BlocProvider.of<T>(this);
  }
}
