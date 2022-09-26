import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'components/sign.dart';
import 'components/user_notification.dart';
import 'menue_view_page.dart';
import 'numpad_view.dart';
import 'screensaver_view.dart';
import 'signs_view.dart';
import '../components/app_settings.dart';
import '../crypto/sha2562.dart';
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
    messagingClient.messageController.stream.listen((event) {
      if (event.topic != "${messagingClient.prefix}io/user/notification") {
        return;
      }
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
      appSettings.log = "User Notification Received";
      setState(() {
        userNotifications.add(UserNotificationSkeleton.fromJson(payload));
      });
    });
  }

  void _onUnlock(String passcode) {
    appSettings.log = "The unlock button was tapped";
    String passcodeHash = sha2562.convert(utf8.encode(passcode)).toString();
    if (!messagingClient.isConnected()) return;
    messagingClient.send(
      "io/action/unlock/passcode",
      passcodeHash,
    );
  }

  void _onSignTap(String hash) async {
    appSettings.log = "The Sign with hash '$hash' was tapped";
    List<String>? tokens = app.preferences.getStringList("sign/$hash");
    if (null == tokens) {
      appSettings.log = "The Sign '$hash' has no tokens";
      return;
    }
    String snapshot =
        config["notification"]["snapshot"] == true ? await takePicture() : "";
    Map<String, dynamic> message = {
      "tokens": tokens,
      "title": "Jemand steht vor deiner Tuer",
      "body": "https://dieklingel.com/",
      "image": snapshot,
    };
    if (messagingClient.isConnected()) {
      messagingClient.send(
        "firebase/notification/send",
        jsonEncode(message),
      );
    }
    appSettings.log = "A Notification for the Sign '$hash' was send";
  }

  void _onScreensaverTap() {
    Provider.of<AppSettings>(context, listen: false).displayIsActive = true;
  }

  Future<String> takePicture() async {
    final List<CameraDescription> cameras = await availableCameras();
    if (cameras.isEmpty) {
      return "";
    }
    final CameraDescription camera = cameras.first;
    final CameraController controller = CameraController(
      camera,
      ResolutionPreset.medium,
    );
    await controller.initialize();
    XFile image = await controller.takePicture();
    List<int> bytes = await image.readAsBytes();
    String base64 = base64Encode(bytes);
    await controller.dispose();
    return "data:image/png;base64,$base64";
  }

  Widget _awake(
    BuildContext context, {
    required double width,
    required double height,
    required List<Sign> signs,
  }) {
    width -= 0.5; //
    return PageView(
      controller: PageController(
        viewportFraction: 0.99999, // preload next page
      ),
      children: [
        SizedBox(
          width: width,
          child: Signs(signs: signs),
        ),
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment(0.8, 1),
              colors: <Color>[
                Color(0xff1f005c),
                Color(0xff5b0060),
                Color(0xff870160),
                Color(0xffac255e),
                Color(0xffca485c),
                Color(0xffe16b5c),
                Color(0xfff39060),
                Color(0xffffb56b),
              ], // Gradient from https://learnui.design/tools/gradient-generator.html
              tileMode: TileMode.mirror,
            ),
          ),
          child: Numpad(
            width: width,
            height: height,
            textStyle: const TextStyle(color: Colors.white),
            onUnlock: _onUnlock,
            onLongUnlock: (passcode) {
              if (passcode != "000000") return;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: ((context) => const MenueViewPage()),
                ),
              );
            },
          ),
        ),
      ],
    );
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
          Provider.of<AppSettings>(context).displayIsActive
              ? _awake(
                  context,
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
              children: List.generate(userNotifications.length, (index) {
            return UserNotification.fromUserNotificationSkeleton(
              userNotifications[index],
              () {
                setState(() {
                  userNotifications.removeAt(index);
                });
              },
            );
          })),
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
