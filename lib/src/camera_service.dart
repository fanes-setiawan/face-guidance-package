import 'dart:io';
import 'package:camera/camera.dart';

class CameraService {
  CameraController? controller;
  bool _taking = false;

  Future<void> initialize() async {
    final cameras = await availableCameras();

    final front = cameras.firstWhere(
      (cam) => cam.lensDirection == CameraLensDirection.front,
    );

    controller = CameraController(
      front,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    await controller!.initialize();
  }

  Future<File?> takePhoto() async {
    if (controller == null || _taking) return null;
    _taking = true;

    try {
      final x = await controller!.takePicture();
      return File(x.path);
    } finally {
      _taking = false;
    }
  }

  void dispose() {
    controller?.dispose();
  }
}
