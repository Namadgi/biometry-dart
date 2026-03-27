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
    userFullname: 'Test User',
  );
  return (transport, server);
}

void main() {
  group('doJson', () {
    test('sends auth and fullname headers, decodes data', () async {
      final (transport, server) = await testTransport((req) async {
        expect(req.headers.value('authorization'), 'Bearer test-api-key');
        expect(req.headers.value('x-user-fullname'), 'Test User');
        expect(req.headers.value('content-type'),
            contains('application/json'));

        req.response.statusCode = 200;
        req.response.headers.contentType = ContentType.json;
        req.response.write(jsonEncode({
          'data': {'id': '123'},
          'message': 'ok',
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

    test('throws BiometryAPIError on 4xx', () async {
      final (transport, server) = await testTransport((req) async {
        req.response.statusCode = 400;
        req.response.headers.contentType = ContentType.json;
        req.response.write(jsonEncode({'message': 'bad input'}));
        await req.response.close();
      });

      try {
        await expectLater(
          transport.doJson<void>('POST', '/test'),
          throwsA(isA<BiometryAPIError>()
              .having((e) => e.statusCode, 'statusCode', 400)
              .having((e) => e.message, 'message', 'bad input')),
        );
      } finally {
        await server.close();
      }
    });

    test('returns null for void responses', () async {
      final (transport, server) = await testTransport((req) async {
        req.response.statusCode = 200;
        req.response.headers.contentType = ContentType.json;
        req.response.write(jsonEncode({'message': 'ok'}));
        await req.response.close();
      });

      try {
        // Should not throw
        await transport.doJson<void>('POST', '/test');
      } finally {
        await server.close();
      }
    });
  });

  group('doMultipart', () {
    test('sends multipart form data and decodes response', () async {
      final (transport, server) = await testTransport((req) async {
        expect(req.headers.value('content-type'),
            contains('multipart/form-data'));

        // We just verify the content type and return a response
        req.response.statusCode = 200;
        req.response.headers.contentType = ContentType.json;
        req.response.write(jsonEncode({
          'data': {'result': 'ok'},
        }));
        await req.response.close();
      });

      try {
        final result = await transport.doMultipart<Map<String, dynamic>>(
          '/upload',
          fields: {'field1': 'value1'},
          files: [
            FileUpload(
              fieldName: 'upload',
              fileName: 'test.bin',
              content: utf8.encode('file-content'),
            ),
          ],
          fromJson: (data) => data as Map<String, dynamic>,
        );
        expect(result['result'], 'ok');
      } finally {
        await server.close();
      }
    });
  });

  group('doMultipartRaw', () {
    test('returns full response envelope with headers', () async {
      final (transport, server) = await testTransport((req) async {
        req.response.statusCode = 200;
        req.response.headers
          ..set('x-request-id', 'req-abc-123')
          ..set('x-auto-enroll', 'true')
          ..set('x-removed-services', 'true')
          ..contentType = ContentType.json;
        req.response.write(jsonEncode({
          'data': {'id': 'abc'},
          'scoring_result': {'status': 'approved'},
          'score': 92.5,
          'decision_reasons': ['face_match'],
          'message': 'done',
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
        expect(resp.score, 92.5);
        expect(resp.decisionReasons, ['face_match']);
        expect(resp.message, 'done');
        expect(resp.requestId, 'req-abc-123');
        expect(resp.autoEnrolled, true);
        expect(resp.removedServices, true);
      } finally {
        await server.close();
      }
    });
  });

  group('call options headers', () {
    test('sends per-request headers', () async {
      final (transport, server) = await testTransport((req) async {
        expect(req.headers.value('x-user-fullname'), 'Override Name');
        expect(req.headers.value('x-session-id'), 'sess-123');

        req.response.statusCode = 200;
        req.response.headers.contentType = ContentType.json;
        req.response.write(jsonEncode({'data': 'id-1'}));
        await req.response.close();
      });

      try {
        await transport.doJson<void>(
          'POST',
          '/test',
          extraHeaders: buildCallHeaders(
            fullname: 'Override Name',
            sessionId: 'sess-123',
          ),
        );
      } finally {
        await server.close();
      }
    });

    test('sends docauth and MRZ headers', () async {
      final (transport, server) = await testTransport((req) async {
        expect(req.headers.value('x-inhouse-docauth'), 'false');
        expect(req.headers.value('x-inhouse-mrz'), 'true');
        expect(req.headers.value('x-device-info'), '{"model":"iPhone"}');
        expect(req.headers.value('x-request-tags'), 'vip,test');

        req.response.statusCode = 200;
        req.response.headers.contentType = ContentType.json;
        req.response.write(jsonEncode({'data': 'ok'}));
        await req.response.close();
      });

      try {
        await transport.doJson<void>(
          'POST',
          '/test',
          extraHeaders: buildCallHeaders(
            inhouseDocAuth: false,
            mrzValidation: true,
            deviceInfo: '{"model":"iPhone"}',
            requestTags: 'vip,test',
          ),
        );
      } finally {
        await server.close();
      }
    });
  });

  group('error predicates', () {
    test('isNotFound returns true for 404', () {
      final err = BiometryAPIError(
        statusCode: 404,
        message: 'not found',
        rawBody: [],
      );
      expect(isNotFound(err), true);
      expect(isForbidden(err), false);
    });

    test('isForbidden returns true for 403', () {
      final err = BiometryAPIError(
        statusCode: 403,
        message: 'forbidden',
        rawBody: [],
      );
      expect(isForbidden(err), true);
      expect(isNotFound(err), false);
    });

    test('isUnauthorized returns true for 401', () {
      final err = BiometryAPIError(
        statusCode: 401,
        message: 'unauthorized',
        rawBody: [],
      );
      expect(isUnauthorized(err), true);
      expect(isNotFound(err), false);
    });

    test('predicates return false for non-API errors', () {
      expect(isNotFound(Exception('test')), false);
      expect(isForbidden(null), false);
    });
  });
}
