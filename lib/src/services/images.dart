import '../call_options.dart';
import '../client.dart';
import '../transport.dart';
import '../types.dart';

/// Handles face image upload and retrieval.
class ImageService {
  final BiometryTransport _transport;

  ImageService(this._transport);

  /// Uploads a face image associated with an email.
  Future<ImageUploadResponse> upload({
    required String email,
    required List<int> image,
    required String fileName,
    String? fullname,
    String? sessionId,
    String? actionTrigger,
    String? deviceInfo,
    String? geoLocation,
    String? requestTags,
    String? clientApp,
    String? clientVersion,
  }) {
    return _transport.doMultipart<ImageUploadResponse>(
      '$pathGateway/images',
      fields: {'email': email},
      files: [
        FileUpload(
          fieldName: 'image',
          fileName: fileName,
          content: image,
        ),
      ],
      fromJson: (data) =>
          ImageUploadResponse.fromJson(data as Map<String, dynamic>),
      extraHeaders: buildCallHeaders(
        fullname: fullname,
        sessionId: sessionId,
        actionTrigger: actionTrigger,
        deviceInfo: deviceInfo,
        geoLocation: geoLocation,
        requestTags: requestTags,
        clientApp: clientApp,
        clientVersion: clientVersion,
      ),
    );
  }

  /// Retrieves the image URL for a given email.
  Future<ImageGetResponse> get(
    String email, {
    String? fullname,
    String? sessionId,
    String? actionTrigger,
    String? deviceInfo,
    String? geoLocation,
    String? requestTags,
    String? clientApp,
    String? clientVersion,
  }) {
    return _transport.doJson<ImageGetResponse>(
      'GET',
      '$pathGateway/images/$email',
      fromJson: (data) =>
          ImageGetResponse.fromJson(data as Map<String, dynamic>),
      extraHeaders: buildCallHeaders(
        fullname: fullname,
        sessionId: sessionId,
        actionTrigger: actionTrigger,
        deviceInfo: deviceInfo,
        geoLocation: geoLocation,
        requestTags: requestTags,
        clientApp: clientApp,
        clientVersion: clientVersion,
      ),
    );
  }
}
