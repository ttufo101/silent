import 'dart:io';

import 'package:fl_clash/common/tdesign.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// 设计 Token 导出器（单一来源：lib/common/tdesign.dart）
///
/// 直接构建真实主题读取取值，避免手写文档与代码漂移。
/// 运行（项目根目录）：
///   EXPORT_DESIGN_TOKENS=1 flutter test test/design_tokens_export_test.dart
///
/// 产物：docs/design-tokens/README.md
/// 未设置 EXPORT_DESIGN_TOKENS=1 时只做不变量校验，不写文件。
const _outDir = 'docs/design-tokens';

String _hex(Color c) =>
    '#${c.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}';

/// 整数值去掉小数尾巴（12.0 → 12），便于阅读
String _fmt(Object? v) {
  if (v == null) return '-';
  final n = v as num;
  return n == n.toInt() ? '${n.toInt()}' : '$n';
}

Map<String, dynamic> _typography(TextTheme textTheme) {
  Map<String, dynamic> style(TextStyle? s) => {
        'size': s?.fontSize,
        'lineHeight': s == null
            ? null
            : double.parse(
                ((s.height ?? 1) * (s.fontSize ?? 0)).toStringAsFixed(2),
              ),
        'weight': s?.fontWeight?.value ?? 400,
      };
  return {
    'bodySmall': style(textTheme.bodySmall),
    'bodyMedium': style(textTheme.bodyMedium),
    'bodyLarge': style(textTheme.bodyLarge),
    'labelSmall': style(textTheme.labelSmall),
    'labelMedium': style(textTheme.labelMedium),
    'labelLarge': style(textTheme.labelLarge),
    'titleSmall': style(textTheme.titleSmall),
    'titleMedium': style(textTheme.titleMedium),
    'titleLarge': style(textTheme.titleLarge),
    'headlineSmall': style(textTheme.headlineSmall),
    'headlineMedium': style(textTheme.headlineMedium),
    'headlineLarge': style(textTheme.headlineLarge),
  };
}

Map<String, dynamic> _collect(String platform, ViewMode viewMode) {
  final light = TDesignThemeData.build(
    brightness: Brightness.light,
    viewMode: viewMode,
  );
  final dark = TDesignThemeData.build(
    brightness: Brightness.dark,
    viewMode: viewMode,
  );
  final buttonMinSize =
      light.filledButtonTheme.style?.minimumSize?.resolve(<WidgetState>{});
  return {
    'platform': platform,
    'viewMode': viewMode.name,
    'tokensLight': light.extension<TDesignTokens>()!,
    'tokensDark': dark.extension<TDesignTokens>()!,
    'radius': {
      'card': TDesignRadius.card,
      'control': TDesignRadius.control(viewMode),
      'sheet': TDesignRadius.sheet(viewMode),
      'tag': TDesignRadius.tag(viewMode),
    },
    'typography': _typography(light.textTheme),
    'size': {
      'buttonMinHeight': buttonMinSize?.height,
      'navigationBarHeight': light.navigationBarTheme.height,
    },
  };
}

