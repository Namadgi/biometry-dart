import 'dart:convert';
import 'dart:io';

import 'package:biometry_api/biometry_api.dart';
import 'package:test/test.dart';

void main() {
  group('SessionService', () {
    test('start() sends POST and returns session ID', () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(() => server.close());

      server.listen((req) async {
        expect(req.method, 'POST');
        expect(req.uri.path, '/api-gateway/sessions/start');

        req.response.statusCode = 200;
        req.response.headers.contentType = ContentType.json;
        req.response.write(jsonEncode({'data': 'session-abc'}));
        await req.response.close();
      });

      final client = BiometryClient(
        'test-api-key',
        baseUrl: 'http://localhost:${server.port}',
        userFullname: 'Test User',
      );

      final id = await client.sessions.start();
      expect(id, 'session-abc');
    });

    test('end() sends POST with phone number', () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(() => server.close());

      server.listen((req) async {
        expect(req.method, 'POST');
        expect(req.uri.path, '/api-gateway/sessions/end/sess-123');

        // Verify the body contains phone number
        final body = await utf8.decoder.bind(req).join();
        final json = jsonDecode(body) as Map<String, dynamic>;
        expect(json['phone_number'], '+1234567890');

        req.response.statusCode = 200;
        req.response.headers.contentType = ContentType.json;
        req.response.write(jsonEncode({'message': 'ok'}));
        await req.response.close();
      });

      final client = BiometryClient(
        'test-api-key',
        baseUrl: 'http://localhost:${server.port}',
        userFullname: 'Test User',
      );

      await client.sessions.end(
        'sess-123',
        request: EndSessionRequest(phoneNumber: '+1234567890'),
      );
    });
  });
}
