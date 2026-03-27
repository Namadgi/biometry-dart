import '../call_options.dart';
import '../client.dart';
import '../response.dart';
import '../transport.dart';
import '../types.dart';

/// Handles biometric video processing.
class VideoService {
  final BiometryTransport _transport;

  VideoService(this._transport);

  /// Sends a video for biometric verification.
  ///
  /// Returns the full [BiometryResponse] envelope which includes scoring
  /// results, score, and decision reasons.
  Future<BiometryResponse> process(
    ProcessVideoInput input, {
    String? fullname,
    String? sessionId,
    String? actionTrigger,
    String? deviceInfo,
    String? geoLocation,
    String? requestTags,
    String? clientApp,
    String? clientVersion,
  }) {
    final fields = <String, String>{'phrase': input.phrase};
    if (input.vocabulary != null) fields['vocabulary'] = input.vocabulary!;
    if (input.trigger != null) fields['trigger'] = input.trigger!;

    return _transport.doMultipartRaw(
      '$pathGateway/process-video',
      fields: fields,
      files: [
        FileUpload(
          fieldName: 'video',
          fileName: input.videoName,
          content: input.video,
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
}
