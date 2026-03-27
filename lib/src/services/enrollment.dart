import '../call_options.dart';
import '../client.dart';
import '../response.dart';
import '../transport.dart';
import '../types.dart';

/// Handles face and voice enrollment.
class EnrollmentService {
  final BiometryTransport _transport;

  EnrollmentService(this._transport);

  /// Enrolls a face image for recognition.
  Future<BiometryResponse> face(
    EnrollFaceInput input, {
    String? fullname,
    String? sessionId,
    String? actionTrigger,
    String? deviceInfo,
    String? geoLocation,
    String? requestTags,
    String? clientApp,
    String? clientVersion,
  }) {
    final fields = <String, String>{};
    if (input.isDocument) fields['is_document'] = 'true';

    return _transport.doMultipartRaw(
      '$pathGateway/enroll/face',
      fields: fields,
      files: [
        FileUpload(
          fieldName: 'face',
          fileName: input.fileName,
          content: input.face,
        ),
      ],
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

  /// Enrolls voice recordings for recognition.
  Future<BiometryResponse> voice(
    EnrollVoiceInput input, {
    String? fullname,
    String? sessionId,
    String? actionTrigger,
    String? deviceInfo,
    String? geoLocation,
    String? requestTags,
    String? clientApp,
    String? clientVersion,
  }) {
    final fields = <String, String>{
      'phrase': input.phrases.join(','),
    };
    if (input.vocabulary != null) fields['vocabulary'] = input.vocabulary!;

    return _transport.doMultipartRaw(
      '$pathGateway/enroll/voice',
      fields: fields,
      files: input.files
          .map((f) => FileUpload(
                fieldName: 'voice',
                fileName: f.fileName,
                content: f.content,
              ))
          .toList(),
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
