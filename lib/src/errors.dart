import 'dart:convert';

/// Error returned for any HTTP 4xx/5xx response from the Biometry API.
class BiometryAPIError implements Exception {
  /// The HTTP status code.
  final int statusCode;

  /// Human-readable error message extracted from the response body.
  final String message;

  /// The raw response body bytes.
  final List<int> rawBody;

  BiometryAPIError({
    required this.statusCode,
    required this.message,
    required this.rawBody,
  });

  @override
  String toString() => 'BiometryAPIError: HTTP $statusCode: $message';
}

/// Parses an API error from an HTTP response status code and body.
BiometryAPIError parseAPIError(int statusCode, List<int> body) {
  var message = '';
  try {
    final json = jsonDecode(utf8.decode(body)) as Map<String, dynamic>;
    final error = json['error'];
    if (error is String) {
      message = error;
    } else {
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
