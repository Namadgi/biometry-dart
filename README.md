# Biometry Dart SDK

[![pub.dev](https://img.shields.io/pub/v/biometry_api.svg)](https://pub.dev/packages/biometry_api)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Dart](https://img.shields.io/badge/Dart-%3E%3D3.0-blue.svg)](https://dart.dev)

Server-side Dart SDK for the [Biometry](https://biometrysolutions.com) identity verification platform. It calls the Biometry API v2 (`/api-gateway/v2`).

## Installation

Add `biometry_api` to your `pubspec.yaml`:

```yaml
dependencies:
  biometry_api: ^0.2.0
```

Then run:

```bash
dart pub get
```

## Quick Start

```dart
import 'package:biometry_api/biometry_api.dart';

final client = BiometryClient('your-api-key-jwt');

final sessionId = await client.sessions.start();
print('Session started: $sessionId');
```

Every biometric call takes a `userId`: your own opaque, stable key for the end user (not their name or email).

## Full Verification Flow

Enroll the user's face, then verify them in a session: liveness on a video, face verification on the same video, and a face match against their document.

```dart
import 'dart:io';
import 'package:biometry_api/biometry_api.dart';

Future<void> main() async {
  final client = BiometryClient('your-api-key-jwt');
  const userId = 'user-123';
  const phrase = 'one two three four five six seven';

  // 1. Record the user's consent (collected in your app). Enrollment needs
  //    both authorization and storage consent; give() records both by default.
  await client.consents.give(userId);

  // 2. Enroll the face
  final face = await File('face.jpg').readAsBytes();
  await client.enrollment.face(
    EnrollFaceInput(userId: userId, face: face, fileName: 'face.jpg'),
  );

  // 3. Start a session
  final sessionId = await client.sessions.start();

  // 4. Check the identity document
  final passport = await File('passport.jpg').readAsBytes();
  await client.docAuth.check(
    DocAuthInput(document: passport, fileName: 'passport.jpg', sessionId: sessionId),
  );

  // 5. Liveness on a video of the user reading the challenge phrase
  final video = await File('selfie.mp4').readAsBytes();
  await client.verification.liveness(LivenessInput(
    userId: userId,
    video: video,
    fileName: 'selfie.mp4',
    phrase: phrase,
    sessionId: sessionId,
  ));

  // 6. Face verification on the same video
  await client.verification.faceVerify(VerifyInput(
    userId: userId,
    phrase: phrase,
    sessionId: sessionId,
    useSessionVideo: true,
  ));

  // 7. Face match: document photo against the session video
  final match = await client.faceMatch.match(FaceMatchInput(
    userId: userId,
    referenceImage: passport,
    referenceName: 'passport.jpg',
    sessionId: sessionId,
    useSessionVideo: true,
  ));
  print('Face match decision: ${match.decision?.status}');

  // 8. End the session
  await client.sessions.end(sessionId);
}
```

In a session, face verification and face match must use the liveness media: the same file, or `useSessionVideo`.

## Consent

Face and voice enrollment need the user's **authorization** and **storage** consent; `images.upload()` needs authorization consent. Collect the user's agreement in your app, then record it:

```dart
// Give both (the default; enrollment needs both). sessionId is optional:
// it shows the consent with that session in the Console.
var state = await client.consents.give(userId, sessionId: sessionId);

// Withdraw storage consent only; authorization is left unchanged
state = await client.consents.revoke(userId, authorization: false);

// Read the current state (both false if the user never gave consent)
state = await client.consents.status(userId);
print('${state.authorization} ${state.storage}');
```

`give()` and `revoke()` return a `UserConsents` with the state after the change, are safe to repeat, and throw an `ArgumentError` before sending a request if both `authorization` and `storage` are `false`.

`consents.approve()` and `consents.myApprovals()` manage your project's custom consent templates. They do **not** unlock enrollment.

## Services

| Service | Accessor | Methods | API v2 |
|---------|----------|---------|--------|
| Sessions | `client.sessions` | `start()`, `end()` | `/v2/sessions` |
| Verification | `client.verification` | `liveness()`, `faceVerify()`, `voiceVerify()` | `/v2/liveness`, `/v2/face-verify`, `/v2/voice-verify` |
| Enrollment | `client.enrollment` | `face()`, `voice()` | `/v2/enrollments/face`, `/v2/enrollments/voice` |
| Face Match | `client.faceMatch` | `match()` | `/v2/face-match` |
| Document Auth | `client.docAuth` | `check()` | `/v2/documents/check` |
| Deepfake | `client.deepfake` | `submit()`, `status()` | `/v2/deepfake/checks` |
| Images | `client.images` | `upload()`, `get()` | `/v2/users/{user_id}/reference-image` |
| Consents | `client.consents` | `give()`, `revoke()`, `status()` | `/v2/users/{user_id}/consents` |
| Consents | `client.consents` | `approve()`, `myApprovals()` | `/v2/consents` (custom templates) |
| Transactions | `client.transactions` | `list()`, `count()`, `getBySession()`, `getSamples()`, `updateTags()`, `flag()` | `/api-transactions` (not part of v2) |
| API Keys | `client.apiKeys` | `mint()`, `revoke()`, `info()` | `/api-projects` (not part of v2) |

`LivenessInput.excludeServices` skips checks by name; use the `VerificationServices` constants (`faceLiveness`, `activeSpeaker`, `visualSpeech`, ...).

## Per-Request Options

Every service method accepts optional named parameters that map to request metadata headers:

| Parameter | Header | Description |
|-----------|--------|-------------|
| `deviceInfo` | `X-Device-Info` | Device information |
| `geoLocation` | `X-Geo-Location` | Geographic location |
| `requestTags` | `X-Request-Tags` | Comma-separated tags |
| `clientApp` | `X-Client-App` | Client application name |
| `clientVersion` | `X-Client-Version` | Client application version |

```dart
final result = await client.verification.liveness(
  input,
  deviceInfo: 'iPhone 15',
  geoLocation: '-33.8688,151.2093',
  requestTags: 'onboarding,mobile',
  clientApp: 'my-app',
  clientVersion: '2.1.0',
);
```

User, session and trigger are fields on the input objects, not headers.

## Responses

Calls that return `BiometryResponse` carry the API v2 envelope `{ data, decision, meta }`:

```dart
final resp = await client.verification.liveness(input);

resp.decision;   // Decision(status, score, reasons); null when no scoring system applies
resp.data;       // endpoint-specific payload
resp.requestId;  // request trace ID
```

## Error Handling

API errors are thrown as `BiometryAPIError`, with the HTTP status, the v2 error code, the message and the raw body:

```dart
try {
  await client.verification.liveness(input);
} on BiometryAPIError catch (e) {
  print('HTTP ${e.statusCode} ${e.code}: ${e.message}');
}
```

Helpers for common status codes:

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
