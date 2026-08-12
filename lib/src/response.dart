import 'dart:convert';

/// Scoring decision computed for a request when a scoring system applies.
class Decision {
  final String? status;
  final double? score;
  final List<String> reasons;

  Decision({this.status, this.score, this.reasons = const []});

  factory Decision.fromJson(Map<String, dynamic> json) {
    final reasons = json['reasons'];
    return Decision(
      status: json['status'] as String?,
      score: (json['score'] as num?)?.toDouble(),
      reasons:
          reasons is List ? reasons.map((e) => e.toString()).toList() : const [],
    );
  }
}

/// Response metadata attached to every API v2 response.
class ResponseMeta {
  final String? requestId;
  final String? message;

  ResponseMeta({this.requestId, this.message});

  factory ResponseMeta.fromJson(Map<String, dynamic> json) {
    return ResponseMeta(
      requestId: json['request_id'] as String?,
      message: json['message'] as String?,
    );
  }
}

/// Full API v2 success envelope. Used for verification endpoints (liveness,
/// face-verify, voice-verify, face-match, documents/check) that may carry a
/// scoring decision alongside the raw service data.
class BiometryResponse {
  /// Raw JSON from the "data" field.
  final dynamic data;

  /// Scoring decision, present only when a scoring system applies to the API key.
  final Decision? decision;

  /// Response metadata (request ID, message).
  final ResponseMeta meta;

  /// Raw HTTP response headers.
  final Map<String, String> headers;

  BiometryResponse({
    this.data,
    this.decision,
    ResponseMeta? meta,
    this.headers = const {},
  }) : meta = meta ?? ResponseMeta();

  /// Creates a [BiometryResponse] from a JSON map and response headers.
  factory BiometryResponse.fromJson(
    Map<String, dynamic> json,
    Map<String, String> headers,
  ) {
    final decision = json['decision'];
    final meta = json['meta'];
    return BiometryResponse(
      data: json['data'],
      decision: decision is Map<String, dynamic>
          ? Decision.fromJson(decision)
          : null,
      meta: meta is Map<String, dynamic>
          ? ResponseMeta.fromJson(meta)
          : ResponseMeta(),
      headers: headers,
    );
  }

  /// Decodes the [data] field into a typed object using [fromJson].
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

  /// The request identifier, preferring the envelope meta and falling back to
  /// the X-Request-Id response header.
  String get requestId =>
      meta.requestId ?? headers['x-request-id'] ?? '';
}
