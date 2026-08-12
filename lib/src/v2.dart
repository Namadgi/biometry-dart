import 'dart:convert';

/// Services that can be excluded from the liveness pipeline.
class VerificationServices {
  static const faceLiveness = 'face_liveness_detection';
  static const activeSpeaker = 'active_speaker_detection';
  static const visualSpeech = 'visual_speech_recognition';
  static const faceRecognition = 'face_recognition';
  static const voiceRecognition = 'voice_recognition';
}

/// Builds the multipart `request` form field for API v2 gateway endpoints.
///
/// The gateway decodes this JSON part and derives the internal identity,
/// session, and service-selection headers from it (those headers are stripped
/// from the incoming request, so this is the only supported way to pass them).
/// Empty/false values are dropped to keep the payload lean.
Map<String, String> requestField({
  String? userId,
  String? sessionId,
  String? phrase,
  String? vocabulary,
  String? trigger,
  bool? useSessionVideo,
  String? provider,
  String? mrzProvider,
  bool? isDocument,
  List<String>? excludeServices,
}) {
  final req = <String, dynamic>{};
  void put(String key, dynamic value) {
    if (value == null) return;
    if (value is String && value.isEmpty) return;
    if (value is bool && value == false) return;
    req[key] = value;
  }

  put('user_id', userId);
  put('session_id', sessionId);
  put('phrase', phrase);
  put('vocabulary', vocabulary);
  put('trigger', trigger);
  put('use_session_video', useSessionVideo);
  put('provider', provider);
  put('mrz_provider', mrzProvider);
  put('is_document', isDocument);
  if (excludeServices != null && excludeServices.isNotEmpty) {
    req['services'] = {'exclude': excludeServices};
  }

  return {'request': jsonEncode(req)};
}
