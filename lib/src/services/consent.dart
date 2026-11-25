import '../call_options.dart';
import '../client.dart';
import '../transport.dart';
import '../types.dart';

/// Records user consent ([give], [revoke], [status]) and custom consent
/// template approvals ([approve], [myApprovals]).
class ConsentService {
  ConsentService(this._transport);

  final BiometryTransport _transport;

  /// Records that the user consents to Biometry processing ([authorization])
  /// and/or storing ([storage]) their biometric data:
  /// `PUT /v2/users/{user_id}/consents`. Both default to `true`.
  ///
  /// Face and voice enrollment require both consents and fail with 403
  /// without them; `images.upload()` requires authorization consent. Collect
  /// the user's agreement in your app first. Giving a consent the user
  /// already gave is a no-op.
  ///
  /// [sessionId] optionally links the consent to a session, so it shows with
  /// that session in the Console.
  ///
  /// Returns the user's consent state after the change. Throws an
  /// [ArgumentError] before any request if both are `false`.
  Future<UserConsents> give(
    String userId, {
    bool authorization = true,
    bool storage = true,
    String? sessionId,
    String? deviceInfo,
    String? geoLocation,
    String? requestTags,
    String? clientApp,
    String? clientVersion,
  }) {
    return _set(
      userId,
      given: true,
      authorization: authorization,
      storage: storage,
      sessionId: sessionId,
      headers: buildCallHeaders(
        deviceInfo: deviceInfo,
        geoLocation: geoLocation,
        requestTags: requestTags,
        clientApp: clientApp,
        clientVersion: clientVersion,
      ),
    );
  }

  /// Withdraws the user's [authorization] and/or [storage] consent (both
  /// default to `true`, i.e. withdraw both). Enrollment fails with 403
  /// afterwards until [give] is called again. Revoking a consent the user
  /// never gave is a no-op.
  ///
  /// Returns the user's consent state after the change. Throws an
  /// [ArgumentError] before any request if both are `false`.
  Future<UserConsents> revoke(
    String userId, {
    bool authorization = true,
    bool storage = true,
    String? sessionId,
    String? deviceInfo,
    String? geoLocation,
    String? requestTags,
    String? clientApp,
    String? clientVersion,
  }) {
    return _set(
      userId,
      given: false,
      authorization: authorization,
      storage: storage,
      sessionId: sessionId,
      headers: buildCallHeaders(
        deviceInfo: deviceInfo,
        geoLocation: geoLocation,
        requestTags: requestTags,
        clientApp: clientApp,
        clientVersion: clientVersion,
      ),
    );
  }

  /// Returns the user's authorization and storage consent:
  /// `GET /v2/users/{user_id}/consents`. A user who never gave consent has
  /// both `false`.
  Future<UserConsents> status(
    String userId, {
    String? deviceInfo,
    String? geoLocation,
    String? requestTags,
    String? clientApp,
    String? clientVersion,
  }) {
    return _transport.doJson<UserConsents>(
      'GET',
      _userConsentsPath(userId),
      fromJson: _parseUserConsents,
      extraHeaders: buildCallHeaders(
        deviceInfo: deviceInfo,
        geoLocation: geoLocation,
        requestTags: requestTags,
        clientApp: clientApp,
        clientVersion: clientVersion,
      ),
    );
  }

  Future<UserConsents> _set(
    String userId, {
    required bool given,
    required bool authorization,
    required bool storage,
    required String? sessionId,
    required Map<String, String> headers,
  }) async {
    if (!authorization && !storage) {
      throw ArgumentError(
        'At least one of authorization or storage must be true',
      );
    }
    return _transport.doJson<UserConsents>(
      'PUT',
      _userConsentsPath(userId),
      payload: {
        if (authorization) 'authorization': given,
        if (storage) 'storage': given,
        if (sessionId != null && sessionId.isNotEmpty) 'session_id': sessionId,
      },
      fromJson: _parseUserConsents,
      extraHeaders: headers,
    );
  }

  static String _userConsentsPath(String userId) =>
      '$pathGatewayV2/users/${Uri.encodeComponent(userId)}/consents';

  static UserConsents _parseUserConsents(dynamic data) =>
      UserConsents.fromJson(
        data is Map<String, dynamic> ? data : const <String, dynamic>{},
      );

  /// Records the user's approval of one of your project's custom consent
  /// templates. It does not give the authorization and storage consent that
  /// enrollment requires; use [give] for that.
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

  /// Returns the user's custom consent template approvals.
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
