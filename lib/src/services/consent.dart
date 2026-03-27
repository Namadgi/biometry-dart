import '../call_options.dart';
import '../client.dart';
import '../transport.dart';
import '../types.dart';

/// Handles custom consent approvals (API-key-authenticated only).
class ConsentService {
  final BiometryTransport _transport;

  ConsentService(this._transport);

  /// Approves a custom consent for a user.
  Future<void> approve(
    String consentId,
    String userId, {
    String? fullname,
    String? sessionId,
    String? actionTrigger,
    String? deviceInfo,
    String? geoLocation,
    String? requestTags,
    String? clientApp,
    String? clientVersion,
  }) {
    return _transport.doJson<void>(
      'POST',
      '$pathGateway/custom-consents/$consentId/approve/$userId',
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

  /// Returns the consent approvals for a user.
  Future<List<ConsentApproval>> myApprovals(
    String userId, {
    String? fullname,
    String? sessionId,
    String? actionTrigger,
    String? deviceInfo,
    String? geoLocation,
    String? requestTags,
    String? clientApp,
    String? clientVersion,
  }) {
    return _transport.doJson<List<ConsentApproval>>(
      'GET',
      '$pathGateway/custom-consents/my-approvals/$userId',
      fromJson: (data) {
        if (data is List) {
          return data
              .map((e) =>
                  ConsentApproval.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return [];
      },
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
