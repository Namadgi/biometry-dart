/// Request body for ending a session.
class EndSessionRequest {
  EndSessionRequest({this.phoneNumber});

  final String? phoneNumber;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (phoneNumber != null) json['phone_number'] = phoneNumber;
    return json;
  }
}

/// Input for a liveness check (face liveness, active speaker detection, visual
/// speech recognition).
class LivenessInput {
  LivenessInput({
    required this.userId,
    required this.video,
    required this.fileName,
    required this.phrase,
    this.vocabulary,
    this.trigger,
    this.sessionId,
    this.excludeServices,
  });

  /// Opaque, customer-provided identity key.
  final String userId;

  /// Video file bytes.
  final List<int> video;

  /// Name of the video file.
  final String fileName;

  /// Phrase spoken in the video.
  final String phrase;

  /// Optional vocabulary identifier.
  final String? vocabulary;

  /// Optional contextual trigger event name.
  final String? trigger;

  /// Optional session ID for combined scoring.
  final String? sessionId;

  /// Services to skip from the pipeline (see [VerificationServices]).
  final List<String>? excludeServices;
}

/// Input for face or voice verification against the user's enrolled template.
class VerifyInput {
  VerifyInput({
    required this.userId,
    this.media,
    this.fileName,
    required this.phrase,
    this.vocabulary,
    this.sessionId,
    this.useSessionVideo = false,
  });

  /// Opaque, customer-provided identity key.
  final String userId;

  /// Video (face) or audio/video (voice) bytes. Omit when [useSessionVideo] is true.
  final List<int>? media;

  /// Name of the media file.
  final String? fileName;

  /// Phrase spoken in the media.
  final String phrase;

  /// Optional vocabulary identifier.
  final String? vocabulary;

  /// Optional session ID for combined scoring / session-video reuse.
  final String? sessionId;

  /// Reuse the video captured earlier in the session. Requires [sessionId].
  final bool useSessionVideo;
}

/// Input for a face-match request.
class FaceMatchInput {
  FaceMatchInput({
    required this.userId,
    required this.referenceImage,
    required this.referenceName,
    this.video,
    this.videoName,
    this.sessionId,
    this.useSessionVideo = false,
  });

  /// Opaque, customer-provided identity key.
  final String userId;

  /// Reference portrait image bytes.
  final List<int> referenceImage;

  /// Name of the reference image file.
  final String referenceName;

  /// Live capture bytes. Omit when [useSessionVideo] is true.
  final List<int>? video;

  /// Name of the video file.
  final String? videoName;

  /// Optional session ID; required when [useSessionVideo] is true.
  final String? sessionId;

  /// Reuse the video captured earlier in the session. Requires [sessionId].
  final bool useSessionVideo;
}

/// Input for a document authenticity check.
class DocAuthInput {
  DocAuthInput({
    required this.document,
    required this.fileName,
    this.sessionId,
    this.provider,
    this.mrzProvider,
  });

  /// Document image bytes.
  final List<int> document;

  /// Name of the document file.
  final String fileName;

  /// Optional session ID.
  final String? sessionId;

  /// Document authenticity provider: "inhouse" or "idscan".
  final String? provider;

  /// MRZ extraction provider: "inhouse" or "idscan".
  final String? mrzProvider;
}

/// Input for face enrollment.
class EnrollFaceInput {
  EnrollFaceInput({
    required this.userId,
    required this.face,
    required this.fileName,
    this.isDocument = false,
  });

  /// Opaque, customer-provided identity key.
  final String userId;

  /// Face image bytes.
  final List<int> face;

  /// File name of the face image.
  final String fileName;

  /// Set true if the face image is from a document.
  final bool isDocument;
}

/// Input for voice enrollment.
class EnrollVoiceInput {
  EnrollVoiceInput({
    required this.userId,
    required this.voice,
    required this.fileName,
    required this.phrase,
    this.vocabulary,
  });

  /// Opaque, customer-provided identity key.
  final String userId;

  /// Voice recording bytes.
  final List<int> voice;

  /// File name of the voice recording.
  final String fileName;

  /// The phrase spoken in the recording.
  final String phrase;

  /// Optional vocabulary identifier.
  final String? vocabulary;
}

