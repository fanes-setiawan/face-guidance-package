import 'dart:typed_data';
import 'package:camera/camera.dart';

class Converter {
  static Uint8List yuv420toNV21(CameraImage image) {
    final width = image.width;
    final height = image.height;
    final ySize = width * height;

    final nv21 = Uint8List(ySize + (width * height ~/ 2));

    int pos = 0;
    final yPlane = image.planes[0];

    for (int row = 0; row < height; row++) {
      final start = row * yPlane.bytesPerRow;
      nv21.setRange(pos, pos + width, yPlane.bytes, start);
      pos += width;
    }
    return nv21;
  }
}
