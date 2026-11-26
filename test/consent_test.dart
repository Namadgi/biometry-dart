import 'dart:convert';
import 'dart:io';

import 'package:biometry_api/biometry_api.dart';
import 'package:test/test.dart';

/// A recorded request: method, raw (still encoded) path, content type, body.
class _Seen {
  String? method;
  String? rawPath;
  String? contentType;
  String body = '';
}

Future<BiometryClient> _client(
  _Seen seen, {
  int status = 200,
  required Object reply,
}) async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  addTearDown(() => server.close(force: true));
  server.listen((req) async {
    seen
      ..method = req.method
      ..rawPath = req.requestedUri.toString().split('?').first.replaceFirst(
            'http://localhost:${server.port}',
            '',
          )
      ..contentType = req.headers.contentType?.mimeType
      ..body = await utf8.decoder.bind(req).join();
    req.response.statusCode = status;
    req.response.headers.contentType = ContentType.json;
    req.response.write(jsonEncode(reply));
    await req.response.close();
  });
  return BiometryClient('test-api-key',
      baseUrl: 'http://localhost:${server.port}');
}

Map<String, dynamic> _ok(String userId, bool authorization, bool storage) => {
      'data': {
        'user_id': userId,
        'authorization': authorization,
        'storage': storage,
      },
      'meta': <String, dynamic>{},
    };

void main() {
  group('ConsentService user consent', () {
    test('give() defaults to both and PUTs /v2/users/:id/consents', () async {
      final seen = _Seen();
      final client = await _client(seen, reply: _ok('user-123', true, true));

      final state = await client.consents.give('user-123');

      expect(seen.method, 'PUT');
      expect(seen.rawPath, '/api-gateway/v2/users/user-123/consents');
      expect(seen.contentType, 'application/json');
      expect(jsonDecode(seen.body), {'authorization': true, 'storage': true});
      expect(state.userId, 'user-123');
      expect(state.authorization, isTrue);
      expect(state.storage, isTrue);
    });

    test('revoke() sends false for the selected consent only, with session',
        () async {
      final seen = _Seen();
      final client = await _client(seen, reply: _ok('user-123', true, false));

      final state = await client.consents
          .revoke('user-123', authorization: false, sessionId: 'sess_1');

      expect(seen.method, 'PUT');
      expect(jsonDecode(seen.body), {'storage': false, 'session_id': 'sess_1'});
      expect(state.authorization, isTrue);
      expect(state.storage, isFalse);
    });

    test('give()/revoke() throw before any request when nothing is selected',
        () async {
      final seen = _Seen();
      final client = await _client(seen, reply: _ok('u', false, false));

      expect(
        () => client.consents
            .give('user-123', authorization: false, storage: false),
        throwsArgumentError,
      );
      expect(
        () => client.consents
            .revoke('user-123', authorization: false, storage: false),
        throwsArgumentError,
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(seen.method, isNull);
    });

    test('status() GETs with an encoded user id', () async {
      final seen = _Seen();
      final client = await _client(seen, reply: _ok('a/b', true, false));

      final state = await client.consents.status('a/b');

      expect(seen.method, 'GET');
      expect(seen.rawPath, '/api-gateway/v2/users/a%2Fb/consents');
      expect(seen.body, isEmpty);
      expect(state.userId, 'a/b');
      expect(state.authorization, isTrue);
      expect(state.storage, isFalse);
    });

    test('surfaces API errors as BiometryAPIError', () async {
      final seen = _Seen();
      final client = await _client(
        seen,
        status: 409,
        reply: {
          'error': {'code': 'session_closed', 'message': 'session is closed'},
        },
      );

      await expectLater(
        client.consents.give('user-123', sessionId: 'sess_1'),
        throwsA(isA<BiometryAPIError>()
            .having((e) => e.statusCode, 'statusCode', 409)
            .having((e) => e.code, 'code', 'session_closed')),
      );
    });
  });
}
