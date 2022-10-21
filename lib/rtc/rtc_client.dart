import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import 'rtc_connection_state.dart';
import '../media/media_ressource.dart';
import '../signaling/signaling_message.dart';
import '../signaling/signaling_message_type.dart';
import '../signaling/signaling_client.dart';

class RtcTransceiver {
  RTCRtpMediaType kind;
  TransceiverDirection direction;

  RtcTransceiver({required this.kind, required this.direction});

  dynamic toAddableTransiver() {
    return {
      "kind": kind,
      "init": RTCRtpTransceiverInit(direction: direction),
    };
  }
}

class RtcClient extends ChangeNotifier {
  final SignalingClient _signalingClient;
  final MediaRessource _mediaRessource;
  final Map<String, dynamic> _iceServers;
  final Function(SignalingMessage offer)? onOfferReceived;
  final Function(MediaStream mediaStream)? onMediatrackReceived;
  final Function(RtcConnectionState state, RtcClient client)? onStateChanged;
  String recipient = "";

  RTCPeerConnection? _rtcPeerConnection;
  List<RTCIceCandidate> candidates = List.empty(growable: true);
  RtcConnectionState _rtcConnectionState = RtcConnectionState.disconnected;

  set rtcConnectionState(RtcConnectionState state) {
    _rtcConnectionState = state;
    notifyListeners();
    onStateChanged?.call(state, this);
  }

  RtcConnectionState get rtcConnectionState {
    return _rtcConnectionState;
  }

  RtcClient(
    this._signalingClient,
    this._mediaRessource,
    this._iceServers, {
    this.onOfferReceived,
    this.onMediatrackReceived,
    this.onStateChanged,
  }) {
    _signalingClient.messageController.stream.listen((message) {
      switch (message.type) {
        case SignalingMessageType.offer:
          onOfferReceived?.call(message);
          rtcConnectionState = RtcConnectionState.invited;
          notifyListeners();
          break;
        case SignalingMessageType.answer:
          _rtcPeerConnection?.setRemoteDescription(
            RTCSessionDescription(
              message.data['sdp'],
              message.data['type'],
            ),
          );
          rtcConnectionState = RtcConnectionState.connecting;
          notifyListeners();
          break;
        case SignalingMessageType.candidate:
          RTCIceCandidate candidate = RTCIceCandidate(
            message.data['candidate'],
            message.data['sdpMid'],
            message.data['sdpMLineIndex'],
          );
          if (_rtcPeerConnection == null) {
            candidates.add(candidate);
          }
          _rtcPeerConnection?.addCandidate(candidate);
          break;
        case SignalingMessageType.busy:
        case SignalingMessageType.leave:
          rtcConnectionState = RtcConnectionState.disconnected;
          notifyListeners();
          abort();
          break;
        default:
          break;
      }
    });
    /*_signalingClient.addEventListener("message", (message) {
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
          RTCIceCandidate candidate = RTCIceCandidate(
            message.data['candidate'],
            message.data['sdpMid'],
            message.data['sdpMLineIndex'],
          );
          if (_rtcPeerConnection == null) {
            candidates.add(candidate);
          }
          _rtcPeerConnection?.addCandidate(candidate);
          break;
        case SignalingMessageType.busy:
        case SignalingMessageType.leave:
          emit("state-changed", RtcConnectionState.disconnected);
          abort();
          break;
        default:
          break;
      }
    });*/
  }

  Future<RTCPeerConnection> _createRtcPeerConnection({
    List<RtcTransceiver> transceivers = const [],
  }) async {
    RTCPeerConnection connection = await createPeerConnection(_iceServers);
    MediaStream? stream = _mediaRessource.stream;
    if (null != stream) {
      stream.getTracks().forEach((track) {
        connection.addTrack(track, stream);
      });
    }
    connection.onIceCandidate = _onNewIceCandidateFound;
    connection.onIceConnectionState = (RTCIceConnectionState state) {
      switch (state) {
        case RTCIceConnectionState.RTCIceConnectionStateDisconnected:
        case RTCIceConnectionState.RTCIceConnectionStateFailed:
          //connection.restartIce();
          break;
        default:
          break;
      }
    };
    connection.onConnectionState = _onConnectionStateChanged;
    connection.onTrack = _onTrackReceived;
    // unified-plan has to set explicit
    for (RtcTransceiver transceiver in transceivers) {
      await connection.addTransceiver(
        kind: transceiver.kind,
        init: RTCRtpTransceiverInit(
          direction: transceiver.direction,
        ),
      );
    }
    return connection;
  }

  void _onNewIceCandidateFound(RTCIceCandidate candidate) {
    if (null == _rtcPeerConnection) return;
    SignalingMessage message = SignalingMessage();
    //message.sender = _signalingClient.uid;
    //message.recipient = recipient;
    message.type = SignalingMessageType.candidate;
    message.data = candidate.toMap();
    _signalingClient.send(message);
  }

  void _onConnectionStateChanged(RTCPeerConnectionState state) {
    switch (state) {
      case RTCPeerConnectionState.RTCPeerConnectionStateConnected:
        rtcConnectionState = RtcConnectionState.connected;
        notifyListeners();
        break;
      case RTCPeerConnectionState.RTCPeerConnectionStateDisconnected:
        rtcConnectionState = RtcConnectionState.disconnected;
        notifyListeners();
        hangup();
        break;
      default:
        break;
    }
  }

  void _onTrackReceived(RTCTrackEvent event) {
    if (event.streams.isEmpty) return;
    onMediatrackReceived?.call(event.streams[0]);
  }

  Future<void> invite(
    String other, {
    Map<String, dynamic> options = const {},
    List<RtcTransceiver> transceivers = const [],
  }) async {
    rtcConnectionState = RtcConnectionState.connecting;
    notifyListeners();
    RTCPeerConnection connection = await _createRtcPeerConnection(
      transceivers: transceivers,
    );
    recipient = other;
    RTCSessionDescription offer = await connection.createOffer(options);
    await connection.setLocalDescription(offer);
    SignalingMessage message = SignalingMessage();
    //message.recipient = other;
    //message.sender = _signalingClient.uid;
    message.type = SignalingMessageType.offer;
    message.data = offer.toMap();
    _rtcPeerConnection = connection;
    _signalingClient.send(message);
  }

  Future<void> answer(SignalingMessage offer) async {
    if (offer.type != SignalingMessageType.offer) return;
    rtcConnectionState = RtcConnectionState.connecting;
    notifyListeners();
    RTCPeerConnection connection = await _createRtcPeerConnection();
    //recipient = offer.sender;
    await connection.setRemoteDescription(RTCSessionDescription(
      offer.data["sdp"],
      offer.data["type"],
    ));
    RTCSessionDescription answer = await connection.createAnswer();
    await connection.setLocalDescription(answer);

    for (RTCIceCandidate candidate in candidates) {
      connection.addCandidate(candidate);
    }
    candidates.clear();

    SignalingMessage message = SignalingMessage();
    //message.sender = _signalingClient.uid;
    //message.recipient = offer.sender;
    message.type = SignalingMessageType.answer;
    message.data = answer.toMap();
    _rtcPeerConnection = connection;
    _signalingClient.send(message);
  }

  Future<void> hangup() async {
    if (null == _rtcPeerConnection) return;
    SignalingMessage message = SignalingMessage();
    //message.sender = _signalingClient.uid;
    //message.recipient = recipient;
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
