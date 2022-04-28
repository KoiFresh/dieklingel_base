import '../event/event_emitter.dart';
import 'signaling_message.dart';

abstract class SignalingClient extends EventEmitter {
  String identifier = "";
  void connect(String url, {int port = -1});
  void send(SignalingMessage message);
}
