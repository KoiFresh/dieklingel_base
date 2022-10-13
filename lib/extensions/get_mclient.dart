import 'dart:async';
import 'package:uuid/uuid.dart';

import '../messaging/mclient.dart';
import '../messaging/mclient_subscribtion.dart';
import '../messaging/mclient_topic_message.dart';

extension Get on MClient {
  void listen(String topic, String Function(String message) executer) {
    subscribe("$topic/+", (message) {
      String returnVal = executer(message.message);
      publish(
        MClientTopicMessage(
          topic: "${message.topic}/response",
          message: returnVal,
        ),
      );
    });
  }

  Future<String?> get(
    String topic,
    String request, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    Completer<String?> completer = Completer<String?>();
    String identifier = const Uuid().v4();
    MClientSubscribtion sub =
        subscribe("$topic/$identifier/response", (message) {
      completer.complete(message.message);
    });
    publish(
      MClientTopicMessage(
        topic: "$topic/$identifier",
        message: request,
      ),
    );
    String? result =
        await completer.future.timeout(timeout, onTimeout: () => null);
    unsubscribe(sub);
    return result;
  }
}