/// Input for submitting a deepfake check.
class DeepfakeInput {
  DeepfakeInput({
    required this.userId,
    required this.video,
    required this.fileName,
    this.sessionId,
  });

  /// Opaque, customer-provided identity key.
  final String userId;

  /// Video file bytes.
  final List<int> video;

  /// Name of the video file.
  final String fileName;

  /// Optional session ID.
  final String? sessionId;
}

/// Document authentication info extracted from a document.
class DocAuthInfo {
  DocAuthInfo({
    this.documentType = '',
    this.countryCode = '',
    this.nationalityCode = '',
    this.nationalityName = '',
    this.sex = '',
    this.firstName = '',
    this.fatherName = '',
    this.lastName = '',
    this.expiryDate = '',
    this.documentNumber = '',
    this.birthDate = '',
    this.portraitPhoto = '',
    this.signature = '',
    this.documentCategory = '',
    this.issuingState = '',
    this.frontDocumentTypeId = '',
    this.containsRfid = false,
    this.faceImageBase64,
    this.currentResult,
    this.mrzValidation,
  });

  factory DocAuthInfo.fromJson(Map<String, dynamic> json) {
    return DocAuthInfo(
      documentType: (json['document_type'] as String?) ?? '',
      countryCode: (json['country_code'] as String?) ?? '',
      nationalityCode: (json['nationality_code'] as String?) ?? '',
      nationalityName: (json['nationality_name'] as String?) ?? '',
      sex: (json['sex'] as String?) ?? '',
      firstName: (json['first_name'] as String?) ?? '',
      fatherName: (json['father_name'] as String?) ?? '',
      lastName: (json['last_name'] as String?) ?? '',
      expiryDate: (json['expiry_date'] as String?) ?? '',
      documentNumber: (json['document_number'] as String?) ?? '',
      birthDate: (json['birth_date'] as String?) ?? '',
      portraitPhoto: (json['portrait_photo'] as String?) ?? '',
      signature: (json['signature'] as String?) ?? '',
      documentCategory: (json['document_category'] as String?) ?? '',
      issuingState: (json['issuing_state'] as String?) ?? '',
      frontDocumentTypeId: (json['front_document_type_id'] as String?) ?? '',
      containsRfid: (json['contains_rfid'] as bool?) ?? false,
      faceImageBase64: json['face_image_base64'] as String?,
      currentResult: json['current_result'] as String?,
      mrzValidation: json['mrz_validation'] != null
          ? MRZValidation.fromJson(
              json['mrz_validation'] as Map<String, dynamic>)
          : null,
    );
  }

  final String documentType;
  final String countryCode;
  final String nationalityCode;
  final String nationalityName;
  final String sex;
  final String firstName;
  final String fatherName;
  final String lastName;
  final String expiryDate;
  final String documentNumber;
  final String birthDate;
  final String portraitPhoto;
  final String signature;
  final String documentCategory;
  final String issuingState;
  final String frontDocumentTypeId;
  final bool containsRfid;
  final String? faceImageBase64;
  final String? currentResult;
  final MRZValidation? mrzValidation;

  Map<String, dynamic> toJson() {
    final result = <String, dynamic>{
      'document_type': documentType,
      'country_code': countryCode,
      'nationality_code': nationalityCode,
      'nationality_name': nationalityName,
      'sex': sex,
      'first_name': firstName,
      'father_name': fatherName,
      'last_name': lastName,
      'expiry_date': expiryDate,
      'document_number': documentNumber,
      'birth_date': birthDate,
      'portrait_photo': portraitPhoto,
      'signature': signature,
      'document_category': documentCategory,
      'issuing_state': issuingState,
      'front_document_type_id': frontDocumentTypeId,
      'contains_rfid': containsRfid,
    };
    if (faceImageBase64 != null) {
      result['face_image_base64'] = faceImageBase64;
    }
    if (currentResult != null) result['current_result'] = currentResult;
    if (mrzValidation != null) {
      result['mrz_validation'] = mrzValidation!.toJson();
    }
    return result;
  }
}

