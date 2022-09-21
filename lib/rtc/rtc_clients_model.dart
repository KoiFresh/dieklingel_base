import 'dart:collection';

import 'package:dieklingel_base/rtc/rtc_client.dart';
import 'package:flutter/material.dart';

class RtcClientsModel extends ChangeNotifier {
  final List<RtcClient> _clients = [];

  UnmodifiableListView<RtcClient> get clients => UnmodifiableListView(_clients);

  void add(RtcClient rtcClient) {
    _clients.add(rtcClient);
    notifyListeners();
  }

  void remove(RtcClient client) {
    _clients.remove(client);
    notifyListeners();
  }
}
