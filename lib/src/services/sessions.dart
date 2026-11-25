import '../call_options.dart';
import '../client.dart';
import '../transport.dart';
import '../types.dart';

/// Handles biometric session lifecycle.
class SessionService {
  SessionService(this._transport);

  final BiometryTransport _transport;

  /// Begins a new biometric session and returns the session ID.
  Future<String> start({
    String? deviceInfo,
    String? geoLocation,
    String? requestTags,
    String? clientApp,
    String? clientVersion,
  }) {
    return _transport.doJson<String>(
      'POST',
      '$pathGatewayV2/sessions',
      fromJson: (data) =>
          (data as Map<String, dynamic>)['session_id'] as String,
      extraHeaders: buildCallHeaders(
        deviceInfo: deviceInfo,
        geoLocation: geoLocation,
        requestTags: requestTags,
        clientApp: clientApp,
        clientVersion: clientVersion,
      ),
    );
  }

  /// Terminates a session by ID. Pass [request] to run a SIM-swap check.
  Future<void> end(
    String id, {
    EndSessionRequest? request,
    String? deviceInfo,
    String? geoLocation,
    String? requestTags,
    String? clientApp,
    String? clientVersion,
  }) {
    return _transport.doJson<void>(
      'POST',
      '$pathGatewayV2/sessions/$id/end',
      payload: request?.toJson(),
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
