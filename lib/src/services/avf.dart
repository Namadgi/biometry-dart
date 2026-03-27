import '../call_options.dart';
import '../client.dart';
import '../transport.dart';
import '../types.dart';

/// Handles anti-video-forgery inference.
class AVFService {
  final BiometryTransport _transport;

  AVFService(this._transport);

  /// Submits a video for anti-forgery analysis.
  Future<AVFInferenceResponse> startInference({
    required List<int> video,
    required String videoName,
    String? fullname,
    String? sessionId,
    String? actionTrigger,
    String? deviceInfo,
    String? geoLocation,
    String? requestTags,
    String? clientApp,
    String? clientVersion,
  }) {
    return _transport.doMultipart<AVFInferenceResponse>(
      '$pathGateway/avf/infer',
      files: [
        FileUpload(
          fieldName: 'video',
          fileName: videoName,
          content: video,
        ),
      ],
      fromJson: (data) =>
          AVFInferenceResponse.fromJson(data as Map<String, dynamic>),
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

  /// Checks the status of an AVF inference request.
  Future<AVFStatusResponse> checkStatus(
    String requestId, {
    String? fullname,
    String? sessionId,
    String? actionTrigger,
    String? deviceInfo,
    String? geoLocation,
    String? requestTags,
    String? clientApp,
    String? clientVersion,
  }) {
    return _transport.doJson<AVFStatusResponse>(
      'GET',
      '$pathGateway/avf/status/$requestId',
      fromJson: (data) =>
          AVFStatusResponse.fromJson(data as Map<String, dynamic>),
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
