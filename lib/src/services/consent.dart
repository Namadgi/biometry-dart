import '../call_options.dart';
import '../client.dart';
import '../transport.dart';
import '../types.dart';

/// Handles consent approvals (API-key-authenticated only).
class ConsentService {
  ConsentService(this._transport);

  final BiometryTransport _transport;

  /// Approves a consent for a user.
  Future<void> approve(
    String consentId,
    String userId, {
    String? deviceInfo,
    String? geoLocation,
    String? requestTags,
    String? clientApp,
    String? clientVersion,
  }) {
    return _transport.doJson<void>(
      'POST',
      '$pathGatewayV2/consents/$consentId/approve/$userId',
      extraHeaders: buildCallHeaders(
        deviceInfo: deviceInfo,
        geoLocation: geoLocation,
        requestTags: requestTags,
        clientApp: clientApp,
        clientVersion: clientVersion,
      ),
    );
  }

  /// Returns the consent approvals for a user.
  Future<List<ConsentApproval>> myApprovals(
    String userId, {
    String? deviceInfo,
    String? geoLocation,
    String? requestTags,
    String? clientApp,
    String? clientVersion,
  }) {
    return _transport.doJson<List<ConsentApproval>>(
      'GET',
      '$pathGatewayV2/consents/my-approvals/$userId',
      fromJson: (data) {
        if (data is List) {
          return data
              .map((e) => ConsentApproval.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return [];
      },
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
