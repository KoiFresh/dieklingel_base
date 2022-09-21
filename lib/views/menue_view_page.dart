import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/app_settings.dart';
import '../messaging/messaging_client.dart';
import '../rtc/rtc_clients_model.dart';

class MenueViewPage extends StatefulWidget {
  const MenueViewPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MenueViewPage();
}

class _MenueViewPage extends State<MenueViewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Menue")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text("foce reload"),
            ),
            Text(
              "current RTC's: ${Provider.of<RtcClientsModel>(context).clients.length.toString()}",
            ),
            Text(
              "current mqtt state: ${Provider.of<MessagingClient>(context).isConnected()}",
            ),
            Text(
              "last log: ${Provider.of<AppSettings>(context).log}",
            )
          ],
        ),
      ),
    );
  }
}
