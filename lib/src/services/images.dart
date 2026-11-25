import '../call_options.dart';
import '../client.dart';
import '../transport.dart';

/// Manages a user's reference image (used by face-match).
class ImageService {
  ImageService(this._transport);

  final BiometryTransport _transport;

  /// Stores the reference image for the given user. Requires an approved
  /// consent for the user.
  Future<void> upload({
    required String userId,
    required List<int> image,
    required String fileName,
    String? deviceInfo,
    String? geoLocation,
    String? requestTags,
    String? clientApp,
    String? clientVersion,
  }) {
    return _transport.doMultipart<void>(
      '$pathGatewayV2/users/$userId/reference-image',
      method: 'PUT',
      files: [
        FileUpload(
          fieldName: 'image',
          fileName: fileName,
          content: image,
        ),
      ],
      extraHeaders: buildCallHeaders(
        deviceInfo: deviceInfo,
        geoLocation: geoLocation,
        requestTags: requestTags,
        clientApp: clientApp,
        clientVersion: clientVersion,
      ),
    );
  }

  /// Downloads the stored reference image bytes for the given user.
  Future<List<int>> get(
    String userId, {
    String? deviceInfo,
    String? geoLocation,
    String? requestTags,
    String? clientApp,
    String? clientVersion,
  }) {
    return _transport.doBytes(
      'GET',
      '$pathGatewayV2/users/$userId/reference-image',
      extraHeaders: buildCallHeaders(
        deviceInfo: deviceInfo,
        geoLocation: geoLocation,
        requestTags: requestTags,
        clientApp: clientApp,
        clientVersion: clientVersion,
      ),
    );
  }
}
