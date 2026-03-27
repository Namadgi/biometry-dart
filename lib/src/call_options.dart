/// Builds optional per-request headers from named parameters.
Map<String, String> buildCallHeaders({
  String? fullname,
  String? sessionId,
  String? actionTrigger,
  String? deviceInfo,
  String? geoLocation,
  String? requestTags,
  String? clientApp,
  String? clientVersion,
  bool? inhouseDocAuth,
  bool? mrzValidation,
}) {
  final headers = <String, String>{};
  if (fullname != null) headers['X-User-Fullname'] = fullname;
  if (sessionId != null) headers['X-Session-ID'] = sessionId;
  if (actionTrigger != null) headers['X-Action-Trigger'] = actionTrigger;
  if (deviceInfo != null) headers['X-Device-Info'] = deviceInfo;
  if (geoLocation != null) headers['X-Geo-Location'] = geoLocation;
  if (requestTags != null) headers['X-Request-Tags'] = requestTags;
  if (clientApp != null) headers['X-Client-App'] = clientApp;
  if (clientVersion != null) headers['X-Client-Version'] = clientVersion;
  if (inhouseDocAuth != null) {
    headers['X-Inhouse-Docauth'] = inhouseDocAuth.toString();
  }
  if (mrzValidation == true) headers['X-Inhouse-MRZ'] = 'true';
  return headers;
}
