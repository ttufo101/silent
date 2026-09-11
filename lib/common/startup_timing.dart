import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

class StartupTiming {
  final Stopwatch _total = Stopwatch();
  Duration _last = Duration.zero;
  bool _active = false;

  bool get isActive => _active;

  void start() {
    _total
      ..reset()
      ..start();
    _last = Duration.zero;
    _active = true;
    mark('start');
  }

  void mark(String stage) {
    if (!_active) return;
    final elapsed = _total.elapsed;
    final delta = elapsed - _last;
    _last = elapsed;
    final message =
        '$stage total=${elapsed.inMilliseconds}ms '
        'delta=${delta.inMilliseconds}ms';
    developer.log(message, name: 'startup');
    if (kDebugMode) {
      debugPrint('[startup] $message');
    }
  }

  void finish(String stage) {
    mark(stage);
    _total.stop();
    _active = false;
  }
}

final startupTiming = StartupTiming();
