import '../call_options.dart';
import '../client.dart';
import '../response.dart';
import '../transport.dart';
import '../types.dart';
import '../v2.dart';

/// Handles document authentication.
class DocAuthService {
  final BiometryTransport _transport;

  DocAuthService(this._transport);

  /// Verifies the authenticity of a document image (jpg, jpeg, or png).
  Future<BiometryResponse> check(
    DocAuthInput input, {
    String? deviceInfo,
    String? geoLocation,
    String? requestTags,
    String? clientApp,
    String? clientVersion,
  }) {
    return _transport.doMultipartRaw(
      '$pathGatewayV2/documents/check',
      fields: requestField(
        sessionId: input.sessionId,
        provider: input.provider,
        mrzProvider: input.mrzProvider,
      ),
      files: [
        FileUpload(
          fieldName: 'document',
          fileName: input.fileName,
          content: input.document,
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
