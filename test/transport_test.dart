import 'dart:convert';
import 'dart:io';

import 'package:biometry_api/biometry_api.dart';
import 'package:biometry_api/src/transport.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

/// Creates a local HTTP server and a [BiometryTransport] pointing at it.
Future<(BiometryTransport, HttpServer)> testTransport(
  Future<void> Function(HttpRequest) handler,
) async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  server.listen(handler);
  final transport = BiometryTransport(
    httpClient: http.Client(),
    baseUrl: 'http://localhost:${server.port}',
    apiKey: 'test-api-key',
  );
  return (transport, server);
}

void main() {
  group('doJson', () {
    test('sends auth + user-agent headers, decodes data envelope', () async {
      final (transport, server) = await testTransport((req) async {
        expect(req.headers.value('authorization'), 'Bearer test-api-key');
        expect(req.headers.value('user-agent'), startsWith('biometry-dart/'));
        expect(req.headers.value('content-type'), contains('application/json'));

        req.response.statusCode = 200;
        req.response.headers.contentType = ContentType.json;
        req.response.write(jsonEncode({
          'data': {'id': '123'},
          'meta': <String, dynamic>{},
        }));
        await req.response.close();
      });

      try {
        final result = await transport.doJson<Map<String, dynamic>>(
          'POST',
          '/test',
          payload: {'key': 'val'},
          fromJson: (data) => data as Map<String, dynamic>,
        );
        expect(result['id'], '123');
      } finally {
        await server.close();
      }
    });

    test('throws BiometryAPIError with code on a v2 error envelope', () async {
      final (transport, server) = await testTransport((req) async {
        req.response.statusCode = 422;
        req.response.headers.contentType = ContentType.json;
        req.response.write(jsonEncode({
          'error': {'code': 'face_not_detected', 'message': 'no face detected'},
          'meta': {'request_id': 'r9'},
        }));
        await req.response.close();
      });

      try {
        await expectLater(
          transport.doJson<void>('POST', '/test'),
          throwsA(isA<BiometryAPIError>()
              .having((e) => e.statusCode, 'statusCode', 422)
              .having((e) => e.code, 'code', 'face_not_detected')
              .having((e) => e.message, 'message', 'no face detected')),
        );
      } finally {
        await server.close();
      }
    });

    test('parses the legacy string error shape', () async {
      final (transport, server) = await testTransport((req) async {
        req.response.statusCode = 400;
        req.response.headers.contentType = ContentType.json;
        req.response.write(jsonEncode({'error': 'bad input'}));
        await req.response.close();
      });

      try {
        await expectLater(
          transport.doJson<void>('POST', '/test'),
          throwsA(isA<BiometryAPIError>()
              .having((e) => e.message, 'message', 'bad input')),
        );
      } finally {
        await server.close();
      }
    });
  });

  group('multipart request part', () {
    test('carries the JSON request field + file', () async {
      final (transport, server) = await testTransport((req) async {
        expect(req.headers.value('content-type'), contains('multipart/form-data'));
        final body = await utf8.decoder.bind(req).join();
        expect(body, contains('name="request"'));
        expect(body, contains('"user_id":"user-1"'));
        expect(body, contains('name="face"'));

        req.response.statusCode = 200;
        req.response.headers.contentType = ContentType.json;
        req.response.write(jsonEncode({
          'data': {'enrolled': true},
          'meta': <String, dynamic>{},
        }));
        await req.response.close();
      });

      try {
        final client = BiometryClient(
          'test-api-key',
          baseUrl: 'http://localhost:${server.port}',
        );
        final resp = await client.enrollment.face(EnrollFaceInput(
          userId: 'user-1',
          face: utf8.encode('img'),
          fileName: 'f.jpg',
          isDocument: true,
        ));
        expect(resp.data['enrolled'], true);
      } finally {
        await server.close();
      }
    });
  });

  group('doMultipartRaw', () {
    test('returns the v2 envelope with decision + meta', () async {
      final (transport, server) = await testTransport((req) async {
        req.response.statusCode = 200;
        req.response.headers.contentType = ContentType.json;
        req.response.write(jsonEncode({
          'data': {'id': 'abc'},
          'decision': {
            'status': 'pass',
            'score': 92.5,
            'reasons': ['face_match'],
          },
          'meta': {'request_id': 'req-abc-123', 'message': 'done'},
        }));
        await req.response.close();
      });

      try {
        final resp = await transport.doMultipartRaw(
          '/process',
          files: [
            FileUpload(
              fieldName: 'video',
              fileName: 'test.mp4',
              content: utf8.encode('video-data'),
            ),
          ],
        );
        expect(resp.decision?.status, 'pass');
        expect(resp.decision?.score, 92.5);
        expect(resp.decision?.reasons, ['face_match']);
        expect(resp.meta.message, 'done');
        expect(resp.requestId, 'req-abc-123');
      } finally {
        await server.close();
      }
    });
  });

  group('reference image', () {
    test('upload() PUTs to /v2/users/:id/reference-image', () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(() => server.close());
      server.listen((req) async {
        expect(req.method, 'PUT');
        expect(req.uri.path, '/api-gateway/v2/users/user-1/reference-image');
        req.response.statusCode = 200;
        req.response.headers.contentType = ContentType.json;
        req.response.write(jsonEncode({'meta': <String, dynamic>{}}));
        await req.response.close();
      });

      final client = BiometryClient(
        'test-api-key',
        baseUrl: 'http://localhost:${server.port}',
      );
      await client.images.upload(
        userId: 'user-1',
        image: utf8.encode('img'),
        fileName: 'ref.jpg',
      );
    });

    test('get() returns the raw image bytes', () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(() => server.close());
      server.listen((req) async {
        req.response.statusCode = 200;
        req.response.add([0x89, 0x50, 0x4e, 0x47]);
        await req.response.close();
      });

      final client = BiometryClient(
        'test-api-key',
        baseUrl: 'http://localhost:${server.port}',
      );
      final bytes = await client.images.get('user-1');
      expect(bytes, [0x89, 0x50, 0x4e, 0x47]);
    });
  });

  group('call options headers', () {
    test('sends metadata headers', () async {
      final (transport, server) = await testTransport((req) async {
        expect(req.headers.value('x-device-info'), '{"model":"iPhone"}');
        expect(req.headers.value('x-request-tags'), 'vip,test');
        expect(req.headers.value('x-client-app'), 'demo');

        req.response.statusCode = 200;
        req.response.headers.contentType = ContentType.json;
        req.response.write(jsonEncode({'meta': <String, dynamic>{}}));
        await req.response.close();
      });

      try {
        await transport.doJson<void>(
          'POST',
          '/test',
          extraHeaders: buildCallHeaders(
            deviceInfo: '{"model":"iPhone"}',
            requestTags: 'vip,test',
            clientApp: 'demo',
          ),
        );
      } finally {
        await server.close();
      }
    });
  });

  group('error predicates', () {
    test('isNotFound returns true for 404', () {
      final err = BiometryAPIError(statusCode: 404, message: 'not found', rawBody: []);
      expect(isNotFound(err), true);
      expect(isForbidden(err), false);
    });

    test('isForbidden returns true for 403', () {
      final err = BiometryAPIError(statusCode: 403, message: 'forbidden', rawBody: []);
      expect(isForbidden(err), true);
    });

    test('isUnauthorized returns true for 401', () {
      final err = BiometryAPIError(statusCode: 401, message: 'unauth', rawBody: []);
      expect(isUnauthorized(err), true);
    });

    test('predicates return false for non-API errors', () {
      expect(isNotFound(Exception('test')), false);
      expect(isForbidden(null), false);
    });
  });
}
