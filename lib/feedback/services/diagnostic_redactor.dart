class DiagnosticRedactor {
  static final _bearer = RegExp(
    r'bearer\s+[a-z0-9._~+\-/]+=*',
    caseSensitive: false,
  );
  static final _sensitiveField = RegExp(
    r'''(access[_-]?token|refresh[_-]?token|jwt[_-]?token|password|passwd|verification[_-]?code|reset[_-]?token)(["']?\s*[:=]\s*["']?)([^\s,"'}]+)''',
    caseSensitive: false,
  );
  static final _email = RegExp(
    r'([a-zA-Z0-9._%+-]{1,2})[a-zA-Z0-9._%+-]*(@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,})',
  );
  static final _windowsUserPath = RegExp(
    r'([a-z]:\\users\\)[^\\\s]+',
    caseSensitive: false,
  );
  static final _longBase64 = RegExp(r'[A-Za-z0-9+/=_-]{160,}');

  String redact(String input) {
    return input
        .replaceAll(_bearer, 'Bearer [REDACTED]')
        .replaceAllMapped(
          _sensitiveField,
          (match) => '${match.group(1)}${match.group(2)}[REDACTED]',
        )
        .replaceAllMapped(
          _email,
          (match) => '${match.group(1)}***${match.group(2)}',
        )
        .replaceAllMapped(
          _windowsUserPath,
          (match) => '${match.group(1)}[USER]',
        )
        .replaceAll(_longBase64, '[REDACTED_LONG_DATA]');
  }
}
