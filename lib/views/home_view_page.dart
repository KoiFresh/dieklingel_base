import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:dieklingel_base/event/event_monitor.dart';
import 'package:dieklingel_base/event/system_event.dart';
import 'package:dieklingel_base/event/system_event_type.dart';
import 'package:dieklingel_base/messaging/mclient_topic_message.dart';
import 'package:mqtt_client/mqtt_client.dart';
import '../extensions/byte64_converter_xfile.dart';
import '../media/media_ressource.dart';
import '../messaging/mclient.dart';
import 'awake_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'components/sign.dart';
import 'components/user_notification.dart';
import 'screensaver_view.dart';
import '../components/app_settings.dart';
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

  MClient get messagingClient {
    return Provider.of<MClient>(context, listen: false);
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
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => initialize());
  }

  void initialize() {
    context.read<MClient>().subscribe("io/user/notification", (event) {
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
      SystemEvent systemEvent = SystemEvent(
        type: SystemEventType.notification,
        payload: event.message,
      );
      context.read<EventMonitor>().add(systemEvent);
    });
  }

  void _onSignTap(String hash) async {
    SystemEvent signClickedEvent = SystemEvent(
      type: SystemEventType.text,
      payload: "The Sign with the hash '$hash' has been clicked.",
    );
    context.read<EventMonitor>().add(signClickedEvent);

    MClient mClient = context.read<MClient>();
    if (mClient.connectionState == MqttConnectionState.connected) {
      MClientTopicMessage message = MClientTopicMessage(
        topic: "io/action/sign/hash",
        message: hash,
      );
      mClient.publish(message);
    }
    appSettings.log("The Sign with hash '$hash' was tapped");
    List<String>? tokens = context.read<AppSettings>().signHashs[hash];
    if (null == tokens) {
      appSettings.log("The Sign '$hash' has no tokens");
      // return;
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
    if (!mounted) return;
    context.read<EventMonitor>().add(
          SystemEvent(
            type: SystemEventType.image,
            payload: snapshot,
          ),
        );
    if (messagingClient.connectionState == MqttConnectionState.connected) {
      // TODO: change notification channel
      MClientTopicMessage fcmMessage = MClientTopicMessage(
        topic: "firebase/notification/send",
        message: jsonEncode(message),
      );
      messagingClient.publish(fcmMessage);
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
