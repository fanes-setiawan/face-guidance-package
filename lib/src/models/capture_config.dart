import 'package:flutter/material.dart';

class CaptureConfig {
  final int timeoutSeconds;
  final double frameSize;
  final double frameTolerance;
  final Color activeColor;
  final Color inactiveColor;
  final String language;
  final Color background;

  const CaptureConfig({
    this.timeoutSeconds = 20,
    this.frameSize = 240,
    this.frameTolerance = 200,
    this.activeColor = Colors.green,
    this.inactiveColor = Colors.red,
    this.language = 'id',
    this.background = Colors.white,
  });
}
