import 'dart:convert';

import 'package:http/http.dart' as http;

import 'errors.dart';
import 'response.dart';

/// Represents a file to be uploaded via multipart.
class FileUpload {
  final String fieldName;
  final String fileName;
  final List<int> content;

  FileUpload({
    required this.fieldName,
    required this.fileName,
    required this.content,
  });
}

/// Low-level HTTP transport for the Biometry API.
///
/// Handles authentication, header injection, JSON/multipart encoding,
/// response envelope unwrapping, and error parsing.
class BiometryTransport {
  final http.Client httpClient;
  final String baseUrl;
  final String apiKey;
  final String userFullname;
  final String userAgent;

  BiometryTransport({
    required this.httpClient,
    required this.baseUrl,
    required this.apiKey,
    this.userFullname = '',
    this.userAgent = 'biometry-dart/0.1.0',
  });

  /// Builds standard headers for every request.
  Map<String, String> _baseHeaders() {
    final headers = <String, String>{
      'Authorization': 'Bearer $apiKey',
      'User-Agent': userAgent,
    };
    if (userFullname.isNotEmpty) {
      headers['X-User-Fullname'] = userFullname;
    }
    return headers;
  }

  /// Sends a JSON request and decodes the "data" field from the response
  /// envelope into [T] using [fromJson]. Pass null for [fromJson] to discard
  /// the response body.
  Future<T> doJson<T>(
    String method,
    String path, {
    Object? payload,
    T Function(dynamic json)? fromJson,
    Map<String, String> extraHeaders = const {},
  }) async {
    final headers = _baseHeaders()..addAll(extraHeaders);
    List<int>? bodyBytes;
    if (payload != null) {
      bodyBytes = utf8.encode(jsonEncode(payload));
      headers['Content-Type'] = 'application/json';
    }

    final uri = Uri.parse('$baseUrl$path');
    final request = http.Request(method, uri)..headers.addAll(headers);
    if (bodyBytes != null) {
      request.bodyBytes = bodyBytes;
    }

    final streamed = await httpClient.send(request);
    final responseBody = await streamed.stream.toBytes();

    if (streamed.statusCode >= 400) {
      throw parseAPIError(streamed.statusCode, responseBody);
    }

    if (fromJson == null) {
      return null as T;
    }

    final envelope =
        jsonDecode(utf8.decode(responseBody)) as Map<String, dynamic>;
    final data = envelope['data'];
    return fromJson(data);
  }

  /// Sends a multipart/form-data request and decodes the "data" field
  /// into [T] using [fromJson].
  Future<T> doMultipart<T>(
    String path, {
    Map<String, String> fields = const {},
    List<FileUpload> files = const [],
    T Function(dynamic json)? fromJson,
    Map<String, String> extraHeaders = const {},
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final request = http.MultipartRequest('POST', uri)
      ..headers.addAll(_baseHeaders())
      ..headers.addAll(extraHeaders)
      ..fields.addAll(fields);

    for (final file in files) {
      request.files.add(http.MultipartFile.fromBytes(
        file.fieldName,
        file.content,
        filename: file.fileName,
      ));
    }

    final streamed = await httpClient.send(request);
    final responseBody = await streamed.stream.toBytes();

    if (streamed.statusCode >= 400) {
      throw parseAPIError(streamed.statusCode, responseBody);
    }

    if (fromJson == null) {
      return null as T;
    }

    final envelope =
        jsonDecode(utf8.decode(responseBody)) as Map<String, dynamic>;
    final data = envelope['data'];
    return fromJson(data);
  }

  /// Sends a multipart request and returns the full [BiometryResponse]
  /// envelope (for endpoints that return scoring data).
  Future<BiometryResponse> doMultipartRaw(
    String path, {
    Map<String, String> fields = const {},
    List<FileUpload> files = const [],
    Map<String, String> extraHeaders = const {},
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final request = http.MultipartRequest('POST', uri)
      ..headers.addAll(_baseHeaders())
      ..headers.addAll(extraHeaders)
      ..fields.addAll(fields);

    for (final file in files) {
      request.files.add(http.MultipartFile.fromBytes(
        file.fieldName,
        file.content,
        filename: file.fileName,
      ));
    }

    final streamed = await httpClient.send(request);
    final responseBody = await streamed.stream.toBytes();

    if (streamed.statusCode >= 400) {
      throw parseAPIError(streamed.statusCode, responseBody);
    }

    final json =
        jsonDecode(utf8.decode(responseBody)) as Map<String, dynamic>;
    return BiometryResponse.fromJson(json, streamed.headers);
  }

  /// Sends a raw GET/POST request and returns the full [BiometryResponse].
  Future<BiometryResponse> doRaw(
    String method,
    String path, {
    Object? payload,
    Map<String, String> extraHeaders = const {},
  }) async {
    final headers = _baseHeaders()..addAll(extraHeaders);
    List<int>? bodyBytes;
    if (payload != null) {
      bodyBytes = utf8.encode(jsonEncode(payload));
      headers['Content-Type'] = 'application/json';
    }

    final uri = Uri.parse('$baseUrl$path');
    final request = http.Request(method, uri)..headers.addAll(headers);
    if (bodyBytes != null) {
      request.bodyBytes = bodyBytes;
    }

    final streamed = await httpClient.send(request);
    final responseBody = await streamed.stream.toBytes();

    if (streamed.statusCode >= 400) {
      throw parseAPIError(streamed.statusCode, responseBody);
    }

    final json =
        jsonDecode(utf8.decode(responseBody)) as Map<String, dynamic>;
    return BiometryResponse.fromJson(json, streamed.headers);
  }
}
