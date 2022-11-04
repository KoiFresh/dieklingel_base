import 'dart:convert';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:dieklingel_base/database/objectdb_factory.dart';
import 'package:dieklingel_base/event/event_monitor.dart';
import 'package:dieklingel_base/event/system_event.dart';
import 'package:dieklingel_base/event/system_event_type.dart';
import 'package:dieklingel_base/messaging/mclient_topic_message.dart';
import 'package:dieklingel_base/rtc/mqtt_rtc_description.dart';
import 'package:dieklingel_base/views/home/main_page.dart';
import 'package:dieklingel_base/views/home/passcode_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:objectdb/objectdb.dart';
import '../extensions/byte64_converter_byte_buffer.dart';
import '../media/media_ressource.dart';
import '../messaging/mclient.dart';
import 'package:provider/provider.dart';

import 'components/sign.dart';
import 'components/user_notification.dart';
import 'home/screensaver_page.dart';
import '../components/app_settings.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.config}) : super(key: key);

  final Map<String, dynamic> config;

  @override
  State<HomePage> createState() => _HomeViewPage();
}

class _HomeViewPage extends State<HomePage> {
  late final Map<String, dynamic> config = widget.config;
  final List<UserNotificationSkeleton> userNotifications = [];

  MClient get messagingClient {
    return Provider.of<MClient>(context, listen: false);
  }

  AppSettings get appSettings {
    return Provider.of<AppSettings>(context, listen: false);
  }

  @override
  void initState() {
    super.initState();
    MClient mclient = context.read<MClient>();
    mclient.mqttRtcDescription = MqttRtcDescription.parse(
      Uri.parse(config["mqtt"]["uri"]),
    );
    mclient.connect();
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

      AudioPlayer().play(AssetSource("audio/alert.wav"));
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
    List<Sign> signs = (config["signs"] as List<dynamic>).map(
      (element) {
        return Sign(
          element["text"],
          element["hash"],
          onTap: _onSignTap,
        );
      },
    ).toList();

    return CupertinoPageScaffold(
      child: Stack(
        children: [
          context.watch<AppSettings>().displayIsActive.value
              ? PageView(
                  children: [
                    MainPage(
                      signs: signs,
                    ),
                    const PasscodePage(),
                  ],
                )
              : ScreensaverPage(
                  text: config["viewport"]?["screensaver"]?["text"] ?? "",
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
