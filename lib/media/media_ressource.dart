import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class MediaRessource {
  static Future<XFile> getSnapshot() async {
    final List<CameraDescription> cameras = await availableCameras();
    if (cameras.isEmpty) {
      return XFile.fromData(Uint8List(0));
    }
    final CameraController controller = CameraController(
      cameras.first,
      ResolutionPreset.medium,
    );
    await controller.initialize();
    XFile image = await controller.takePicture();
    await controller.dispose();
    return image;
  }

  MediaStream? _stream;

  MediaStream? get stream {
    return _stream;
  }

  Future<MediaStream?> open(bool audio, bool video) async {
    if (null != _stream) return _stream;
    Map<String, bool> constraints = {
      'audio': audio,
      'video': video,
    };
    _stream = await navigator.mediaDevices.getUserMedia(constraints);
    return _stream;
  }

  void close() {
    _stream?.getTracks().forEach((track) {
      track.stop();
    });
    _stream?.dispose();
    _stream = null;
  }
}
