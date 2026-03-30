# Biometry Dart SDK

[![pub.dev](https://img.shields.io/pub/v/biometry_api.svg)](https://pub.dev/packages/biometry_api)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Dart](https://img.shields.io/badge/Dart-%3E%3D3.0-blue.svg)](https://dart.dev)

Server-side Dart SDK for the [Biometry](https://biometrysolutions.com) identity verification platform.

## Installation

Add `biometry_api` to your `pubspec.yaml`:

```yaml
dependencies:
  biometry_api: ^0.1.0
```

Then run:

```bash
dart pub get
```

## Quick Start

```dart
import 'package:biometry_api/biometry_api.dart';

final client = BiometryClient('your-api-key-jwt');

// Start a biometric session
final sessionId = await client.sessions.start(fullname: 'John Doe');
print('Session started: $sessionId');
```

## Full Verification Flow

A typical identity verification flow: start a session, collect consent, authenticate a document, enroll the face from the document, process a biometric video, match the face against the session video, then end the session.

```dart
import 'dart:io';
import 'package:biometry_api/biometry_api.dart';

Future<void> main() async {
  final client = BiometryClient(
    'your-api-key-jwt',
    userFullname: 'John Doe',
  );

  // 1. Start session
  final sessionId = await client.sessions.start();
  print('Session: $sessionId');

  // 2. Approve consent
  await client.consents.approve('consent-id', 'user-id', sessionId: sessionId);

  // 3. Document authentication
  final docImage = await File('passport.jpg').readAsBytes();
  final docResult = await client.docAuth.check(
    document: docImage,
    fileName: 'passport.jpg',
    sessionId: sessionId,
    inhouseDocAuth: true,
    mrzValidation: true,
  );
  final docInfo = docResult.decode(DocAuthInfo.fromJson);
  print('Document: ${docInfo.firstName} ${docInfo.lastName}');

  // 4. Enroll face from document
  final faceImage = await File('face.jpg').readAsBytes();
  await client.enrollment.face(
    EnrollFaceInput(face: faceImage, fileName: 'face.jpg', isDocument: true),
    sessionId: sessionId,
  );

  // 5. Process biometric video
  final videoBytes = await File('video.mp4').readAsBytes();
  final videoResult = await client.video.process(
    ProcessVideoInput(
      video: videoBytes,
      videoName: 'video.mp4',
      phrase: 'one two three four',
    ),
    sessionId: sessionId,
  );
  print('Video score: ${videoResult.score}');

  // 6. Face match with session video (reuses the video from step 5)
  final matchResult = await client.faceMatch.matchWithSessionVideo(
    image: faceImage,
    imageName: 'face.jpg',
    sessionId: sessionId,
  );
  print('Match score: ${matchResult.score}');

  // 7. End session
  await client.sessions.end(sessionId);
  print('Session ended');
}
```

## Services

| Service | Accessor | Methods |
|---------|----------|---------|
| Sessions | `client.sessions` | `start()`, `end()` |
| Video | `client.video` | `process()` |
| Enrollment | `client.enrollment` | `face()`, `voice()` |
| Face Match | `client.faceMatch` | `match()`, `matchWithSessionVideo()` |
| Document Auth | `client.docAuth` | `check()` |
| Consents | `client.consents` | `approve()`, `myApprovals()` |
| Images | `client.images` | `upload()`, `get()` |
| AVF | `client.avf` | `startInference()`, `checkStatus()` |
| Transactions | `client.transactions` | `list()`, `count()`, `getBySession()`, `getSamples()`, `updateTags()`, `flag()` |
| API Keys | `client.apiKeys` | `mint()`, `revoke()`, `info()` |

## Per-Request Options

Every service method accepts optional named parameters that map to request headers:

| Parameter | Header | Description |
|-----------|--------|-------------|
| `sessionId` | `X-Session-ID` | Biometric session identifier |
| `fullname` | `X-User-Fullname` | User's full name |
| `deviceInfo` | `X-Device-Info` | Device information string |
| `geoLocation` | `X-Geo-Location` | Geographic location |
| `requestTags` | `X-Request-Tags` | Comma-separated tags |
| `clientApp` | `X-Client-App` | Client application name |
| `clientVersion` | `X-Client-Version` | Client application version |
| `inhouseDocAuth` | `X-Inhouse-Docauth` | Use in-house document authentication |
| `mrzValidation` | `X-Inhouse-MRZ` | Enable MRZ validation |

```dart
final result = await client.video.process(
  input,
  sessionId: sessionId,
  deviceInfo: 'iPhone 15',
  geoLocation: '-33.8688,151.2093',
  requestTags: 'onboarding,mobile',
  clientApp: 'my-app',
  clientVersion: '2.1.0',
);
```

## Response Headers

The `BiometryResponse` object exposes useful response headers:

```dart
final resp = await client.video.process(input, sessionId: sessionId);

resp.requestId;       // X-Request-Id  - unique request identifier
resp.autoEnrolled;    // X-Auto-Enroll - whether auto-enrollment occurred
resp.removedServices; // X-Removed-Services - whether services were removed
```

## Error Handling

All API errors are thrown as `BiometryAPIError` with the HTTP status code, message, and raw body:

```dart
try {
  await client.sessions.start();
} on BiometryAPIError catch (e) {
  print('HTTP ${e.statusCode}: ${e.message}');
}
```

Convenience helpers for common status codes:

```dart
try {
  await client.sessions.end(sessionId);
} on BiometryAPIError catch (e) {
  if (isNotFound(e)) print('Session not found');
  if (isForbidden(e)) print('Access denied');
  if (isUnauthorized(e)) print('Invalid API key');
}
```

## Documentation

Full API reference and integration guides are available at [docs.biometrysolutions.com/sdks/dart](https://docs.biometrysolutions.com/sdks/dart/).

## License

[MIT](LICENSE) - Copyright 2026 Namadgi Pty Ltd
