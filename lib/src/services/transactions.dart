import '../call_options.dart';
import '../client.dart';
import '../transport.dart';
import '../types.dart';

/// Handles transaction queries.
class TransactionService {
  TransactionService(this._transport);

  final BiometryTransport _transport;

  /// Returns transactions matching the given filters.
  Future<List<Transaction>> list(
    TransactionListRequest request, {
    String? fullname,
    String? sessionId,
    String? actionTrigger,
    String? deviceInfo,
    String? geoLocation,
    String? requestTags,
    String? clientApp,
    String? clientVersion,
  }) {
    return _transport.doJson<List<Transaction>>(
      'POST',
      '$pathTransactions/transactions/list',
      payload: request.toJson(),
      fromJson: (data) {
        if (data is List) {
          return data
              .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return [];
      },
      extraHeaders: buildCallHeaders(
        fullname: fullname,
        sessionId: sessionId,
        actionTrigger: actionTrigger,
        deviceInfo: deviceInfo,
        geoLocation: geoLocation,
        requestTags: requestTags,
        clientApp: clientApp,
        clientVersion: clientVersion,
      ),
    );
  }

  /// Returns the number of transactions matching the given filters.
  Future<int> count(
    TransactionListRequest request, {
    String? fullname,
    String? sessionId,
    String? actionTrigger,
    String? deviceInfo,
    String? geoLocation,
    String? requestTags,
    String? clientApp,
    String? clientVersion,
  }) {
    return _transport.doJson<int>(
      'POST',
      '$pathTransactions/transactions/count',
      payload: request.toJson(),
      fromJson: (data) {
        if (data is Map<String, dynamic>) {
          return (data['count'] as int?) ?? 0;
        }
        return 0;
      },
      extraHeaders: buildCallHeaders(
        fullname: fullname,
        sessionId: sessionId,
        actionTrigger: actionTrigger,
        deviceInfo: deviceInfo,
        geoLocation: geoLocation,
        requestTags: requestTags,
        clientApp: clientApp,
        clientVersion: clientVersion,
      ),
    );
  }

  /// Returns all transactions for a session.
  Future<List<Transaction>> getBySession(
    String sessionId, {
    String? fullname,
    String? actionTrigger,
    String? deviceInfo,
    String? geoLocation,
    String? requestTags,
    String? clientApp,
    String? clientVersion,
  }) {
    return _transport.doJson<List<Transaction>>(
      'GET',
      '$pathTransactions/transactions/sessions/$sessionId',
      fromJson: (data) {
        if (data is List) {
          return data
              .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return [];
      },
      extraHeaders: buildCallHeaders(
        fullname: fullname,
        actionTrigger: actionTrigger,
        deviceInfo: deviceInfo,
        geoLocation: geoLocation,
        requestTags: requestTags,
        clientApp: clientApp,
        clientVersion: clientVersion,
      ),
    );
  }

  /// Returns sample data for a transaction.
  Future<dynamic> getSamples(
    String id, {
    String? fullname,
    String? sessionId,
    String? actionTrigger,
    String? deviceInfo,
    String? geoLocation,
    String? requestTags,
    String? clientApp,
    String? clientVersion,
  }) {
    return _transport.doJson<dynamic>(
      'GET',
      '$pathTransactions/transactions/$id/samples',
      fromJson: (data) => data,
      extraHeaders: buildCallHeaders(
        fullname: fullname,
        sessionId: sessionId,
        actionTrigger: actionTrigger,
        deviceInfo: deviceInfo,
        geoLocation: geoLocation,
        requestTags: requestTags,
        clientApp: clientApp,
        clientVersion: clientVersion,
      ),
    );
  }

  /// Updates the tags on a transaction.
  Future<void> updateTags(
    String id,
    List<String> tags, {
    String? fullname,
    String? sessionId,
    String? actionTrigger,
    String? deviceInfo,
    String? geoLocation,
    String? requestTags,
    String? clientApp,
    String? clientVersion,
  }) {
    return _transport.doJson<void>(
      'PUT',
      '$pathTransactions/transactions/$id/tags',
      payload: {'tags': tags},
      extraHeaders: buildCallHeaders(
        fullname: fullname,
        sessionId: sessionId,
        actionTrigger: actionTrigger,
        deviceInfo: deviceInfo,
        geoLocation: geoLocation,
        requestTags: requestTags,
        clientApp: clientApp,
        clientVersion: clientVersion,
      ),
    );
  }

  /// Sets the fraud flag on a transaction.
  Future<void> flag(
    String id,
    String flag, {
    String? fullname,
    String? sessionId,
    String? actionTrigger,
    String? deviceInfo,
    String? geoLocation,
    String? requestTags,
    String? clientApp,
    String? clientVersion,
  }) {
    return _transport.doJson<void>(
      'PUT',
      '$pathTransactions/transactions/$id/flag',
      payload: {'flag': flag},
      extraHeaders: buildCallHeaders(
        fullname: fullname,
        sessionId: sessionId,
        actionTrigger: actionTrigger,
        deviceInfo: deviceInfo,
        geoLocation: geoLocation,
        requestTags: requestTags,
        clientApp: clientApp,
        clientVersion: clientVersion,
      ),
    );
  }
}
