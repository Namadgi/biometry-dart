/// Builds optional per-request metadata headers from named parameters.
///
/// For API v2 gateway operations, identity/session/trigger/document-provider/
/// prefilled-video selection are NOT headers — they are fields of the per-call
/// input objects (carried in the JSON `request` part), and the gateway strips
/// the corresponding headers. The `fullname` / `sessionId` / `actionTrigger`
/// options remain here only for the non-gateway services (transactions, API
/// keys), which are unaffected by the v2 migration.
Map<String, String> buildCallHeaders({
  String? fullname,
  String? sessionId,
  String? actionTrigger,
  String? deviceInfo,
  String? geoLocation,
  String? requestTags,
  String? clientApp,
  String? clientVersion,
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
  return headers;
}
