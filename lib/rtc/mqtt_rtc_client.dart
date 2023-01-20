import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import 'rtc_connection_state.dart';
import 'rtc_transceiver.dart';

import '../media/media_ressource.dart';
import '../messaging/mclient.dart';
import '../messaging/mclient_state.dart';
import '../messaging/mclient_subscribtion.dart';
import '../models/ice_server.dart';
import '../models/mqtt_uri.dart';
import '../signaling/signaling_message.dart';
import '../signaling/signaling_message_type.dart';

class MqttRtcClient extends ChangeNotifier {
  final String username;
  final String password;
  final MqttUri uri;
  final MediaRessource mediaRessource;
  final RTCVideoRenderer rtcVideoRenderer = RTCVideoRenderer();

  late final MClient mclient;
  late final MClientSubscribtion sub;
  late final String topic;

  RtcConnectionState _rtcConnectionState = RtcConnectionState.disconnected;
  late final RTCPeerConnection _rtcPeerConnection;

  RtcConnectionState get rtcConnectionState => _rtcConnectionState;

  set __rtcConnectionState(RtcConnectionState state) {
    if (state != _rtcConnectionState) {
      _rtcConnectionState = state;
      notifyListeners();
    }
  }

  MqttRtcClient.invite(
    this.uri,
    this.mediaRessource, {
    this.username = "",
    this.password = "",
  }) {
    rtcVideoRenderer.initialize();
    mclient = MClient();

    topic = "invite";
    sub = mclient.subscribe("answer", _onMessage);
  }

  MqttRtcClient.answer(
    this.uri,
    this.mediaRessource, {
    this.username = "",
    this.password = "",
  }) {
    rtcVideoRenderer.initialize();
    mclient = MClient();

    topic = "answer";
    sub = mclient.subscribe("invite", _onMessage);
  }

  /// make sure to open the media ressource before calling init
  Future<void> init({
    List<RtcTransceiver> transceivers = const [],
    List<IceServer> iceServers = const [],
  }) async {
    await mclient.connect(uri, username: username, password: password);

    List<Map<String, dynamic>> servers = iceServers
        .map(
          (e) => {
            "urls": e.urls,
            "username": e.username,
            "credential": e.credential
          },
        )
        .toList();

    _rtcPeerConnection = await createPeerConnection({"iceServers": servers});

    MediaStream? stream = mediaRessource.stream;
    if (null != stream) {
      stream.getTracks().forEach((track) {
        _rtcPeerConnection.addTrack(track, stream);
      });
    }

    _rtcPeerConnection.onIceCandidate = _onIceCandidate;
    _rtcPeerConnection.onConnectionState = _onConnectionState;
    _rtcPeerConnection.onTrack = _onTrack;

    for (RtcTransceiver transceiver in transceivers) {
      await _rtcPeerConnection.addTransceiver(
        kind: transceiver.kind,
        init: RTCRtpTransceiverInit(
          direction: transceiver.direction,
        ),
      );
    }
  }

  void _onMessage(String topic, String message) async {
    SignalingMessage smes = SignalingMessage.fromJson(
      jsonDecode(message),
    );
    switch (smes.type) {
      case SignalingMessageType.offer:
        __rtcConnectionState = RtcConnectionState.invited;
        _answer(smes);
        break;
      case SignalingMessageType.answer:
        __rtcConnectionState = RtcConnectionState.connecting;
        _rtcPeerConnection.setRemoteDescription(
          RTCSessionDescription(
            smes.data["sdp"],
            smes.data["type"],
          ),
        );
        break;
      case SignalingMessageType.candidate:
        RTCIceCandidate candidate = RTCIceCandidate(
          smes.data['candidate'],
          smes.data['sdpMid'],
          smes.data['sdpMLineIndex'],
        );
        _rtcPeerConnection.addCandidate(candidate);
        break;
      case SignalingMessageType.busy:
      case SignalingMessageType.leave:
      case SignalingMessageType.error:
        _rtcConnectionState = RtcConnectionState.disconnected;
        close();
        break;
    }
  }

  void _onIceCandidate(RTCIceCandidate candidate) {
    SignalingMessage message = SignalingMessage()
      ..type = SignalingMessageType.candidate
      ..data = candidate.toMap();
    mclient.publish(topic, message.toJsonString());
  }

  void _onConnectionState(RTCPeerConnectionState state) {
    switch (state) {
      case RTCPeerConnectionState.RTCPeerConnectionStateConnected:
        __rtcConnectionState = RtcConnectionState.connected;
        break;
      case RTCPeerConnectionState.RTCPeerConnectionStateDisconnected:
        __rtcConnectionState = RtcConnectionState.disconnected;
        close();
        break;
      default:
        break;
    }
    notifyListeners();
  }

  void _onTrack(RTCTrackEvent event) {
    if (event.streams.isEmpty) return;
    rtcVideoRenderer.srcObject = event.streams.first;
  }

  Future<void> open({
    Map<String, dynamic> options = const {},
  }) async {
    __rtcConnectionState = RtcConnectionState.connecting;
    RTCSessionDescription offer = await _rtcPeerConnection.createOffer(options);
    await _rtcPeerConnection.setLocalDescription(offer);

    SignalingMessage smes = SignalingMessage()
      ..type = SignalingMessageType.offer
      ..data = offer.toMap();

    mclient.publish(topic, smes.toJsonString());
  }

  Future<void> _answer(SignalingMessage offer) async {
    __rtcConnectionState = RtcConnectionState.connecting;
    await _rtcPeerConnection.setRemoteDescription(
      RTCSessionDescription(
        offer.data["sdp"],
        offer.data["type"],
      ),
    );
    RTCSessionDescription answer = await _rtcPeerConnection.createAnswer();
    await _rtcPeerConnection.setLocalDescription(answer);

    SignalingMessage message = SignalingMessage()
      ..type = SignalingMessageType.answer
      ..data = answer.toMap();

    mclient.publish(topic, message.toJsonString());
  }

  Future<void> close() async {
    SignalingMessage message = SignalingMessage()
      ..type = SignalingMessageType.leave;

    if (mclient.state == MClientState.connected) {
      mclient.publish(topic, message.toJsonString());
    }

    // TODO: fix disconnection
    return Future.delayed(const Duration(seconds: 1), () async {
      mclient.disconnect();
      await _rtcPeerConnection.close();
      mediaRessource.close();
      _rtcConnectionState = RtcConnectionState.disconnected;
    });
  }
}
