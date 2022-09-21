import 'package:dieklingel_base/views/components/animation_player.dart';
import 'package:flutter/material.dart';

class UserNotification extends StatelessWidget {
  final String title;
  final String body;
  final bool enabled;
  final Function()? onDismissed;

  const UserNotification(
      {Key? key,
      this.title = "Hallo",
      this.body = "Welt",
      required this.enabled,
      this.onDismissed})
      : super(key: key);

  Widget content(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            Text(
              body,
              style: const TextStyle(
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: AnimationPlayer(
        create: ((stateMixin) => AnimationController(
              vsync: stateMixin,
              duration: Duration(seconds: 1),
              reverseDuration: Duration(seconds: 1),
            )),
        controller: (controller) {
          if (enabled) {
            controller.reverse();
          } else {
            controller.forward();
          }
          return SlideTransition(
            position: Tween<Offset>(
              begin: Offset.zero,
              end: const Offset(0.0, -1.5),
            ).animate(
              CurvedAnimation(
                parent: controller,
                curve: Curves.elasticIn,
              ),
            ),
            child: Dismissible(
              direction: DismissDirection.up,
              key: UniqueKey(),
              child: content(context),
              onDismissed: (DismissDirection direction) {
                controller.forward(from: controller.upperBound);
                onDismissed?.call();
              },
            ),
          );
        },
      ),
    );
  }
}