String _markdown(Map<String, dynamic> android, Map<String, dynamic> desktop) {
  final b = StringBuffer()
    ..writeln('# Design Tokens（Android / Desktop）')
    ..writeln()
    ..writeln('> 本文件由代码自动生成，**请勿手改**。')
    ..writeln('>')
    ..writeln('> - 单一来源：`lib/common/tdesign.dart`')
    ..writeln(
      '> - 重新导出：`EXPORT_DESIGN_TOKENS=1 flutter test '
      'test/design_tokens_export_test.dart`',
    )
    ..writeln('> - 颜色为 Flutter 的 ARGB 格式 `#AARRGGBB`')
    ..writeln();

  // 圆角
  b
    ..writeln('## 圆角 Radius（两端不同）')
    ..writeln()
    ..writeln('| Token | Android (mobile) | Desktop | 说明 |')
    ..writeln('| --- | --- | --- | --- |');
  const radiusDesc = {
    'card': '卡片',
    'control': '按钮 / 输入框 / FAB',
    'sheet': '底部面板 / 对话框',
    'tag': '小标签 / Chip',
  };
  for (final key in ['card', 'control', 'sheet', 'tag']) {
    b.writeln(
      '| `radius.$key` | ${_fmt(android['radius'][key])} | '
      '${_fmt(desktop['radius'][key])} | ${radiusDesc[key]} |',
    );
  }
  b.writeln();

  // 字号
  b
    ..writeln('## 字号 Typography（两端不同，size / lineHeight / weight）')
    ..writeln()
    ..writeln('| Token | Android (mobile) | Desktop |')
    ..writeln('| --- | --- | --- |');
  final typoKeys = (android['typography'] as Map<String, dynamic>).keys;
  for (final key in typoKeys) {
    final a = android['typography'][key] as Map<String, dynamic>;
    final d = desktop['typography'][key] as Map<String, dynamic>;
    b.writeln(
      '| `$key` | ${_fmt(a['size'])} / ${_fmt(a['lineHeight'])} / '
      'w${a['weight']} | ${_fmt(d['size'])} / ${_fmt(d['lineHeight'])} / '
      'w${d['weight']} |',
    );
  }
  b
    ..writeln()
    ..writeln(
      '字体：PingFang SC → 回退 Noto Sans SC → Roboto → sans-serif'
      '（安卓无 PingFang SC 时靠回退链保证跨平台一致）',
    )
    ..writeln();

  // 尺寸
  b
    ..writeln('## 尺寸 Size')
    ..writeln()
    ..writeln('| Token | Android (mobile) | Desktop |')
    ..writeln('| --- | --- | --- |')
    ..writeln(
      '| 按钮最小高度 | ${_fmt(android['size']['buttonMinHeight'])} | '
      '${_fmt(desktop['size']['buttonMinHeight'])} |',
    )
    ..writeln(
      '| 底部导航栏高度 | ${_fmt(android['size']['navigationBarHeight'])} | '
      '${_fmt(desktop['size']['navigationBarHeight'])} |',
    )
    ..writeln();

  // 颜色（两端一致）
  final light = android['tokensLight'] as TDesignTokens;
  final dark = android['tokensDark'] as TDesignTokens;

  b
    ..writeln('## 中性色 / 文字色（两端一致）')
    ..writeln()
    ..writeln('| Token | 浅色 | 深色 | 说明 |')
    ..writeln('| --- | --- | --- | --- |');
  final neutrals = <String, List<dynamic>>{
    'pageBackground': [light.pageBackground, dark.pageBackground, '页面背景'],
    'container': [light.container, dark.container, '卡片 / 容器'],
    'secondaryContainer': [
      light.secondaryContainer,
      dark.secondaryContainer,
      '次级容器',
    ],
    'component': [light.component, dark.component, '组件填充'],
    'componentStroke': [
      light.componentStroke,
      dark.componentStroke,
      '分割线 / 描边（细）',
    ],
    'componentBorder': [
      light.componentBorder,
      dark.componentBorder,
      '边框',
    ],
    'textPlaceholder': [
      light.textPlaceholder,
      dark.textPlaceholder,
      '三级文字（占位符）',
    ],
    'textDisabled': [light.textDisabled, dark.textDisabled, '四级文字（禁用）'],
  };
  for (final entry in neutrals.entries) {
    b.writeln(
      '| `${entry.key}` | ${_hex(entry.value[0] as Color)} | '
      '${_hex(entry.value[1] as Color)} | ${entry.value[2]} |',
    );
  }
  b.writeln();

  // 语义色
  final semantics = <String, List<TDesignStateColor>>{
    'brand': [light.brand, dark.brand],
    'success': [light.success, dark.success],
    'warning': [light.warning, dark.warning],
    'error': [light.error, dark.error],
  };
  const stateDesc = {
    'color': '常规',
    'hover': '悬浮',
    'focus': '聚焦',
    'active': '点击',
    'disabled': '禁用',
    'light': '浅色背景',
    'lightHover': '浅色背景悬浮',
  };
  Color stateColor(TDesignStateColor c, String state) => switch (state) {
        'color' => c.color,
        'hover' => c.hover,
        'focus' => c.focus,
        'active' => c.active,
        'disabled' => c.disabled,
        'light' => c.light,
        _ => c.lightHover,
      };

  b
    ..writeln('## 语义色 Semantic（两端一致）')
    ..writeln()
    ..writeln('| Token | 状态 | 浅色 | 深色 |')
    ..writeln('| --- | --- | --- | --- |');
  for (final entry in semantics.entries) {
    for (final state in stateDesc.keys) {
      b.writeln(
        '| `${entry.key}` | $state（${stateDesc[state]}） | '
        '${_hex(stateColor(entry.value[0], state))} | '
        '${_hex(stateColor(entry.value[1], state))} |',
      );
    }
  }
  b.writeln();

  // 映射到代码
  b
    ..writeln('## 代码映射')
    ..writeln()
    ..writeln('| 用途 | 写法 |')
    ..writeln('| --- | --- |')
    ..writeln('| 取中性色 | `context.tDesign.container` |')
    ..writeln('| 取语义常规色 | `context.tDesign.brand.color` |')
    ..writeln('| 取语义浅色背景 | `context.tDesign.error.light` |')
    ..writeln('| 取圆角 | `TDesignRadius.control(viewMode)` |')
    ..writeln('| 取文字样式 | `context.textTheme.bodyMedium` |')
    ..writeln()
    ..writeln(
      '> 两端差异由 `ViewMode` 驱动（窗口宽度跨 600px 阈值自动切换 '
      'mobile ↔ laptop/desktop），无需为平台写分支。',
    );
  return b.toString();
}

void main() {
  testWidgets('export design tokens', (tester) async {
    final android = _collect('android', ViewMode.mobile);
    final desktop = _collect('desktop', ViewMode.desktop);

    // 不变量校验：防止 token 被误改
    expect(
      (android['radius']['control'] as num) >
          (desktop['radius']['control'] as num),
      isTrue,
      reason: '移动端控件圆角应大于桌面端',
    );
    expect(
      (android['typography']['bodyMedium']['size'] as num) >
          (desktop['typography']['bodyMedium']['size'] as num),
      isTrue,
      reason: '移动端正文字号应大于桌面端',
    );
    expect(
      (android['size']['buttonMinHeight'] as num) >
          (desktop['size']['buttonMinHeight'] as num),
      isTrue,
      reason: '移动端按钮高度应大于桌面端',
    );

    if (Platform.environment['EXPORT_DESIGN_TOKENS'] != '1') return;
    final dir = Directory(_outDir)..createSync(recursive: true);
    File('${dir.path}/README.md').writeAsStringSync(
      '${_markdown(android, desktop)}\n',
    );
  });
}
