import '../call_options.dart';
import '../client.dart';
import '../response.dart';
import '../transport.dart';

/// Handles document authentication.
class DocAuthService {
  final BiometryTransport _transport;

  DocAuthService(this._transport);

  /// Verifies the authenticity of a document image (jpg, jpeg, or png).
  Future<BiometryResponse> check({
    required List<int> document,
    required String fileName,
    String? fullname,
    String? sessionId,
    String? actionTrigger,
    String? deviceInfo,
    String? geoLocation,
    String? requestTags,
    String? clientApp,
    String? clientVersion,
    bool? inhouseDocAuth,
    bool? mrzValidation,
  }) {
    return _transport.doMultipartRaw(
      '$pathGateway/docauth/check',
      files: [
        FileUpload(
          fieldName: 'document',
          fileName: fileName,
          content: document,
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
        inhouseDocAuth: inhouseDocAuth,
        mrzValidation: mrzValidation,
      ),
    );
  }
}
