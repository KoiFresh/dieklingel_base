import 'dart:convert';

import '../media/media_ressource.dart';
import '../messaging/mclient.dart';
import '../messaging/mclient_subscribtion.dart';
import '../messaging/mclient_topic_message.dart';
import 'mqtt_rtc_description.dart';
import 'rtc_client.dart';
import 'rtc_connection_state.dart';
import '../signaling/signaling_message.dart';
import '../signaling/signaling_message_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class MqttRtcClient extends ChangeNotifier {
  final String username;
  final String password;
  final MqttRtcDescription mqttRtcDescription;
  final MediaRessource mediaRessource;
  final RTCVideoRenderer rtcVideoRenderer = RTCVideoRenderer()..initialize();

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
    this.mqttRtcDescription,
    this.mediaRessource, {
    this.username = "",
    this.password = "",
  }) {
    rtcVideoRenderer.initialize();
    mclient = MClient(mqttRtcDescription: mqttRtcDescription);

    topic = "invite";
    sub = mclient.subscribe("answer", _onMessage);
  }

  MqttRtcClient.answer(
    this.mqttRtcDescription,
    this.mediaRessource, {
    this.username = "",
    this.password = "",
  }) {
    rtcVideoRenderer.initialize();
    mclient = MClient(mqttRtcDescription: mqttRtcDescription);

    topic = "answer";
    sub = mclient.subscribe("invite", _onMessage);
  }

  /// make sure to open the media ressource before calling init
  Future<void> init({
    List<RtcTransceiver> transceivers = const [],
    Map<String, dynamic> iceServers = const {},
  }) async {
    await mclient.connect(username: username, password: password);
    _rtcPeerConnection = await createPeerConnection(iceServers);

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

  void _onMessage(MClientTopicMessage message) async {
    SignalingMessage smes = SignalingMessage.fromJson(
      jsonDecode(message.message),
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
    SignalingMessage smes = SignalingMessage();
    smes.type = SignalingMessageType.candidate;
    smes.data = candidate.toMap();
    MClientTopicMessage tmes = MClientTopicMessage(
      topic: topic,
      message: smes.toString(),
    );
    mclient.publish(tmes);
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
    SignalingMessage smes = SignalingMessage();
    smes.type = SignalingMessageType.offer;
    smes.data = offer.toMap();
    MClientTopicMessage tmes = MClientTopicMessage(
      topic: topic,
      message: smes.toString(),
    );
    mclient.publish(tmes);
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

    SignalingMessage smes = SignalingMessage();
    smes.type = SignalingMessageType.answer;
    smes.data = answer.toMap();
    MClientTopicMessage tmes = MClientTopicMessage(
      topic: topic,
      message: smes.toString(),
    );
    mclient.publish(tmes);
  }

  Future<void> close() async {
    SignalingMessage smes = SignalingMessage();
    smes.type = SignalingMessageType.leave;
    MClientTopicMessage tmes = MClientTopicMessage(
      topic: topic,
      message: smes.toString(),
    );
    if (mclient.isConnected()) {
      mclient.publish(tmes);
    }

    return Future.delayed(const Duration(seconds: 1), () async {
      mclient.disconnect();
      await _rtcPeerConnection.close();
      mediaRessource.close();
      _rtcConnectionState = RtcConnectionState.disconnected;
    });
  }
}
