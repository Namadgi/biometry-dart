/// Dart SDK for the Biometry platform APIs (API v2).
///
/// Initialize a client with your API key and call methods on the service
/// sub-clients:
///
/// ```dart
/// final client = BiometryClient('your-api-key-jwt');
///
/// final sessionId = await client.sessions.start();
/// ```
library biometry_api;

export 'src/call_options.dart';
export 'src/client.dart';
export 'src/errors.dart';
export 'src/response.dart';
export 'src/transport.dart' show FileUpload;
export 'src/types.dart';
export 'src/v2.dart';
export 'src/services/sessions.dart';
export 'src/services/verification.dart';
export 'src/services/enrollment.dart';
export 'src/services/facematch.dart';
export 'src/services/docauth.dart';
export 'src/services/consent.dart';
export 'src/services/images.dart';
export 'src/services/deepfake.dart';
export 'src/services/transactions.dart';
export 'src/services/apikeys.dart';
