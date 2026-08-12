import 'dart:convert';

/// Error returned for any HTTP 4xx/5xx response from the Biometry API.
class BiometryAPIError implements Exception {
  /// The HTTP status code.
  final int statusCode;

  /// Machine-readable error code from the API v2 error envelope
  /// (e.g. "invalid_request", "face_not_detected"). Empty for legacy responses.
  final String code;

  /// Human-readable error message extracted from the response body.
  final String message;

  /// The raw response body bytes.
  final List<int> rawBody;

  BiometryAPIError({
    required this.statusCode,
    this.code = '',
    required this.message,
    required this.rawBody,
  });

  @override
  String toString() => code.isNotEmpty
      ? 'BiometryAPIError: HTTP $statusCode [$code]: $message'
      : 'BiometryAPIError: HTTP $statusCode: $message';
}

/// Parses an API error from an HTTP response status code and body.
BiometryAPIError parseAPIError(int statusCode, List<int> body) {
  var code = '';
  var message = '';
  try {
    final json = jsonDecode(utf8.decode(body)) as Map<String, dynamic>;
    final error = json['error'];
    if (error is Map<String, dynamic>) {
      // API v2 error envelope: { error: { code, message }, meta }.
      code = (error['code'] as String?) ?? '';
      final msg = error['message'];
      if (msg is String) {
        message = msg;
      } else if (msg != null) {
        message = jsonEncode(msg);
      }
    } else if (error is String) {
      // Legacy shape: { error: "message" }.
      message = error;
    }
    if (message.isEmpty) {
      message = (json['message'] as String?) ?? '';
    }
  } catch (_) {
    // ignore parse errors
  }
  if (message.isEmpty) {
    message = utf8.decode(body, allowMalformed: true);
  }
  return BiometryAPIError(
    statusCode: statusCode,
    code: code,
    message: message,
    rawBody: body,
  );
}

/// Returns true if the error is a 404 API response.
bool isNotFound(Object? error) {
  return error is BiometryAPIError && error.statusCode == 404;
}

/// Returns true if the error is a 403 API response.
bool isForbidden(Object? error) {
  return error is BiometryAPIError && error.statusCode == 403;
}

/// Returns true if the error is a 401 API response.
bool isUnauthorized(Object? error) {
  return error is BiometryAPIError && error.statusCode == 401;
}
