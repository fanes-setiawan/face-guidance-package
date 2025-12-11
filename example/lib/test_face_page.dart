import 'dart:io';
import 'package:flutter/material.dart';
import 'package:face_guidance/face_guidance.dart';


class TestFacePage extends StatefulWidget {
  const TestFacePage({super.key});

  @override
  State<TestFacePage> createState() => _TestFacePageState();
}

class _TestFacePageState extends State<TestFacePage> {
  File? result;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Face Guidance Preview")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (result != null)
              Column(
                children: [
                  Image.file(result!, width: 250),
                  const SizedBox(height: 16),
                  const Text("Foto berhasil diambil!"),
                ],
              )
            else
              const Text("Belum ada hasil"),

            const SizedBox(height: 20),

            ElevatedButton(
              child: const Text("Mulai Face Capture"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FaceGuidanceView(
                      config: CaptureConfig(
                        timeoutSeconds: 20,
                        language: "id", 
                      ),
                      onSuccess: (file) {
                        setState(() => result = file);
                        Navigator.pop(context);
                      },
                      onTimeout: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Timeout")),
                        );
                      },
                      onError: (err) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error: $err")),
                        );
                      },
                    ),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
