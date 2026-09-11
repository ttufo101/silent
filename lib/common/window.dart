import 'dart:io';
import 'dart:math' as math;

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/config.dart';
import 'package:flutter/material.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:window_manager/window_manager.dart';

class Window {
  static Window? _instance;

  Window._internal();

  factory Window() {
    _instance ??= Window._internal();
    return _instance!;
  }

  Future<void> init(int version, WindowProps props) async {
    final acquire = await singleInstanceLock.acquire();
    if (!acquire) {
      exit(0);
    }
    if (system.isWindows) {
      protocol.register('clash');
      protocol.register('clashmeta');
      protocol.register('flclash');
    }
    await windowManager.ensureInitialized();
    final requestedSize =
        system.isWindows && props.width <= 0 && props.height <= 0
        ? const Size(1440, 1024)
        : props.size;
    final primaryDisplay = await screenRetriever.getPrimaryDisplay();
    final availableSize = primaryDisplay.visibleSize ?? primaryDisplay.size;
    final initialSize = Size(
      math.min(requestedSize.width, availableSize.width),
      math.min(requestedSize.height, availableSize.height),
    );
    final minimumSize = system.isWindows
        ? Size(
            math.min(1100, availableSize.width),
            math.min(720, availableSize.height),
          )
        : const Size(380, 400);
    final WindowOptions windowOptions = WindowOptions(
      size: initialSize,
      minimumSize: minimumSize,
    );
    if (!system.isMacOS || version > 10) {
      await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
    }
    await windowManager.setMaximizable(true);
    await _windowPosition(props);
    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.setPreventClose(true);
    });
  }

  Future<void> _windowPosition(WindowProps props) async {
    if (!system.isMacOS) {
      final left = props.left ?? 0;
      final top = props.top ?? 0;
      if (left == 0 && top == 0) {
        await windowManager.setAlignment(Alignment.center);
      } else {
        final displays = await screenRetriever.getAllDisplays();
        final width = props.width > 0 ? props.width : 1440.0;
        final height = props.height > 0 ? props.height : 1024.0;
        final windowBounds = Rect.fromLTWH(left, top, width, height);
        final matchingDisplays = displays
            .where((display) {
              final displaySize = display.visibleSize ?? display.size;
              final displayBounds = Rect.fromLTWH(
                display.visiblePosition?.dx ?? 0,
                display.visiblePosition?.dy ?? 0,
                displaySize.width,
                displaySize.height,
              );
              return displayBounds.overlaps(windowBounds);
            })
            .toList(growable: false);
        if (matchingDisplays.isEmpty) {
          await windowManager.setAlignment(Alignment.center);
          return;
        }
        final display = matchingDisplays.first;
        final displaySize = display.visibleSize ?? display.size;
        final displayLeft = display.visiblePosition?.dx ?? 0;
        final displayTop = display.visiblePosition?.dy ?? 0;
        final maxLeft = math.max(
          displayLeft,
          displayLeft + displaySize.width - math.min(width, displaySize.width),
        );
        final maxTop = math.max(
          displayTop,
          displayTop +
              displaySize.height -
              math.min(height, displaySize.height),
        );
        await windowManager.setPosition(
          Offset(
            left.clamp(displayLeft, maxLeft).toDouble(),
            top.clamp(displayTop, maxTop).toDouble(),
          ),
        );
      }
    }
  }

  Future<void> show() async {
    render?.resume();
    await windowManager.show();
    await windowManager.focus();
    await windowManager.setSkipTaskbar(false);
  }

  Future<bool> get isVisible async {
    final value = await windowManager.isVisible();
    commonPrint.log('window visible check: $value');
    return value;
  }

  Future<void> close() async {
    await windowManager.close();
  }

  void forceExit() {
    exit(0);
  }

  Future<void> hide() async {
    render?.pause();
    await windowManager.hide();
    await windowManager.setSkipTaskbar(true);
  }
}

final window = system.isDesktop ? Window() : null;
