import 'package:flutter_webrtc/flutter_webrtc.dart';

class RtcTransceiver {
  RTCRtpMediaType kind;
  TransceiverDirection direction;

  RtcTransceiver({required this.kind, required this.direction});
}