/// MRZ (Machine Readable Zone) validation results.
class MRZValidation {
  MRZValidation({
    this.hasMrz = false,
    this.rawMrz,
    this.checkDigitsValid = false,
    this.fieldsMatch = false,
    this.discrepancies = const [],
    this.validationPerformed = false,
  });

  factory MRZValidation.fromJson(Map<String, dynamic> json) {
    final disc = json['discrepancies'];
    return MRZValidation(
      hasMrz: (json['has_mrz'] as bool?) ?? false,
      rawMrz: json['raw_mrz'] as String?,
      checkDigitsValid: (json['check_digits_valid'] as bool?) ?? false,
      fieldsMatch: (json['fields_match'] as bool?) ?? false,
      discrepancies: disc is List
          ? disc.map((e) => e.toString()).toList()
          : const [],
      validationPerformed: (json['validation_performed'] as bool?) ?? false,
    );
  }

  final bool hasMrz;
  final String? rawMrz;
  final bool checkDigitsValid;
  final bool fieldsMatch;
  final List<String> discrepancies;
  final bool validationPerformed;

  Map<String, dynamic> toJson() {
    final result = <String, dynamic>{
      'has_mrz': hasMrz,
      'check_digits_valid': checkDigitsValid,
      'fields_match': fieldsMatch,
      'discrepancies': discrepancies,
      'validation_performed': validationPerformed,
    };
    if (rawMrz != null) result['raw_mrz'] = rawMrz;
    return result;
  }
}

/// Consent approval record.
class ConsentApproval {
  ConsentApproval({
    required this.id,
    required this.consentVersionId,
    required this.userId,
    required this.isApproved,
    required this.createdAt,
  });

  factory ConsentApproval.fromJson(Map<String, dynamic> json) {
    return ConsentApproval(
      id: (json['id'] as String?) ?? '',
      consentVersionId: (json['consent_version_id'] as String?) ?? '',
      userId: (json['user_id'] as String?) ?? '',
      isApproved: (json['is_approved'] as bool?) ?? false,
      createdAt: DateTime.parse(
        (json['created_at'] as String?) ?? '1970-01-01T00:00:00Z',
      ),
    );
  }

  final String id;
  final String consentVersionId;
  final String userId;
  final bool isApproved;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'consent_version_id': consentVersionId,
        'user_id': userId,
        'is_approved': isApproved,
        'created_at': createdAt.toIso8601String(),
      };
}

/// State of an asynchronous deepfake check.
class DeepfakeCheck {
  DeepfakeCheck({
    required this.id,
    required this.status,
    this.score,
    this.prediction,
    this.message,
    this.createdAt,
    this.completedAt,
  });

  factory DeepfakeCheck.fromJson(Map<String, dynamic> json) {
    return DeepfakeCheck(
      id: _requireString(json, 'id'),
      status: _requireString(json, 'status'),
      score: (json['score'] as num?)?.toDouble(),
      prediction: json['prediction'] as String?,
      message: json['message'] as String?,
      createdAt: (json['created_at'] as num?)?.toInt(),
      completedAt: (json['completed_at'] as num?)?.toInt(),
    );
  }

  final String id;

  /// pending | processing | completed | failed
  final String status;

  /// Deepfake probability (0.0–1.0), null until completed.
  final double? score;
  final String? prediction;
  final String? message;

  /// Unix timestamp (seconds).
  final int? createdAt;

  /// Unix timestamp (seconds).
  final int? completedAt;
}

/// Request filters for listing transactions.
class TransactionListRequest {
  TransactionListRequest({
    this.projectId,
    this.sessionId,
    this.userFullname,
    this.fromDate,
    this.toDate,
    this.statusCode,
    this.decision,
    this.action,
    this.flag,
    this.page,
    this.pageSize,
    this.sortBy,
    this.sortOrder,
  });

