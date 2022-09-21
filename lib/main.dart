import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:provider/provider.dart';

import 'components/app_settings.dart';
import 'components/session_handler.dart';
import 'globals.dart' as app;
import 'media/media_ressource.dart';
import 'messaging/messaging_client.dart';
import 'rtc/rtc_client.dart';
import 'rtc/rtc_clients_model.dart';
import 'rtc/rtc_connection_state.dart';
import 'signaling/signaling_client.dart';
import 'signaling/signaling_message.dart';
import 'signaling/signaling_message_type.dart';
import 'touch_scroll_behavior.dart';
import 'views/loading_view_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await app.init();
  MessagingClient messagingClient = MessagingClient();
  SignalingClient signalingClient =
      SignalingClient.fromMessagingClient(messagingClient);
  RtcClientsModel rtcClientsModel = RtcClientsModel();
  AppSettings appSettings = AppSettings.fromMessagingClient(messagingClient);

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
        ChangeNotifierProvider(
          create: ((context) => appSettings),
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
  final RTCVideoRenderer _rtcVideoRenderer = RTCVideoRenderer();
  late final Map<String, dynamic> config;

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
    _rtcVideoRenderer.initialize();
    signalingClient.messageController.stream.listen((message) {
      switch (message.type) {
        case SignalingMessageType.candidate:
          break;
        case SignalingMessageType.offer:
          SignalingMessage m = SignalingMessage.fromJson(message.toJson());
          createRtcClient(m);
          break;
        default:
          break;
      }
    });
  }

  void createRtcClient(SignalingMessage offerMessage) async {
    Map<String, dynamic> iceServers = config["webrtc"]["ice"];
    MediaRessource mediaRessource = MediaRessource();
    RtcClient client = RtcClient(
      signalingClient,
      mediaRessource,
      iceServers,
      onMediatrackReceived: ((mediaStream) {
        if (_rtcVideoRenderer.srcObject != null) {
          MediaStream stream = _rtcVideoRenderer.srcObject!;
          for (MediaStreamTrack audiotrack in mediaStream.getAudioTracks()) {
            stream.addTrack(audiotrack);
          }
          _rtcVideoRenderer.srcObject = stream;
        } else {
          _rtcVideoRenderer.srcObject = mediaStream;
        }
      }),
      onStateChanged: ((state, client) {
        switch (state) {
          case RtcConnectionState.disconnected:
            rtcClientsModel.remove(client);
            break;
          default:
            break;
        }
        if (messagingClient.isConnected()) {
          messagingClient.send(
            "rtc/call/state",
            state.toString(),
          );
        }
      }),
    );

    client.recipient = offerMessage.sender;

    appSettings.log =
        "request to start rtc acknowledged for ${client.recipient}, active calls: ${rtcClientsModel.clients.length}";

    await mediaRessource.open(true, true);
    client.answer(offerMessage);
    rtcClientsModel.add(client);
  }

  Widget content(BuildContext context) {
    return SessionHandler(
      timeout: const Duration(seconds: 10),
      enabled: false,
      onTimeout: () {
        appSettings.displayIsActive = false;
      },
      child: MaterialApp(
        scrollBehavior: TouchScrollBehavior(),
        home: Scaffold(
          body: LoadingViewPage(
            onLoad: (config) async {
              this.config = config;
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
              messagingClient.prefix = config["uid"] ?? "";
              await messagingClient.connect(
                username: config["mqtt"]["username"],
                password: config["mqtt"]["password"],
              );
              String uid = config["uid"] ?? "";
              appSettings.log = "System started with uid: $uid";
              signalingClient.uid = uid;
              signalingClient.signalingTopic = "rtc/signaling";
              messagingClient
                  .listen("rtc/signaling")
                  .listen("io/display/state")
                  .listen("firebase/notification/token/add")
                  .listen("io/camera/request");
            },
          ),
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
