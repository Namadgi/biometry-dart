import '../call_options.dart';
import '../client.dart';
import '../response.dart';
import '../transport.dart';
import '../types.dart';
import '../v2.dart';

/// Handles biometric verification. API v2 splits the v1 process-video call into
/// three focused operations: [liveness], [faceVerify], and [voiceVerify].
class VerificationService {
  VerificationService(this._transport);

  final BiometryTransport _transport;

  /// Runs the liveness pipeline (face liveness, active speaker, visual speech).
  Future<BiometryResponse> liveness(
    LivenessInput input, {
    String? deviceInfo,
    String? geoLocation,
    String? requestTags,
    String? clientApp,
    String? clientVersion,
  }) {
    return _transport.doMultipartRaw(
      '$pathGatewayV2/liveness',
      fields: requestField(
        userId: input.userId,
        phrase: input.phrase,
        vocabulary: input.vocabulary,
        trigger: input.trigger,
        sessionId: input.sessionId,
        excludeServices: input.excludeServices,
      ),
      files: [
        FileUpload(
          fieldName: 'video',
          fileName: input.fileName,
          content: input.video,
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

  /// Verifies the face against the user's enrolled face template.
  Future<BiometryResponse> faceVerify(
    VerifyInput input, {
    String? deviceInfo,
    String? geoLocation,
    String? requestTags,
    String? clientApp,
    String? clientVersion,
  }) {
    return _verify('/face-verify', 'video', input,
        deviceInfo: deviceInfo,
        geoLocation: geoLocation,
        requestTags: requestTags,
        clientApp: clientApp,
        clientVersion: clientVersion);
  }

  /// Verifies the voice against the user's enrolled voice template.
  Future<BiometryResponse> voiceVerify(
    VerifyInput input, {
    String? deviceInfo,
    String? geoLocation,
    String? requestTags,
    String? clientApp,
    String? clientVersion,
  }) {
    return _verify('/voice-verify', 'voice', input,
        deviceInfo: deviceInfo,
        geoLocation: geoLocation,
        requestTags: requestTags,
        clientApp: clientApp,
        clientVersion: clientVersion);
  }

  Future<BiometryResponse> _verify(
    String path,
    String fileField,
    VerifyInput input, {
    String? deviceInfo,
    String? geoLocation,
    String? requestTags,
    String? clientApp,
    String? clientVersion,
  }) {
    return _transport.doMultipartRaw(
      '$pathGatewayV2$path',
      fields: requestField(
        userId: input.userId,
        phrase: input.phrase,
        vocabulary: input.vocabulary,
        sessionId: input.sessionId,
        useSessionVideo: input.useSessionVideo,
      ),
      files: input.media != null
          ? [
              FileUpload(
                fieldName: fileField,
                fileName: input.fileName ?? 'capture',
                content: input.media!,
              ),
            ]
          : const [],
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
