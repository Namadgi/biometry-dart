import '../call_options.dart';
import '../client.dart';
import '../response.dart';
import '../transport.dart';
import '../types.dart';
import '../v2.dart';

/// Handles face and voice enrollment.
class EnrollmentService {
  EnrollmentService(this._transport);

  final BiometryTransport _transport;

  /// Enrolls a face image for recognition.
  Future<BiometryResponse> face(
    EnrollFaceInput input, {
    String? deviceInfo,
    String? geoLocation,
    String? requestTags,
    String? clientApp,
    String? clientVersion,
  }) {
    return _transport.doMultipartRaw(
      '$pathGatewayV2/enrollments/face',
      fields: requestField(userId: input.userId, isDocument: input.isDocument),
      files: [
        FileUpload(
          fieldName: 'face',
          fileName: input.fileName,
          content: input.face,
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

  /// Enrolls a voice recording for recognition.
  Future<BiometryResponse> voice(
    EnrollVoiceInput input, {
    String? deviceInfo,
    String? geoLocation,
    String? requestTags,
    String? clientApp,
    String? clientVersion,
  }) {
    return _transport.doMultipartRaw(
      '$pathGatewayV2/enrollments/voice',
      fields: requestField(
        userId: input.userId,
        phrase: input.phrase,
        vocabulary: input.vocabulary,
      ),
      files: [
        FileUpload(
          fieldName: 'voice',
          fileName: input.fileName,
          content: input.voice,
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
}
