import 'package:http/http.dart' as http;

import 'transport.dart';
import 'services/sessions.dart';
import 'services/verification.dart';
import 'services/enrollment.dart';
import 'services/facematch.dart';
import 'services/docauth.dart';
import 'services/consent.dart';
import 'services/images.dart';
import 'services/deepfake.dart';
import 'services/transactions.dart';
import 'services/apikeys.dart';

/// Default Biometry API base URL.
const defaultBaseUrl = 'https://api.biometrysolutions.com';

/// Service path prefixes.
const pathGateway = '/api-gateway';
const pathGatewayV2 = '/api-gateway/v2';
const pathTransactions = '/api-transactions';
const pathProjects = '/api-projects';

/// Root Biometry SDK client, targeting the Biometry API v2 gateway
/// (/api-gateway/v2). Exposes service-specific sub-clients.
///
/// ```dart
/// final client = BiometryClient('your-api-key-jwt');
/// final sessionId = await client.sessions.start();
/// ```
///
/// Biometric operations identify the end user with an opaque, customer-provided
/// userId supplied on each call's input (not a header).
class BiometryClient {
  /// Session lifecycle operations.
  late final SessionService sessions;

  /// Biometric verification (liveness, face-verify, voice-verify).
  late final VerificationService verification;

  /// Face and voice enrollment.
  late final EnrollmentService enrollment;

  /// Face matching against a client-provided reference image.
  late final FaceMatchService faceMatch;

  /// Document authentication.
  late final DocAuthService docAuth;

  /// Consent management.
  late final ConsentService consents;

  /// User reference image (used by face-match).
  late final ImageService images;

  /// Deepfake / anti-video-forgery checks.
  late final DeepfakeService deepfake;

  /// Transaction queries.
  late final TransactionService transactions;

  /// API key management.
  late final APIKeyService apiKeys;

  /// The underlying HTTP transport.
  final BiometryTransport transport;

  /// Creates a new Biometry SDK client.
  ///
  /// [apiKey] is the API key JWT for authentication.
  /// [baseUrl] overrides the default API base URL.
  /// [httpClient] sets a custom HTTP client.
  /// [userAgent] overrides the default User-Agent header.
  BiometryClient(
    String apiKey, {
    String baseUrl = defaultBaseUrl,
    http.Client? httpClient,
    String userAgent = 'biometry-dart/0.2.0',
  }) : transport = BiometryTransport(
          httpClient: httpClient ?? http.Client(),
          baseUrl: baseUrl,
          apiKey: apiKey,
          userAgent: userAgent,
        ) {
    sessions = SessionService(transport);
    verification = VerificationService(transport);
    enrollment = EnrollmentService(transport);
    faceMatch = FaceMatchService(transport);
    docAuth = DocAuthService(transport);
    consents = ConsentService(transport);
    images = ImageService(transport);
    deepfake = DeepfakeService(transport);
    transactions = TransactionService(transport);
    apiKeys = APIKeyService(transport);
  }
}