  final String? projectId;
  final String? sessionId;
  final String? userFullname;
  final String? fromDate;
  final String? toDate;
  final int? statusCode;
  final String? decision;
  final String? action;
  final String? flag;
  final int? page;
  final int? pageSize;
  final String? sortBy;
  final String? sortOrder;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (projectId != null) json['project_id'] = projectId;
    if (sessionId != null) json['session_id'] = sessionId;
    if (userFullname != null) json['user_fullname'] = userFullname;
    if (fromDate != null) json['from_date'] = fromDate;
    if (toDate != null) json['to_date'] = toDate;
    if (statusCode != null) json['status_code'] = statusCode;
    if (decision != null) json['decision'] = decision;
    if (action != null) json['action'] = action;
    if (flag != null) json['flag'] = flag;
    if (page != null) json['page'] = page;
    if (pageSize != null) json['page_size'] = pageSize;
    if (sortBy != null) json['sort_by'] = sortBy;
    if (sortOrder != null) json['sort_order'] = sortOrder;
    return json;
  }
}

/// Biometric transaction record.
class Transaction {
  Transaction({
    required this.id,
    required this.sessionId,
    this.flag = '',
    required this.device,
    required this.projectId,
    required this.apiKeyId,
    this.statusCode = 0,
    this.isSuccess = false,
    this.bodyByteSize = 0,
    this.usedServices = const [],
    required this.receivedAt,
    required this.answeredAt,
    this.action = '',
    this.appVersion = '',
    this.duration = 0,
    this.decision = '',
    this.decisionHistory = const [],
    this.geo,
    this.tags = const [],
    this.inputMetadata,
    this.outputMetadata,
    this.rulesVersion = 0,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    final services = json['used_services'];
    final history = json['decision_history'];
    final tagsRaw = json['tags'];
    return Transaction(
      id: (json['id'] as String?) ?? '',
      sessionId: (json['session_id'] as String?) ?? '',
      flag: (json['flag'] as String?) ?? '',
      device: TransactionDevice.fromJson(
        (json['device'] as Map<String, dynamic>?) ?? {},
      ),
      projectId: (json['project_id'] as String?) ?? '',
      apiKeyId: (json['api_key_id'] as String?) ?? '',
      statusCode: (json['status_code'] as int?) ?? 0,
      isSuccess: (json['is_success'] as bool?) ?? false,
      bodyByteSize: (json['body_byte_size'] as int?) ?? 0,
      usedServices: services is List
          ? services.map((e) => e.toString()).toList()
          : const [],
      receivedAt: DateTime.parse(
        // Note: backend spells it "recieved_at"
        (json['recieved_at'] as String?) ?? '1970-01-01T00:00:00Z',
      ),
      answeredAt: DateTime.parse(
        (json['answered_at'] as String?) ?? '1970-01-01T00:00:00Z',
      ),
      action: (json['action'] as String?) ?? '',
      appVersion: (json['app_version'] as String?) ?? '',
      duration: (json['duration'] as int?) ?? 0,
      decision: (json['decision'] as String?) ?? '',
      decisionHistory: history is List
          ? history
              .map(
                (e) => DecisionChange.fromJson(e as Map<String, dynamic>),
              )
              .toList()
          : const [],
      geo: json['geo'] != null
          ? Geo.fromJson(json['geo'] as Map<String, dynamic>)
          : null,
      tags: tagsRaw is List
          ? tagsRaw.map((e) => e.toString()).toList()
          : const [],
      inputMetadata: json['input_metadata'],
      outputMetadata: json['output_metadata'],
      rulesVersion: (json['rules_version'] as int?) ?? 0,
    );
  }

  final String id;
  final String sessionId;
  final String flag;
  final TransactionDevice device;
  final String projectId;
  final String apiKeyId;
  final int statusCode;
  final bool isSuccess;
  final int bodyByteSize;
  final List<String> usedServices;
  final DateTime receivedAt;
  final DateTime answeredAt;
  final String action;
  final String appVersion;
  final int duration;
  final String decision;
  final List<DecisionChange> decisionHistory;
  final Geo? geo;
  final List<String> tags;
  final dynamic inputMetadata;
  final dynamic outputMetadata;
  final int rulesVersion;

  Map<String, dynamic> toJson() => {
        'id': id,
        'session_id': sessionId,
        'flag': flag,
        'device': device.toJson(),
        'project_id': projectId,
        'api_key_id': apiKeyId,
        'status_code': statusCode,
        'is_success': isSuccess,
        'body_byte_size': bodyByteSize,
        'used_services': usedServices,
        'recieved_at': receivedAt.toIso8601String(),
        'answered_at': answeredAt.toIso8601String(),
        'action': action,
        'app_version': appVersion,
        'duration': duration,
        'decision': decision,
        'decision_history': decisionHistory.map((e) => e.toJson()).toList(),
        'geo': geo?.toJson(),
        'tags': tags,
        'input_metadata': inputMetadata,
        'output_metadata': outputMetadata,
        'rules_version': rulesVersion,
      };
}

/// Device information from a transaction.
class TransactionDevice {
  TransactionDevice({this.deviceType = '', this.deviceOs = ''});

