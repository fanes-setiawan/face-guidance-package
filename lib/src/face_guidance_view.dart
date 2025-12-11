import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:camera/camera.dart';

import 'camera_service.dart';
import 'models/capture_config.dart';
import 'utils/converter.dart';
import 'painters/circle_ring_painter.dart';
import 'painters/face_outline_painter.dart';

class FaceGuidanceView extends StatefulWidget {
  final CaptureConfig config;
  final Function(File image) onSuccess;
  final Function()? onTimeout;
  final Function(String error)? onError;

  final String defaultLanguage;

  const FaceGuidanceView({
    super.key,
    required this.config,
    required this.onSuccess,
    this.onTimeout,
    this.onError,
    this.defaultLanguage = "en",
  });

  @override
  State<FaceGuidanceView> createState() => _FaceGuidanceViewState();
}

class _FaceGuidanceViewState extends State<FaceGuidanceView> {
  final CameraService _camera = CameraService();
  late FaceDetector _detector;

  int timeLeft = 0;
  Timer? timer;

  String hint = "";
  bool inside = false;

  File? captured;
  bool _capturing = false;

  int _noFaceCooldown = 0;
  DateTime? _stableStart;

  @override
  void initState() {
    super.initState();
    timeLeft = widget.config.timeoutSeconds;

    hint = _t("place_face");

    _detector = FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.fast,
        enableClassification: true,
        enableLandmarks: true,
      ),
    );

    _init();
    _startTimer();
  }

  @override
  void dispose() {
    timer?.cancel();
    _camera.dispose();
    _detector.close();
    super.dispose();
  }

  String _t(String key) {
    final lang = widget.config.language;

    const en = {
      "place_face": "Position your face inside the frame",
      "no_face": "No face detected",
      "move_right": "Move your face to the right",
      "move_left": "Move your face to the left",
      "move_up": "Raise your face a bit",
      "move_down": "Lower your face a bit",
      "come_closer": "Move closer to the camera",
      "move_back": "Move slightly back",
      "good": "Perfect! Hold still…",
    };

    const id = {
      "place_face": "Posisikan wajah di dalam lingkaran",
      "no_face": "Wajah tidak terdeteksi",
      "move_right": "Geser wajah ke kanan",
      "move_left": "Geser wajah ke kiri",
      "move_up": "Naikkan wajah sedikit",
      "move_down": "Turunkan wajah sedikit",
      "come_closer": "Dekatkan wajah ke kamera",
      "move_back": "Jauhkan sedikit wajah",
      "good": "Posisi pas! Jangan bergerak…",
    };

    if (lang == "id") return id[key] ?? key;
    return en[key] ?? key;
  }

  Future<void> _init() async {
    try {
      await _camera.initialize();
      await _camera.controller!.startImageStream(_processFrame);
      setState(() {});
    } catch (e) {
      widget.onError?.call(e.toString());
    }
  }

  void _startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (timeLeft <= 0) {
        t.cancel();
        widget.onTimeout?.call();
      }
      setState(() => timeLeft--);

      if (_noFaceCooldown > 0) _noFaceCooldown--;
    });
  }

  Future<void> _processFrame(CameraImage image) async {
    if (captured != null || _capturing) return;

    final nv21 = Converter.yuv420toNV21(image);

    final input = InputImage.fromBytes(
      bytes: nv21,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: InputImageRotation.rotation270deg,
        format: InputImageFormat.nv21,
        bytesPerRow: image.planes[0].bytesPerRow,
      ),
    );

    final faces = await _detector.processImage(input);

    if (faces.isEmpty) {
      if (_noFaceCooldown == 0) {
        _update(_t("no_face"), false);
        _noFaceCooldown = 2;
      }
      _stableStart = null;
      return;
    }

    _checkFacePosition(faces.first.boundingBox);
  }

  void _checkFacePosition(Rect box) async {
    final c = _camera.controller;
    if (c == null) return;

    final size = c.value.previewSize!;
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    final fs = widget.config.frameSize;
    final tol = widget.config.frameTolerance;

    final left = centerX - fs / 2 - tol;
    final right = centerX + fs / 2 + tol;
    final top = centerY - fs / 2 - tol;
    final bottom = centerY + fs / 2 + tol;

    final faceX = box.center.dx;
    final faceY = box.center.dy;

    String message = "";
    bool ok = true;

    if (faceX < left) {
      message = _t("move_right");
      ok = false;
    } else if (faceX > right) {
      message = _t("move_left");
      ok = false;
    }

    if (ok) {
      if (faceY < top) {
        message = _t("move_down");
        ok = false;
      } else if (faceY > bottom) {
        message = _t("move_up");
        ok = false;
      }
    }

    final faceWidth = box.width;

    if (ok) {
      if (faceWidth < 300) {
        message = _t("come_closer");
        ok = false;
      } else if (faceWidth > 350) {
        message = _t("move_back");
        ok = false;
      }
    }

    if (!ok) {
      _stableStart = null;
      _update(message, false);
      return;
    }

    message = _t("good");

    _stableStart ??= DateTime.now();

    final diff = DateTime.now().difference(_stableStart!).inMilliseconds;

    if (diff >= 2000 && !_capturing) {
      _capturing = true;

      final img = await _camera.takePhoto();
      if (img != null && mounted) {
        captured = img;
        widget.onSuccess(img);
      }
      return;
    }

    _update(message, true);
  }

  void _update(String msg, bool ok) {
    setState(() {
      hint = msg;
      inside = ok;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cam = _camera.controller;

    return Scaffold(
      backgroundColor: widget.config.background,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Column(
              children: [
                SizedBox(
                  width: widget.config.frameSize,
                  height: widget.config.frameSize,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipOval(
                        child: Container(
                          width: 260,
                          height: 260,
                          color: Colors.black12,
                          child: (cam == null || !cam.value.isInitialized)
                              ? const Center(child: Text("Memuat kamera..."))
                              : CameraPreview(cam),
                        ),
                      ),
                      SizedBox(
                        width: 260,
                        height: 260,
                        child: CustomPaint(
                          painter: CircleRingPainter(
                            color: inside
                                ? widget.config.activeColor
                                : widget.config.inactiveColor,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 240,
                        height: 240,
                        child: CustomPaint(
                          painter: FaceOutlinePainter(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            hint,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: inside
                  ? widget.config.activeColor
                  : widget.config.inactiveColor,
            ),
          ),
        ],
      ),
    );
  }
}
