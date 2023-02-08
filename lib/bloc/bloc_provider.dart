import 'package:flutter/cupertino.dart';
import 'package:provider/single_child_widget.dart';

import 'bloc.dart';

class BlocProvider<T extends Bloc> extends SingleChildStatefulWidget {
  final T bloc;

  const BlocProvider({
    required this.bloc,
    super.child,
    super.key,
  });

  static T of<T extends Bloc>(BuildContext context) {
    final BlocProvider<T> provider = context.findAncestorWidgetOfExactType()!;
    return provider.bloc;
  }

  @override
  State<StatefulWidget> createState() => _BlocProvider();
}

class _BlocProvider extends SingleChildState<BlocProvider> {
  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return child ?? Container();
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
