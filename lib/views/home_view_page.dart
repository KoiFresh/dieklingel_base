import 'dart:convert';
import 'dart:typed_data';
import 'package:dieklingel_base/database/objectdb_factory.dart';
import 'package:dieklingel_base/event/event_monitor.dart';
import 'package:dieklingel_base/event/system_event.dart';
import 'package:dieklingel_base/event/system_event_type.dart';
import 'package:dieklingel_base/messaging/mclient_topic_message.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:objectdb/objectdb.dart';
import '../extensions/byte64_converter_byte_buffer.dart';
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
      UserNotificationSkeleton skeleton = UserNotificationSkeleton.fromJson(
        {
          "key": UniqueKey().toString(),
          "title": "",
          "body": event.message,
          "ttl": 15,
          "delay": 0,
        },
      );
      setState(() {
        userNotifications.add(skeleton);
      });

      SystemEvent even = SystemEvent(
        type: SystemEventType.notification,
        payload: event.message,
      );
      context.read<EventMonitor>().add(even);

      // TODO: play alert sound
    });
  }

  void _onSignTap(String id) async {
    EventMonitor monitor = context.read<EventMonitor>();
    MediaRessource mediaRessource = MediaRessource();
    MClient mClient = context.read<MClient>();

    // publish sign information
    if (mClient.isConnected()) {
      List<dynamic> payloads = [];

      ObjectDB database = ObjectDBFactory.get();
      List<JSON> docs = await database.find({"id": id});
      for (var element in docs) {
        payloads.add(element["payload"]);
      }

      Map<String, dynamic> payload = {
        "id": id,
        "payload": payloads,
      };

      MClientTopicMessage message = MClientTopicMessage(
        topic: "io/action/sign/clicked",
        message: jsonEncode(payload),
      );
      mClient.publish(message);
    }

    // publish clicked events
    SystemEvent clickedEvent = SystemEvent(
      type: SystemEventType.text,
      payload: "The Sign with the hash '$id' has been clicked.",
    );
    monitor.add(clickedEvent);

    // take picture
    MediaStream? stream = await mediaRessource.open(false, true);
    if (null == stream) {
      SystemEvent event = SystemEvent(
        type: SystemEventType.warning,
        payload: "could not open camera for snapshot",
      );
      monitor.add(event);
      return;
    }

    await Future.delayed(const Duration(seconds: 1)); // cooldown for lightning
    MediaStreamTrack? track = stream.getVideoTracks().first;

    ByteBuffer buffer = await track.captureFrame();
    mediaRessource.close();
    String snapshot = await buffer.asB64String(data: "image/png");

    // publish picture event
    SystemEvent imageEvent = SystemEvent(
      type: SystemEventType.image,
      payload: snapshot,
    );
    monitor.add(imageEvent);
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
