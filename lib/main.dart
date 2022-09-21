import 'package:dieklingel_base/components/session_handler.dart';
import 'package:dieklingel_base/messaging/messaging_client.dart';
import 'package:dieklingel_base/rtc/rtc_clients_model.dart';
import 'package:dieklingel_base/signaling/signaling_client.dart';
import 'package:dieklingel_base/touch_scroll_behavior.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'globals.dart' as app;
import 'views/loading_view_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await app.init();
  MessagingClient messagingClient = MessagingClient();
  SignalingClient signalingClient =
      SignalingClient.fromMessagingClient(messagingClient);
  RtcClientsModel rtcClientsModel = RtcClientsModel();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: ((context) => messagingClient),
        ),
        ChangeNotifierProvider(
          create: ((context) => signalingClient),
        ),
        ChangeNotifierProvider(
          create: ((context) => rtcClientsModel),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyApp();
}

class _MyApp extends State<MyApp> {
  EdgeInsetsGeometry geometry = const EdgeInsets.all(0);

  @override
  void initState() {
    super.initState();
  }

  Widget content(BuildContext context) {
    return MaterialApp(
      scrollBehavior: TouchScrollBehavior(),
      home: Scaffold(
        body: LoadingViewPage(
          onLoad: (config) async {
            EdgeInsets insets = EdgeInsets.fromLTRB(
              config["viewport"]?["clip"]?["left"] ?? 0.0,
              config["viewport"]?["clip"]?["top"] ?? 0.0,
              config["viewport"]?["clip"]?["right"] ?? 0.0,
              config["viewport"]?["clip"]?["bottom"] ?? 0.0,
            );
            setState(() {
              geometry = insets;
            });
            MessagingClient messagingClient =
                Provider.of<MessagingClient>(context, listen: false);
            SignalingClient signalingClient =
                Provider.of<SignalingClient>(context, listen: false);
            messagingClient.hostname = config["mqtt"]["address"] as String;
            messagingClient.port = config["mqtt"]["port"] as int;
            await messagingClient.connect(
              username: config["mqtt"]["username"],
              password: config["mqtt"]["password"],
            );
            String uid = config["uid"] ?? "";
            signalingClient.uid = uid;
            signalingClient.signalingTopic = "${uid}rtc/signaling";
            messagingClient
                .listen("${uid}rtc/signaling")
                .listen("${uid}io/display/state")
                .listen("${uid}firebase/notification/token/add")
                .listen("${uid}io/camera/request");
          },
        ),
      ),
    );
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: geometry,
      child: ClipRRect(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        borderRadius: BorderRadius.circular(20),
        child: content(context),
      ),
    );
  }
}
