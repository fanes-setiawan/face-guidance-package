# face_guidance

Flutter package for real-time face guidance, frame alignment, and automatic face capture using Google ML Kit. Perfect for KYC, attendance, and identity verification apps.

## Features

- Real-time face detection
- Guidance to align face in frame
- Automatic photo capture when face is stable
- Configurable frame size, timeout, and colors
- Supports multiple languages

## Installation

Add to your `android/app/src/main/AndroidManifest.xml`:

```yaml
<uses-permission android:name="android.permission.CAMERA" />

```
Usage 
```yaml
import 'package:face_guidance/face_guidance.dart';

FaceGuidanceView(
  config: CaptureConfig(
    timeoutSeconds: 20,
    language: "id",
  ),
  onSuccess: (file) {
    # handle captured image
  },
  onTimeout: () {
    # handle timeout
  },
  onError: (err) {
    # handle error
  },
)

