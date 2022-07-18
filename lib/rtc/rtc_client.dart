import 'package:dieklingel_base/rtc/rtc_connection_state.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../event/event_emitter.dart';
import '../media/media_ressource.dart';
import '../signaling/signaling_message.dart';
import '../signaling/signaling_message_type.dart';
import '../signaling/signaling_client.dart';

class RtcClient extends EventEmitter {
  final SignalingClient _signalingClient;
  final MediaRessource _mediaRessource;
  final Map<String, dynamic> _iceServers;
  String recipient = "";
  RTCPeerConnection? _rtcPeerConnection;

  RtcClient(this._signalingClient, this._mediaRessource, this._iceServers) {
    _signalingClient.addEventListener("message", (message) {
      if (message is! SignalingMessage) return;
      switch (message.type) {
        case SignalingMessageType.offer:
          emit("state-changed", RtcConnectionState.invited);
          emit("offer-received", message);
          break;
        case SignalingMessageType.answer:
          emit("state-changed", RtcConnectionState.connecting);
          _rtcPeerConnection?.setRemoteDescription(
            RTCSessionDescription(
              message.data['sdp'],
              message.data['type'],
            ),
          );
          break;
        case SignalingMessageType.candidate:
          _rtcPeerConnection?.addCandidate(
            RTCIceCandidate(
              message.data['candidate'],
              message.data['sdpMid'],
              message.data['sdpMLineIndex'],
            ),
          );
          break;
        case SignalingMessageType.busy:
        case SignalingMessageType.leave:
          emit("state-changed", RtcConnectionState.disconnected);
          abort();
          break;
        default:
          break;
      }
    });
  }

  Future<RTCPeerConnection> _createRtcPeerConnection() async {
    RTCPeerConnection connection = await createPeerConnection(_iceServers);
    MediaStream? stream = _mediaRessource.stream;
    if (null != stream) {
      stream.getTracks().forEach((track) {
        connection.addTrack(track, stream);
      });
    }
    connection.onIceCandidate = _onNewIceCandidateFound;
    connection.onConnectionState = _onConnectionStateChanged;
    connection.onTrack = _onTrackReceived;
    return connection;
  }

  void _onNewIceCandidateFound(RTCIceCandidate candidate) {
    if (null == _rtcPeerConnection) return;
    SignalingMessage message = SignalingMessage();
    message.sender = _signalingClient.uid;
    message.recipient = recipient;
    message.type = SignalingMessageType.candidate;
    message.data = candidate.toMap();
    _signalingClient.send(message);
  }

  void _onConnectionStateChanged(RTCPeerConnectionState state) {
    // emit("state-changed", state.toString());
    switch (state) {
      case RTCPeerConnectionState.RTCPeerConnectionStateConnected:
        emit("state-changed", RtcConnectionState.connected);
        break;
      case RTCPeerConnectionState.RTCPeerConnectionStateDisconnected:
        hangup();
        break;
      default:
        break;
    }
  }

  void _onTrackReceived(RTCTrackEvent event) {
    emit("mediatrack-received", event.streams[0]);
  }

  Future<void> invite(String other,
      {Map<String, dynamic> options = const {}}) async {
    emit("state-changed", RtcConnectionState.connecting);
    RTCPeerConnection connection = await _createRtcPeerConnection();
    recipient = other;
    RTCSessionDescription offer = await connection.createOffer(options);
    await connection.setLocalDescription(offer);
    SignalingMessage message = SignalingMessage();
    message.recipient = other;
    message.sender = _signalingClient.uid;
    message.type = SignalingMessageType.offer;
    message.data = offer.toMap();
    _rtcPeerConnection = connection;
    _signalingClient.send(message);
  }

  Future<void> answer(SignalingMessage offer) async {
    if (offer.type != SignalingMessageType.offer) return;
    emit("state-changed", RtcConnectionState.connecting);
    RTCPeerConnection connection = await _createRtcPeerConnection();
    recipient = offer.sender;
    await connection.setRemoteDescription(RTCSessionDescription(
      offer.data["sdp"],
      offer.data["type"],
    ));
    RTCSessionDescription answer = await connection.createAnswer();
    await connection.setLocalDescription(answer);
    SignalingMessage message = SignalingMessage();
    message.sender = _signalingClient.uid;
    message.recipient = offer.sender;
    message.type = SignalingMessageType.answer;
    message.data = answer.toMap();
    _rtcPeerConnection = connection;
    _signalingClient.send(message);
  }

  Future<void> hangup() async {
    if (null == _rtcPeerConnection) return;
    SignalingMessage message = SignalingMessage();
    message.sender = _signalingClient.uid;
    message.recipient = recipient;
    message.type = SignalingMessageType.leave;
    _signalingClient.send(message);
    abort();
  }

  Future<void> abort() async {
    if (null == _rtcPeerConnection) return;
    await _rtcPeerConnection?.close();
    _mediaRessource.close();
    _rtcPeerConnection = null;
    recipient = "";
  }
}
