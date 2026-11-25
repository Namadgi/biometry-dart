import '../call_options.dart';
import '../client.dart';
import '../transport.dart';
import '../types.dart';

/// Manages API keys via the public endpoints.
class APIKeyService {
  APIKeyService(this._transport);

  final BiometryTransport _transport;

  /// Creates a new API key.
  Future<APIKeyInfo> mint({
    String? fullname,
    String? sessionId,
    String? actionTrigger,
    String? deviceInfo,
    String? geoLocation,
    String? requestTags,
    String? clientApp,
    String? clientVersion,
  }) {
    return _transport.doJson<APIKeyInfo>(
      'POST',
      '$pathProjects/public/apikeys',
      fromJson: (data) => APIKeyInfo.fromJson(data as Map<String, dynamic>),
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

  /// Revokes (deletes) an API key by ID.
  Future<void> revoke(
    String keyId, {
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
      'DELETE',
      '$pathProjects/public/apikeys/$keyId',
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

  /// Returns information about the current API key.
  Future<APIKeyInfo> info({
    String? fullname,
    String? sessionId,
    String? actionTrigger,
    String? deviceInfo,
    String? geoLocation,
    String? requestTags,
    String? clientApp,
    String? clientVersion,
  }) {
    return _transport.doJson<APIKeyInfo>(
      'GET',
      '$pathProjects/public/apikeys',
      fromJson: (data) => APIKeyInfo.fromJson(data as Map<String, dynamic>),
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
