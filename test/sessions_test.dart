import 'dart:convert';
import 'dart:io';

import 'package:biometry_api/biometry_api.dart';
import 'package:test/test.dart';

void main() {
  group('SessionService', () {
    test('start() POSTs to /v2/sessions and returns session ID', () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(() => server.close());

      server.listen((req) async {
        expect(req.method, 'POST');
        expect(req.uri.path, '/api-gateway/v2/sessions');

        req.response.statusCode = 200;
        req.response.headers.contentType = ContentType.json;
        req.response.write(jsonEncode({
          'data': {'session_id': 'session-abc'},
          'meta': <String, dynamic>{},
        }));
        await req.response.close();
      });

      final client = BiometryClient(
        'test-api-key',
        baseUrl: 'http://localhost:${server.port}',
      );

      final id = await client.sessions.start();
      expect(id, 'session-abc');
    });

    test('end() POSTs to /v2/sessions/:id/end with phone number', () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(() => server.close());

      server.listen((req) async {
        expect(req.method, 'POST');
        expect(req.uri.path, '/api-gateway/v2/sessions/sess-123/end');

        final body = await utf8.decoder.bind(req).join();
        final json = jsonDecode(body) as Map<String, dynamic>;
        expect(json['phone_number'], '+1234567890');

        req.response.statusCode = 200;
        req.response.headers.contentType = ContentType.json;
        req.response.write(jsonEncode({'meta': <String, dynamic>{}}));
        await req.response.close();
      });

      final client = BiometryClient(
        'test-api-key',
        baseUrl: 'http://localhost:${server.port}',
      );

      await client.sessions.end(
        'sess-123',
        request: EndSessionRequest(phoneNumber: '+1234567890'),
      );
    });
  });
}
