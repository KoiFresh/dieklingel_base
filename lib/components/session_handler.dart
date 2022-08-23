import 'dart:async';

import 'package:flutter/material.dart';

class SessionHandler extends StatefulWidget {
  const SessionHandler({
    Key? key,
    required this.child,
    required this.timeout,
    this.onTimeout,
  }) : super(key: key);

  final Widget child;
  final Duration timeout;
  final Function? onTimeout;

  @override
  State<StatefulWidget> createState() => _SessionHandler();
}

class _SessionHandler extends State<SessionHandler> {
  Timer? sessionTimeout;

  @override
  void initState() {
    super.initState();
  }

  void _onActivityDetected() {
    sessionTimeout?.cancel();
    sessionTimeout = Timer(widget.timeout, _onInactivity);
  }

  void _onInactivity() {
    widget.onTimeout?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _onActivityDetected,
      onPanDown: (DragDownDetails details) => _onActivityDetected(),
      onPanUpdate: (details) => _onActivityDetected(),
      child: widget.child,
    );
  }
}
