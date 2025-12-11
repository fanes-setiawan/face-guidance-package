import 'package:flutter/material.dart';
import 'test_face_page.dart';

void main() {
  runApp(const FaceGuidanceExampleApp());
}

class FaceGuidanceExampleApp extends StatelessWidget {
  const FaceGuidanceExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Face Guidance Demo',
      debugShowCheckedModeBanner: false,
      home: const TestFacePage(),
    );
  }
}
