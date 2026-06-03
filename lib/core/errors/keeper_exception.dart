/// Domain-level error used to signal invalid operations against the
/// route state machine (e.g. wrong QR, out-of-order action, unverified
/// manifest). The UI catches these and shows a friendly message.
class KeeperException implements Exception {
  final String message;
  const KeeperException(this.message);

  @override
  String toString() => 'KeeperException: $message';
}
