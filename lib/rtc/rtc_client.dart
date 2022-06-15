import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../event/event_emitter.dart';
import '../media/media_ressource.dart';
import '../signaling/signaling_message.dart';
import '../signaling/signaling_message_type.dart';
import '../signaling/signaling_client.dart';

class RtcClient extends EventEmitter {
  static const String mediaReceived = "media_received";
  static const String incommingCall = "incomming_call";
  static const String offer = "offer";

  final SignalingClient _signalingClient;
  final MediaRessource _mediaRessource;
  final Map<String, dynamic> _iceServers;
  String to = "";
  RTCPeerConnection? _rtcPeerConnection;

  RtcClient(
    SignalingClient signalingClient,
    MediaRessource mediaRessource,
    Map<String, dynamic> iceServers,
  )   : _signalingClient = signalingClient,
        _mediaRessource = mediaRessource,
        _iceServers = iceServers {
    _signalingClient.addEventListener(
        "message", (data) => {onSignalingMessage(data)});
  }

  SignalingClient get signalingClient {
    return _signalingClient;
  }

  MediaRessource get mediaRessource {
    return _mediaRessource;
  }

  Future<RTCPeerConnection> _createRtcPeerConnection() async {
    RTCPeerConnection connection = await createPeerConnection(_iceServers);
    MediaStream? stream = _mediaRessource.stream;
    if (null != stream) {
      stream.getTracks().forEach((track) {
        connection.addTrack(track, stream);
      });
    }
    connection.onIceCandidate = onNewIceCandidateFound;
    connection.onConnectionState = onConnectionStateChanged;
    connection.onTrack = onTrackReceived;
    return connection;
  }

  void onSignalingBroadcast(SignalingMessage message) {
    // TODO: implement method
  }

  void onSignalingMessage(SignalingMessage message) {
    switch (message.type) {
      case SignalingMessageType.offer:
        if (null == _rtcPeerConnection) {
          emit(RtcClient.offer, message);
        }
        break;
      case SignalingMessageType.answer:
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
        abort();
        break;
    }
  }

  void onNewIceCandidateFound(RTCIceCandidate candidate) {
    if (null == _rtcPeerConnection) return;
    SignalingMessage message = SignalingMessage();
    message.from = _signalingClient.identifier;
    message.to = to;
    message.type = SignalingMessageType.candidate;
    message.data = candidate.toMap();
    _signalingClient.send(message);
  }

  void onConnectionStateChanged(RTCPeerConnectionState state) {
    switch (state) {
      case RTCPeerConnectionState.RTCPeerConnectionStateDisconnected:
        hangup();
        break;
      default:
        break;
    }
  }

  void onTrackReceived(RTCTrackEvent event) {
    emit(RtcClient.mediaReceived, event.streams[0]);
  }

  Future<void> invite(String other,
      {Map<String, dynamic> options = const {}}) async {
    RTCPeerConnection connection = await _createRtcPeerConnection();
    to = other;
    RTCSessionDescription offer = await connection.createOffer(options);
    await connection.setLocalDescription(offer);
    SignalingMessage message = SignalingMessage();
    message.to = other;
    message.from = _signalingClient.identifier;
    message.type = SignalingMessageType.offer;
    message.data = offer.toMap();
    _rtcPeerConnection = connection;
    _signalingClient.send(message);
  }

  Future<void> answer(SignalingMessage offer) async {
    if (offer.type != SignalingMessageType.offer) return;
    RTCPeerConnection connection = await _createRtcPeerConnection();
    to = offer.from;
    await connection.setRemoteDescription(RTCSessionDescription(
      offer.data["sdp"],
      offer.data["type"],
    ));
    RTCSessionDescription answer = await connection.createAnswer();
    await connection.setLocalDescription(answer);
    SignalingMessage message = SignalingMessage();
    message.from = _signalingClient.identifier;
    message.to = offer.from;
    message.type = SignalingMessageType.answer;
    message.data = answer.toMap();
    _rtcPeerConnection = connection;
    _signalingClient.send(message);
  }

  Future<void> hangup() async {
    if (null == _rtcPeerConnection) return;
    SignalingMessage message = SignalingMessage();
    message.from = _signalingClient.identifier;
    message.to = to;
    message.type = SignalingMessageType.leave;
    _signalingClient.send(message);
    abort();
  }

  Future<void> abort() async {
    if (null == _rtcPeerConnection) return;
    await _rtcPeerConnection?.close();
    _mediaRessource.close();
    _rtcPeerConnection = null;
    to = "";
  }
}
