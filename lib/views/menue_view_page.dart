import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/app_settings.dart';
import '../messaging/mclient.dart';
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
                //Navigator.popUntil(context, (route) => route.isFirst);
                Provider.of<AppSettings>(context, listen: false).lastLog.value =
                    "Hallo";
              },
              child: const Text("foce reload"),
            ),
            Text(
              "current RTC's: ${Provider.of<RtcClientsModel>(context).clients.length.toString()}",
            ),
            Text(
              "current mqtt state: ${Provider.of<MClient>(context).connectionState}",
            ),
            Text(
              "last log: ${Provider.of<AppSettings>(context).lastLog.toString()}",
            )
          ],
        ),
      ),
    );
  }
}
