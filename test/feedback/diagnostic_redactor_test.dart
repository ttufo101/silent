import 'package:fl_clash/feedback/services/diagnostic_redactor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('redacts sensitive values without throwing', () {
    final result = DiagnosticRedactor().redact(
      r'Authorization: Bearer AbC.123_X-y password=Secret123 '
      r'access_token:"token-value" C:\Users\ford\silent '
      'ygliu1921@gmail.com',
    );

    expect(result, contains('Bearer [REDACTED]'));
    expect(result, contains('password=[REDACTED]'));
    expect(result, contains(r'access_token:"[REDACTED]"'));
    expect(result, contains(r'C:\Users\[USER]\silent'));
    expect(result, contains('yg***@gmail.com'));
    expect(result, isNot(contains('Secret123')));
    expect(result, isNot(contains('token-value')));
  });
}
