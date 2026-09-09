import 'dart:async';
import 'dart:io';

import 'package:fl_clash/pages/error.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rust_api/rust_api.dart';

import 'application.dart';
import 'common/common.dart';

Future<void> main() async {
  startupTiming.start();
  WidgetsFlutterBinding.ensureInitialized();
  startupTiming.mark('flutter binding ready');
  try {
    if (system.isDesktop) {
      await RustLib.init();
      startupTiming.mark('desktop rust ready');
    }
    final version = await system.init();
    startupTiming.mark('system ready');
    final container = await globalState.init(version);
    startupTiming.mark('global state ready');
    HttpOverrides.global = FlClashHttpOverrides();
    runApp(
      UncontrolledProviderScope(
        container: container,
        child: const Application(),
      ),
    );
    startupTiming.mark('runApp called');
  } catch (e, s) {
    startupTiming.finish('startup failed');
    runApp(
      MaterialApp(
        home: InitErrorScreen(error: e, stack: s),
      ),
    );
  }
}