  factory TransactionDevice.fromJson(Map<String, dynamic> json) {
    return TransactionDevice(
      deviceType: (json['device_type'] as String?) ?? '',
      deviceOs: (json['device_os'] as String?) ?? '',
    );
  }

  final String deviceType;
  final String deviceOs;

  Map<String, dynamic> toJson() => {
        'device_type': deviceType,
        'device_os': deviceOs,
      };
}

/// Records a change in transaction decision.
class DecisionChange {
  DecisionChange({
    required this.from,
    required this.to,
    this.reason = '',
    this.changedBy = '',
    required this.changedAt,
  });

  factory DecisionChange.fromJson(Map<String, dynamic> json) {
    return DecisionChange(
      from: (json['from'] as String?) ?? '',
      to: (json['to'] as String?) ?? '',
      reason: (json['reason'] as String?) ?? '',
      changedBy: (json['changed_by'] as String?) ?? '',
      changedAt: DateTime.parse(
        (json['changed_at'] as String?) ?? '1970-01-01T00:00:00Z',
      ),
    );
  }

  final String from;
  final String to;
  final String reason;
  final String changedBy;
  final DateTime changedAt;

  Map<String, dynamic> toJson() => {
        'from': from,
        'to': to,
        'reason': reason,
        'changed_by': changedBy,
        'changed_at': changedAt.toIso8601String(),
      };
}

/// Geographic location data.
class Geo {
  Geo({
    this.ip = '',
    this.lat = 0,
    this.lng = 0,
    this.country = '',
    this.city = '',
  });

  factory Geo.fromJson(Map<String, dynamic> json) {
    return Geo(
      ip: (json['ip'] as String?) ?? '',
      lat: (json['lat'] as num?)?.toDouble() ?? 0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0,
      country: (json['country'] as String?) ?? '',
      city: (json['city'] as String?) ?? '',
    );
  }

  final String ip;
  final double lat;
  final double lng;
  final String country;
  final String city;

  Map<String, dynamic> toJson() => {
        'ip': ip,
        'lat': lat,
        'lng': lng,
        'country': country,
        'city': city,
      };
}

/// API key information.
class APIKeyInfo {
  APIKeyInfo({
    required this.id,
    required this.projectId,
    this.name = '',
    this.state = '',
    this.services = const [],
    required this.createdAt,
    this.expiresAt,
  });

  factory APIKeyInfo.fromJson(Map<String, dynamic> json) {
    final svc = json['selected_services'];
    return APIKeyInfo(
      id: (json['id'] as String?) ?? '',
      projectId: (json['project_id'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      state: (json['state'] as String?) ?? '',
      services:
          svc is List ? svc.map((e) => e.toString()).toList() : const [],
      createdAt: DateTime.parse(
        (json['created_at'] as String?) ?? '1970-01-01T00:00:00Z',
      ),
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
    );
  }

  final String id;
  final String projectId;
  final String name;
  final String state;
  final List<String> services;
  final DateTime createdAt;
  final DateTime? expiresAt;

  Map<String, dynamic> toJson() {
    final result = <String, dynamic>{
      'id': id,
      'project_id': projectId,
      'name': name,
      'state': state,
      'selected_services': services,
      'created_at': createdAt.toIso8601String(),
    };
    if (expiresAt != null) {
      result['expires_at'] = expiresAt!.toIso8601String();
    }
    return result;
  }
}

/// Reads a required string field, or throws a [FormatException] instead of
/// silently using `''` (an empty deepfake check `status` would make a caller
/// that polls for `completed`/`failed` loop forever).
String _requireString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is String && value.isNotEmpty) return value;
  throw FormatException('Unexpected response: missing or invalid "$key"', json);
}
