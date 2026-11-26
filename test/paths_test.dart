import 'dart:convert';
import 'dart:io';

import 'package:biometry_api/biometry_api.dart';
import 'package:test/test.dart';

class _Seen {
  String? rawPath;
  String body = '';
}

Future<BiometryClient> _client(_Seen seen, Object reply) async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  addTearDown(() => server.close(force: true));
  server.listen((req) async {
    seen
      ..rawPath = req.requestedUri.toString().replaceFirst(
            'http://localhost:${server.port}',
            '',
          )
      ..body = await latin1.decoder.bind(req).join();
    req.response.statusCode = 200;
    req.response.headers.contentType = ContentType.json;
    req.response.write(jsonEncode(reply));
    await req.response.close();
  });
  return BiometryClient('k', baseUrl: 'http://localhost:${server.port}');
}

void main() {
  group('path segments are URI-encoded', () {
    final cases = <String, (Future<Object?> Function(BiometryClient), String)>{
      'sessions.end': (
        (c) => c.sessions.end('a/b?c'),
        '/api-gateway/v2/sessions/a%2Fb%3Fc/end',
      ),
      'images.get': (
        (c) => c.images.get('u/1'),
        '/api-gateway/v2/users/u%2F1/reference-image',
      ),
      'consents.approve': (
        (c) => c.consents.approve('t/1', 'u?1'),
        '/api-gateway/v2/consents/t%2F1/approve/u%3F1',
      ),
      'consents.myApprovals': (
        (c) => c.consents.myApprovals('u/1'),
        '/api-gateway/v2/consents/my-approvals/u%2F1',
      ),
    };
    cases.forEach((name, c) {
      test(name, () async {
        final seen = _Seen();
        final client = await _client(seen, {'data': <dynamic>[], 'meta': {}});
        try {
          await c.$1(client);
        } catch (_) {}
        expect(seen.rawPath, c.$2);
      });
    });
  });

  group('useSessionVideo does not upload media', () {
    test('faceVerify drops the media part', () async {
      final seen = _Seen();
      final client = await _client(seen, {'data': {}, 'meta': {}});
      await client.verification.faceVerify(VerifyInput(
        userId: 'u-1',
        phrase: '',
        sessionId: 'sess_1',
        useSessionVideo: true,
        media: utf8.encode('vid'),
      ));
      expect(seen.body, isNot(contains('name="video"')));
      expect(seen.body, contains('"use_session_video":true'));
    });

    test('faceMatch drops the video but keeps the reference image', () async {
      final seen = _Seen();
      final client = await _client(seen, {'data': {}, 'meta': {}});
      await client.faceMatch.match(FaceMatchInput(
        userId: 'u-1',
        referenceImage: utf8.encode('img'),
        referenceName: 'r.jpg',
        sessionId: 'sess_1',
        useSessionVideo: true,
        video: utf8.encode('vid'),
      ));
      expect(seen.body, isNot(contains('name="video"')));
      expect(seen.body, contains('name="reference_image"'));
    });
  });

  group('DeepfakeCheck.fromJson', () {
    test('parses a complete check', () {
      final check = DeepfakeCheck.fromJson({'id': 'r1', 'status': 'pending'});
      expect(check.id, 'r1');
      expect(check.status, 'pending');
    });

    test('throws on a missing id or status', () {
      expect(() => DeepfakeCheck.fromJson({'status': 'pending'}),
          throwsFormatException);
      expect(() => DeepfakeCheck.fromJson({'id': 'r1'}), throwsFormatException);
    });
  });
}
