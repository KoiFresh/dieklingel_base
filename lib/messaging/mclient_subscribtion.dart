import 'mclient_topic_message.dart';

class MClientSubscribtion {
  final String topic;
  final void Function(MClientTopicMessage message) listener;
  final RegExp regExp;

  MClientSubscribtion(this.topic, {required this.listener, regExp})
      : regExp = regExp ?? RegExp(topic);
}
