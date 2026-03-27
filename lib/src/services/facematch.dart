import '../call_options.dart';
import '../client.dart';
import '../response.dart';
import '../transport.dart';

/// Handles face matching between images and videos.
class FaceMatchService {
  final BiometryTransport _transport;

  FaceMatchService(this._transport);

  /// Compares faces from an uploaded image and video.
  Future<BiometryResponse> match({
    required List<int> image,
    required String imageName,
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
    return _transport.doMultipartRaw(
      '$pathGateway/match-faces',
      files: [
        FileUpload(
          fieldName: 'image',
          fileName: imageName,
          content: image,
        ),
        FileUpload(
          fieldName: 'video',
          fileName: videoName,
          content: video,
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

  /// Compares a face image against the video from a previous process-video
  /// call in the given session, avoiding re-upload.
  Future<BiometryResponse> matchWithSessionVideo({
    required List<int> image,
    required String imageName,
    required String sessionId,
    String? fullname,
    String? actionTrigger,
    String? deviceInfo,
    String? geoLocation,
    String? requestTags,
    String? clientApp,
    String? clientVersion,
  }) {
    final headers = buildCallHeaders(
      fullname: fullname,
      sessionId: sessionId,
      actionTrigger: actionTrigger,
      deviceInfo: deviceInfo,
      geoLocation: geoLocation,
      requestTags: requestTags,
      clientApp: clientApp,
      clientVersion: clientVersion,
    );
    headers['X-Use-Prefilled-Video'] = 'true';
    headers['X-Session-ID'] = sessionId;

    return _transport.doMultipartRaw(
      '$pathGateway/match-faces',
      files: [
        FileUpload(
          fieldName: 'image',
          fileName: imageName,
          content: image,
        ),
      ],
      extraHeaders: headers,
    );
  }
}
