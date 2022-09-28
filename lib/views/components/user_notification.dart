import 'package:async/async.dart';
import 'package:flutter/material.dart';

class UserNotificationSkeleton {
  final Key key;
  final String title;
  final String body;
  final Duration timeToLive;
  final Duration delay;

  UserNotificationSkeleton({
    required this.key,
    required this.title,
    required this.body,
    required this.timeToLive,
    required this.delay,
  });

  UserNotificationSkeleton.fromJson(Map<String, dynamic> json)
      : key = Key(json['key']),
        title = json['title'],
        body = json['body'],
        timeToLive = Duration(seconds: json['ttl'] as int),
        delay = Duration(seconds: json["delay"] as int);
}

class UserNotification extends StatefulWidget {
  final String title;
  final String body;
  final Duration timeToLive;
  final Duration delay;
  final void Function()? onDismissed;

  UserNotification.fromUserNotificationSkeleton(
    UserNotificationSkeleton skeleton,
    this.onDismissed,
  )   : title = skeleton.title,
        body = skeleton.body,
        timeToLive = skeleton.timeToLive,
        delay = skeleton.delay,
        super(key: skeleton.key);

  const UserNotification({
    required Key key,
    required this.title,
    required this.body,
    this.delay = Duration.zero,
    this.timeToLive = const Duration(seconds: 15),
    this.onDismissed,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _UserNotification();
}

class _UserNotification extends State<UserNotification>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    value: 1,
    duration: const Duration(seconds: 1),
  );
  CancelableOperation? dismissAfterTtl;

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      animateIn();
    });
    if (widget.timeToLive > Duration.zero) {
      dismissAfterTtl = CancelableOperation.fromFuture(
        Future.delayed(
          widget.delay + widget.timeToLive,
          () async {
            await animateOut();
            onDismiss(DismissDirection.up);
          },
        ),
      );
    }
  }

  Widget content(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[850]?.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            widget.title != ""
                ? Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.white60,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  )
                : Container(),
            Text(
              widget.body,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  TickerFuture animateIn() {
    return _controller.reverse();
  }

  TickerFuture animateOut() {
    return _controller.forward();
  }

  TickerFuture setIn(AnimationController controller) {
    return _controller.reverse(from: controller.lowerBound);
  }

  TickerFuture setOut(AnimationController controller) {
    return _controller.forward(from: controller.upperBound);
  }

  void onDismiss(DismissDirection direction) {
    setOut(_controller);
    widget.onDismissed?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(0.0, -1.5),
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Curves.elasticIn,
          ),
        ),
        child: Dismissible(
          direction: DismissDirection.up,
          key: widget.key!,
          child: content(context),
          onDismissed: (direction) {
            onDismiss(direction);
            dismissAfterTtl?.cancel();
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
