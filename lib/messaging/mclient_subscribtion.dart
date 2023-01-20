class MClientSubscribtion {
  final String topic;
  final void Function(String topic, String message) listener;
  final RegExp regExp;

  MClientSubscribtion(this.topic, {required this.listener, regExp})
      : regExp = regExp ?? RegExp(topic);
}
