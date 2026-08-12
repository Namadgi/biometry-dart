import '../call_options.dart';
import '../client.dart';
import '../transport.dart';
import '../types.dart';
import '../v2.dart';

/// Handles asynchronous deepfake / anti-video-forgery checks.
class DeepfakeService {
  final BiometryTransport _transport;

  DeepfakeService(this._transport);

  /// Sends a video for deepfake analysis and returns the created check.
  Future<DeepfakeCheck> submit(
    DeepfakeInput input, {
    String? deviceInfo,
    String? geoLocation,
    String? requestTags,
    String? clientApp,
    String? clientVersion,
  }) {
    return _transport.doMultipart<DeepfakeCheck>(
      '$pathGatewayV2/deepfake/checks',
      fields: requestField(userId: input.userId, sessionId: input.sessionId),
      files: [
        FileUpload(
          fieldName: 'video',
          fileName: input.fileName,
          content: input.video,
        ),
      ],
      fromJson: (data) => DeepfakeCheck.fromJson(data as Map<String, dynamic>),
      extraHeaders: buildCallHeaders(
        deviceInfo: deviceInfo,
        geoLocation: geoLocation,
        requestTags: requestTags,
        clientApp: clientApp,
        clientVersion: clientVersion,
      ),
    );
  }

  /// Retrieves the current state and results of a deepfake check.
  Future<DeepfakeCheck> status(
    String requestId, {
    String? deviceInfo,
    String? geoLocation,
    String? requestTags,
    String? clientApp,
    String? clientVersion,
  }) {
    return _transport.doJson<DeepfakeCheck>(
      'GET',
      '$pathGatewayV2/deepfake/checks/$requestId',
      fromJson: (data) => DeepfakeCheck.fromJson(data as Map<String, dynamic>),
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
