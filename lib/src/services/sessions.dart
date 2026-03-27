import '../call_options.dart';
import '../client.dart';
import '../transport.dart';
import '../types.dart';

/// Handles biometric session lifecycle.
class SessionService {
  final BiometryTransport _transport;

  SessionService(this._transport);

  /// Begins a new biometric session and returns the session ID.
  Future<String> start({
    String? fullname,
    String? sessionId,
    String? actionTrigger,
    String? deviceInfo,
    String? geoLocation,
    String? requestTags,
    String? clientApp,
    String? clientVersion,
  }) {
    return _transport.doJson<String>(
      'POST',
      '$pathGateway/sessions/start',
      fromJson: (data) => data as String,
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

  /// Terminates a session by ID.
  Future<void> end(
    String id, {
    EndSessionRequest? request,
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
      '$pathGateway/sessions/end/$id',
      payload: request?.toJson(),
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
