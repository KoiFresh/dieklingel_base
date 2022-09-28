import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:dieklingel_base/extensions/byte64_converter_xfile.dart';
import 'package:dieklingel_base/media/media_ressource.dart';
import 'package:dieklingel_base/views/awake_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'components/sign.dart';
import 'components/user_notification.dart';
import 'screensaver_view.dart';
import '../components/app_settings.dart';
import '../globals.dart' as app;
import '../messaging/messaging_client.dart';
import '../rtc/rtc_clients_model.dart';
import '../signaling/signaling_client.dart';

class HomeViewPage extends StatefulWidget {
  const HomeViewPage({Key? key, required this.config}) : super(key: key);

  final Map<String, dynamic> config;

  @override
  State<HomeViewPage> createState() => _HomeViewPage();
}

class _HomeViewPage extends State<HomeViewPage> {
  late final Map<String, dynamic> config = widget.config;
  final List<UserNotificationSkeleton> userNotifications = [];

  bool notifyEnabled = true;

  MessagingClient get messagingClient {
    return Provider.of<MessagingClient>(context, listen: false);
  }

  SignalingClient get signalingClient {
    return Provider.of<SignalingClient>(context, listen: false);
  }

  RtcClientsModel get rtcClientsModel {
    return Provider.of<RtcClientsModel>(context, listen: false);
  }

  AppSettings get appSettings {
    return Provider.of<AppSettings>(context, listen: false);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        initialize();
      },
    );
  }

  void initialize() {
    context.read<MessagingClient>().messageController.stream.listen(
      (event) {
        String prefix = context.read<MessagingClient>().prefix;
        if (event.topic != "${prefix}io/user/notification") return;
        Map<String, dynamic> payload = {};
        try {
          payload = jsonDecode(event.message);
        } catch (exception) {
          payload["body"] = event.message;
        }
        payload["key"] = UniqueKey().toString();
        payload["title"] ??= "";
        payload["body"] ??= "www.dieklingel.com";
        payload["ttl"] ??= 15;
        payload["delay"] ??= 0;
        appSettings.log("User Notification Received");
        setState(
          () {
            userNotifications.add(UserNotificationSkeleton.fromJson(payload));
          },
        );
      },
    );
  }

  void _onSignTap(String hash) async {
    if (context.read<MessagingClient>().isConnected()) {
      context.read<MessagingClient>().send("io/action/sign/hash", hash);
    }
    appSettings.log("The Sign with hash '$hash' was tapped");
    List<String>? tokens = app.preferences.getStringList("sign/$hash");
    if (null == tokens) {
      appSettings.log("The Sign '$hash' has no tokens");
      return;
    }
    String snapshot = "";
    if (config["notification"]["snapshot"] == true) {
      XFile image = await MediaRessource.getSnapshot();
      snapshot = await image.asB64String(data: "image/png");
      if (mounted) {
        context.read<AppSettings>().snapshot.setValueAndForceNotify(snapshot);
      }
    }
    Map<String, dynamic> message = {
      "tokens": tokens,
      "title": "Jemand steht vor deiner Tuer",
      "body": "https://dieklingel.com/",
      "image": snapshot,
    };
    if (messagingClient.isConnected()) {
      // TODO: change notification channel
      messagingClient.send(
        "firebase/notification/send",
        jsonEncode(message),
      );
    }
    appSettings.log("A Notification for the Sign '$hash' was send");
  }

  void _onScreensaverTap() {
    appSettings.displayIsActive.value = true;
  }

  @override
  Widget build(BuildContext context) {
    final double clipLeft = config["viewport"]["clip"]["left"] ?? 0.0;
    final double clipTop = config["viewport"]["clip"]["top"] ?? 0.0;
    final double clipRight = config["viewport"]["clip"]["right"] ?? 0.0;
    final double clipBottom = config["viewport"]["clip"]["bottom"] ?? 0.0;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double width = screenWidth - clipLeft - clipRight;
    final double height = screenHeight - clipTop - clipBottom;

    List<Sign> signs = (config["signs"] as List<dynamic>).map(
      (element) {
        return Sign(
          element["text"],
          element["hash"],
          height,
          onTap: _onSignTap,
        );
      },
    ).toList();

    return Scaffold(
      body: Stack(
        children: [
          context.watch<AppSettings>().displayIsActive.value
              ? AwakeView(
                  width: width,
                  height: height,
                  signs: signs,
                )
              : ScreensaverView(
                  text: config["viewport"]?["screensaver"]?["text"] ?? "",
                  width: width,
                  height: height,
                  onTap: _onScreensaverTap,
                ),
          Stack(
            children: List.generate(
              userNotifications.length,
              (index) {
                return UserNotification.fromUserNotificationSkeleton(
                  userNotifications[index],
                  () {
                    setState(
                      () {
                        userNotifications.removeAt(index);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    messagingClient.disconnect();
  }
}
