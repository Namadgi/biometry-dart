import 'dart:convert';

/// Full API response envelope. Used for endpoints like process-video and
/// match-faces that return scoring data alongside the result.
class BiometryResponse {
  /// Raw JSON data from the "data" field.
  final dynamic data;

  /// Raw scoring result object.
  final dynamic scoringResult;

  /// Numeric score (e.g. face match confidence).
  final double score;

  /// Reasons that led to the scoring decision.
  final List<String> decisionReasons;

  /// Server message.
  final String message;

  /// Raw HTTP response headers.
  final Map<String, String> headers;

  BiometryResponse({
    this.data,
    this.scoringResult,
    this.score = 0,
    this.decisionReasons = const [],
    this.message = '',
    this.headers = const {},
  });

  /// Creates a [BiometryResponse] from a JSON map and response headers.
  factory BiometryResponse.fromJson(
    Map<String, dynamic> json,
    Map<String, String> headers,
  ) {
    final reasons = json['decision_reasons'];
    return BiometryResponse(
      data: json['data'],
      scoringResult: json['scoring_result'],
      score: (json['score'] as num?)?.toDouble() ?? 0,
      decisionReasons: reasons is List
          ? reasons.map((e) => e.toString()).toList()
          : const [],
      message: (json['message'] as String?) ?? '',
      headers: headers,
    );
  }

  /// Decodes the [data] field into a typed object using the provided
  /// [fromJson] factory.
  T decode<T>(T Function(Map<String, dynamic>) fromJson) {
    if (data is Map<String, dynamic>) {
      return fromJson(data as Map<String, dynamic>);
    }
    throw StateError(
      'Cannot decode data: expected Map<String, dynamic>, got ${data.runtimeType}',
    );
  }

  /// Returns the raw data field as a JSON string.
  String get dataJson => jsonEncode(data);

  /// Returns the X-Request-Id response header value.
  String get requestId => headers['x-request-id'] ?? '';

  /// Returns true if X-Auto-Enroll response header is "true".
  bool get autoEnrolled => headers['x-auto-enroll'] == 'true';

  /// Returns true if X-Removed-Services response header is "true".
  bool get removedServices => headers['x-removed-services'] == 'true';
}
