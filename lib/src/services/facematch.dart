import '../call_options.dart';
import '../client.dart';
import '../response.dart';
import '../transport.dart';
import '../types.dart';
import '../v2.dart';

/// Matches a live capture against a client-provided reference image.
class FaceMatchService {
  final BiometryTransport _transport;

  FaceMatchService(this._transport);

  /// Compares the live capture against the reference image.
  Future<BiometryResponse> match(
    FaceMatchInput input, {
    String? deviceInfo,
    String? geoLocation,
    String? requestTags,
    String? clientApp,
    String? clientVersion,
  }) {
    final files = <FileUpload>[
      FileUpload(
        fieldName: 'reference_image',
        fileName: input.referenceName,
        content: input.referenceImage,
      ),
    ];
    if (input.video != null) {
      files.add(FileUpload(
        fieldName: 'video',
        fileName: input.videoName ?? 'capture',
        content: input.video!,
      ));
    }

    return _transport.doMultipartRaw(
      '$pathGatewayV2/face-match',
      fields: requestField(
        userId: input.userId,
        sessionId: input.sessionId,
        useSessionVideo: input.useSessionVideo,
      ),
      files: files,
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
