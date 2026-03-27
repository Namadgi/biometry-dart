import 'package:http/http.dart' as http;

import 'transport.dart';
import 'services/sessions.dart';
import 'services/video.dart';
import 'services/enrollment.dart';
import 'services/facematch.dart';
import 'services/docauth.dart';
import 'services/consent.dart';
import 'services/images.dart';
import 'services/avf.dart';
import 'services/transactions.dart';
import 'services/apikeys.dart';

/// Default Biometry API base URL.
const defaultBaseUrl = 'https://api.biometrysolutions.com';

/// Service path prefixes.
const pathGateway = '/api-gateway';
const pathTransactions = '/api-transactions';
const pathProjects = '/api-projects';

/// Root Biometry SDK client. Exposes service-specific sub-clients.
///
/// ```dart
/// final client = BiometryClient(
///   'your-api-key-jwt',
///   userFullname: 'John Doe',
/// );
/// final sessionId = await client.sessions.start();
/// ```
class BiometryClient {
  /// Session lifecycle operations.
  late final SessionService sessions;

  /// Biometric video processing.
  late final VideoService video;

  /// Face and voice enrollment.
  late final EnrollmentService enrollment;

  /// Face matching between images and videos.
  late final FaceMatchService faceMatch;

  /// Document authentication.
  late final DocAuthService docAuth;

  /// Consent management.
  late final ConsentService consents;

  /// Face image upload and retrieval.
  late final ImageService images;

  /// Anti-video-forgery inference.
  late final AVFService avf;

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
  /// [userFullname] sets the default X-User-Fullname header.
  /// [userAgent] overrides the default User-Agent header.
  BiometryClient(
    String apiKey, {
    String baseUrl = defaultBaseUrl,
    http.Client? httpClient,
    String userFullname = '',
    String userAgent = 'biometry-dart/0.1.0',
  }) : transport = BiometryTransport(
          httpClient: httpClient ?? http.Client(),
          baseUrl: baseUrl,
          apiKey: apiKey,
          userFullname: userFullname,
          userAgent: userAgent,
        ) {
    sessions = SessionService(transport);
    video = VideoService(transport);
    enrollment = EnrollmentService(transport);
    faceMatch = FaceMatchService(transport);
    docAuth = DocAuthService(transport);
    consents = ConsentService(transport);
    images = ImageService(transport);
    avf = AVFService(transport);
    transactions = TransactionService(transport);
    apiKeys = APIKeyService(transport);
  }
}
