/// Builds the boxed request / response text printed to the debug console.
///
/// Layout (same idea as the `pretty_dio_logger` package):
///
///     ╔╣ Request ║ GET
///     ║  https://...
///     ╚════════════
///     ╔ Headers
///     ║  accept: application/json
///     ╚════════════
class NetworkLogBox {
  static const int _width = 80;

  static String request(
    String method,
    Uri uri,
    Map<String, String>? headers, {
    String? body,
  }) {
    final headerLines = (headers == null || headers.isEmpty)
        ? ['  (none)']
        : headers.entries
              .map(
                (e) => '  ${e.key}: '
                    '${_isSensitiveHeader(e.key) ? '[REDACTED]' : e.value}',
              )
              .toList();

    return [
      _section('╣ Request ║ $method', ['  $uri']),
      _section(' Headers', headerLines),
      if (body != null) _section(' Body', ['  (omitted)']),
    ].join('\n');
  }

  static String response({
    required String method,
    required Uri? uri,
    required int statusCode,
    required String? reason,
    required int elapsedMs,
    required String body,
  }) {
    final status = reason == null || reason.isEmpty
        ? '$statusCode'
        : '$statusCode $reason';

    return [
      _section('╣ Response ║ $method ║ Status: $status ║ Time: $elapsedMs ms', [
        '  $uri',
      ]),
      _section(' Body', ['  (omitted)']),
    ].join('\n');
  }

  static String error(String method, Uri uri, String message, int elapsedMs) {
    return _section('╣ Error ║ $method ║ Time: $elapsedMs ms', [
      '  $uri',
      '  $message',
    ]);
  }

  static bool _isSensitiveHeader(String name) {
    final key = name.toLowerCase();
    return key == 'token' ||
        key == 'authorization' ||
        key == 'cookie' ||
        key == 'set-cookie' ||
        key == 'x-api-key';
  }

  static String _section(String title, List<String> lines) {
    return [
      '╔$title',
      ...lines.map((l) => '║$l'),
      '╚${'═' * _width}',
    ].join('\n');
  }
}
