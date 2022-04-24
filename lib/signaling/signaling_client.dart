import '../event/event_emitter.dart';
import 'signaling_message.dart';

abstract class SignalingClient extends EventEmitter {
  String identifier = "";
  void connect(String url);
  void send(SignalingMessage message);
}
