import 'package:fl_clash/enum/enum.dart';
import 'package:flutter/material.dart';

/// 语义色（brand / success / warning / error）的完整状态集。
/// 取值对照 TDesign 官方色彩规范：color=常规、hover=悬浮、focus=聚焦、
/// active=点击、disabled=禁用、light=浅色背景、lightHover=浅色背景悬浮。
/// 命名后数字为官方色板级数，例如 brand light: color=7、hover=6、active=8、
/// disabled=3、light=1、light-hover=2。
@immutable
class TDesignStateColor {
  final Color color; // 常规
  final Color hover; // 悬浮
  final Color focus; // 聚焦
  final Color active; // 点击
  final Color disabled; // 禁用
  final Color light; // 浅色背景
  final Color lightHover; // 浅色背景悬浮

  const TDesignStateColor({
    required this.color,
    required this.hover,
    required this.focus,
    required this.active,
    required this.disabled,
    required this.light,
    required this.lightHover,
  });

  TDesignStateColor copyWith({
    Color? color,
    Color? hover,
    Color? focus,
    Color? active,
    Color? disabled,
    Color? light,
    Color? lightHover,
  }) {
    return TDesignStateColor(
      color: color ?? this.color,
      hover: hover ?? this.hover,
      focus: focus ?? this.focus,
      active: active ?? this.active,
      disabled: disabled ?? this.disabled,
      light: light ?? this.light,
      lightHover: lightHover ?? this.lightHover,
    );
  }

  TDesignStateColor lerp(TDesignStateColor? other, double t) {
    if (other == null) return this;
    return TDesignStateColor(
      color: Color.lerp(color, other.color, t)!,
      hover: Color.lerp(hover, other.hover, t)!,
      focus: Color.lerp(focus, other.focus, t)!,
      active: Color.lerp(active, other.active, t)!,
      disabled: Color.lerp(disabled, other.disabled, t)!,
      light: Color.lerp(light, other.light, t)!,
      lightHover: Color.lerp(lightHover, other.lightHover, t)!,
    );
  }
}

@immutable
class TDesignTokens extends ThemeExtension<TDesignTokens> {
  final Color pageBackground;
  final Color container;
  final Color secondaryContainer;
  final Color component;
  final Color componentStroke;
  final Color componentBorder;
  final TDesignStateColor brand;
  final TDesignStateColor success;
  final TDesignStateColor warning;
  final TDesignStateColor error;

  /// 三级文字（占位符）：浅色 #000 40% / 深色 #FFF 35%
  final Color textPlaceholder;

  /// 四级文字（禁用）：浅色 #000 26% / 深色 #FFF 22%
  final Color textDisabled;

  const TDesignTokens({
    required this.pageBackground,
    required this.container,
    required this.secondaryContainer,
    required this.component,
    required this.componentStroke,
    required this.componentBorder,
    required this.brand,
    required this.success,
    required this.warning,
    required this.error,
    required this.textPlaceholder,
    required this.textDisabled,
  });

  static const light = TDesignTokens(
    pageBackground: Color(0xFFEEEEEE),
    container: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFF3F3F3),
    component: Color(0xFFE8E8E8),
    componentStroke: Color(0xFFE8E8E8),
    componentBorder: Color(0xFFDDDDDD),
    // brand light: 7/6/2/8/3/1/2
    brand: TDesignStateColor(
      color: Color(0xFF0052D9),
      hover: Color(0xFF366EF4),
      focus: Color(0xFFD9E1FF),
      active: Color(0xFF003CAB),
      disabled: Color(0xFFB5C7FF),
      light: Color(0xFFF2F3FF),
      lightHover: Color(0xFFD9E1FF),
    ),
    // success light: 5/4/2/6/3/1/2
    success: TDesignStateColor(
      color: Color(0xFF2BA471),
      hover: Color(0xFF56C08D),
      focus: Color(0xFFC6F3D7),
      active: Color(0xFF008858),
      disabled: Color(0xFF92DAB2),
      light: Color(0xFFE3F9E9),
      lightHover: Color(0xFFC6F3D7),
    ),
    // warning light: 5/4/2/6/3/1/2
    warning: TDesignStateColor(
      color: Color(0xFFE37318),
      hover: Color(0xFFFA9550),
      focus: Color(0xFFFFD9C2),
      active: Color(0xFFBE5A00),
      disabled: Color(0xFFFFB98C),
      light: Color(0xFFFFF1E9),
      lightHover: Color(0xFFFFD9C2),
    ),
    // error light: 6/5/2/7/3/1/2
    error: TDesignStateColor(
      color: Color(0xFFD54941),
      hover: Color(0xFFF6685D),
      focus: Color(0xFFFFD8D2),
      active: Color(0xFFAD352F),
      disabled: Color(0xFFFFB9B0),
      light: Color(0xFFFFF0ED),
      lightHover: Color(0xFFFFD8D2),
    ),
    textPlaceholder: Color(0x66000000),
    textDisabled: Color(0x42000000),
  );

  static const dark = TDesignTokens(
    pageBackground: Color(0xFF181818),
    container: Color(0xFF242424),
    secondaryContainer: Color(0xFF2C2C2C),
    component: Color(0xFF393939),
    componentStroke: Color(0xFF393939),
    componentBorder: Color(0xFF5E5E5E),
    // brand dark: 沿用现有主色 8 级；深色模式下 hover 更亮(+1)、active 更暗(-1)
    brand: TDesignStateColor(
      color: Color(0xFF4582E6),
      hover: Color(0xFF699EF5),
      focus: Color(0xFF173463),
      active: Color(0xFF2667D4),
      disabled: Color(0xFF143975),
      light: Color(0xFF1B2F51),
      lightHover: Color(0xFF173463),
    ),
    // success dark: 5/6/2/4/3/1/2
    success: TDesignStateColor(
      color: Color(0xFF059465),
      hover: Color(0xFF43AF8A),
      focus: Color(0xFF1A4230),
      active: Color(0xFF0D7A55),
      disabled: Color(0xFF17533D),
      light: Color(0xFF193A2A),
      lightHover: Color(0xFF1A4230),
    ),
    // warning dark: 5/6/2/4/3/1/2
    warning: TDesignStateColor(
      color: Color(0xFFCF6E2D),
      hover: Color(0xFFDC7633),
      focus: Color(0xFF582F21),
      active: Color(0xFFA75D2B),
      disabled: Color(0xFF733C23),
      light: Color(0xFF4F2A1D),
      lightHover: Color(0xFF582F21),
    ),
    // error dark: 6/7/2/5/3/1/2
    error: TDesignStateColor(
      color: Color(0xFFC64751),
      hover: Color(0xFFDE6670),
      focus: Color(0xFF5E2A2D),
      active: Color(0xFFA03F46),
      disabled: Color(0xFF703439),
      light: Color(0xFF472324),
      lightHover: Color(0xFF5E2A2D),
    ),
    textPlaceholder: Color(0x59FFFFFF),
    textDisabled: Color(0x38FFFFFF),
  );

  @override
  TDesignTokens copyWith({
    Color? pageBackground,
    Color? container,
    Color? secondaryContainer,
    Color? component,
    Color? componentStroke,
    Color? componentBorder,
    TDesignStateColor? brand,
    TDesignStateColor? success,
    TDesignStateColor? warning,
    TDesignStateColor? error,
    Color? textPlaceholder,
    Color? textDisabled,
  }) {
    return TDesignTokens(
      pageBackground: pageBackground ?? this.pageBackground,
      container: container ?? this.container,
      secondaryContainer: secondaryContainer ?? this.secondaryContainer,
      component: component ?? this.component,
      componentStroke: componentStroke ?? this.componentStroke,
      componentBorder: componentBorder ?? this.componentBorder,
      brand: brand ?? this.brand,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      textPlaceholder: textPlaceholder ?? this.textPlaceholder,
      textDisabled: textDisabled ?? this.textDisabled,
    );
  }

  @override
  TDesignTokens lerp(TDesignTokens? other, double t) {
    if (other == null) return this;
    return TDesignTokens(
      pageBackground: Color.lerp(pageBackground, other.pageBackground, t)!,
      container: Color.lerp(container, other.container, t)!,
      secondaryContainer: Color.lerp(
        secondaryContainer,
        other.secondaryContainer,
        t,
      )!,
      component: Color.lerp(component, other.component, t)!,
      componentStroke: Color.lerp(componentStroke, other.componentStroke, t)!,
      componentBorder: Color.lerp(componentBorder, other.componentBorder, t)!,
      brand: brand.lerp(other.brand, t),
      success: success.lerp(other.success, t),
      warning: warning.lerp(other.warning, t),
      error: error.lerp(other.error, t),
      textPlaceholder: Color.lerp(textPlaceholder, other.textPlaceholder, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
    );
  }
}

class TDesignThemeData {
  static ThemeData build({
    required Brightness brightness,
    required ViewMode viewMode,
  }) {
    final isDark = brightness == Brightness.dark;
    final tokens = isDark ? TDesignTokens.dark : TDesignTokens.light;
    final brand = tokens.brand.color;
    final error = tokens.error.color;
    final baseScheme = isDark
        ? ColorScheme.dark(
            primary: brand,
            secondary: const Color(0x8CFFFFFF),
            tertiary: tokens.warning.color,
            surface: const Color(0xFF242424),
            error: error,
            onPrimary: Colors.white,
            onSurface: const Color(0xE5FFFFFF),
            onError: Colors.white,
          )
        : ColorScheme.light(
            primary: brand,
            secondary: const Color(0x99000000),
            tertiary: tokens.warning.color,
            surface: Colors.white,
            error: error,
            onPrimary: Colors.white,
            onSurface: const Color(0xE5000000),
            onError: Colors.white,
          );
    final colorScheme = baseScheme.copyWith(
      primary: brand,
      onPrimary: Colors.white,
      primaryContainer: isDark
          ? const Color(0xFF1B2F51)
          : const Color(0xFFF2F3FF),
      onPrimaryContainer: isDark
          ? const Color(0xFF96BBF8)
          : const Color(0xFF001A57),
      surface: tokens.container,
      onSurface: isDark ? const Color(0xE5FFFFFF) : const Color(0xE5000000),
      onSurfaceVariant: isDark
          ? const Color(0x8CFFFFFF)
          : const Color(0x99000000),
      surfaceContainerLowest: tokens.container,
      surfaceContainerLow: tokens.container,
      surfaceContainer: tokens.secondaryContainer,
      surfaceContainerHigh: tokens.component,
      surfaceContainerHighest: tokens.componentBorder,
      outline: tokens.componentBorder,
      outlineVariant: tokens.componentStroke,
      error: error,
      onError: Colors.white,
    );
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: tokens.pageBackground,
    );
    final textTheme = _buildTextTheme(
      base.textTheme,
      colorScheme.onSurface,
      viewMode,
    );
    // 圆角按 ViewMode 区分：移动端(触控)偏大、桌面端(密度)偏小，对照两端规范 §2.2
    final radiusControl = BorderRadius.circular(
      TDesignRadius.control(viewMode),
    );
    final radiusCard = BorderRadius.circular(TDesignRadius.card);
    final shapeControl = RoundedRectangleBorder(borderRadius: radiusControl);
    final shapeCard = RoundedRectangleBorder(borderRadius: radiusCard);
    // 按钮最小高度：移动端 48（规范 §4.1），桌面端 40（规范 §4.1 标准档）
    final buttonMinSize = Size(
      viewMode == ViewMode.mobile ? 48 : 40,
      viewMode == ViewMode.mobile ? 48 : 40,
    );
    return base.copyWith(
      textTheme: textTheme,
      extensions: [tokens],
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: tokens.container,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: tokens.container,
        margin: EdgeInsets.zero,
        shape: shapeCard,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: buttonMinSize,
          shape: shapeControl,
          textStyle: textTheme.titleMedium,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: buttonMinSize,
          side: BorderSide(color: tokens.componentBorder),
          shape: shapeControl,
          textStyle: textTheme.titleMedium,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: brand,
          minimumSize: buttonMinSize,
          shape: shapeControl,
          textStyle: textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: tokens.container,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: radiusControl,
          borderSide: BorderSide(color: tokens.componentBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: radiusControl,
          borderSide: BorderSide(color: tokens.componentBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radiusControl,
          borderSide: BorderSide(color: brand, width: 2),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: tokens.componentStroke,
        thickness: 0.5,
        space: 0.5,
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 64,
        elevation: 0,
        backgroundColor: tokens.container,
        indicatorColor: tokens.brand.light,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? textTheme.labelSmall?.copyWith(color: brand)
              : textTheme.bodySmall;
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        elevation: 0,
        backgroundColor: tokens.container,
        indicatorColor: tokens.brand.light,
        selectedIconTheme: IconThemeData(color: brand),
        selectedLabelTextStyle: textTheme.labelMedium?.copyWith(color: brand),
        unselectedLabelTextStyle: textTheme.bodySmall,
      ),
      dialogTheme: DialogThemeData(
        elevation: 8,
        backgroundColor: tokens.container,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TDesignRadius.sheet(viewMode)),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        elevation: 8,
        backgroundColor: tokens.container,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(TDesignRadius.sheet(viewMode)),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: radiusControl),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? brand
              : colorScheme.onSurfaceVariant;
        }),
      ),
      switchTheme: SwitchThemeData(
        // 移除 shrinkWrap：恢复默认 48px 触控热区，满足规范 §4.6
        trackOutlineWidth: const WidgetStatePropertyAll(0),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return isDark ? const Color(0xFF5E5E5E) : const Color(0xFFDDDDDD);
          }
          return tokens.container;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return tokens.component;
          }
          return states.contains(WidgetState.selected)
              ? brand
              : tokens.componentBorder;
        }),
      ),
    );
  }

  static TextTheme _buildTextTheme(
    TextTheme base,
    Color color,
    ViewMode viewMode,
  ) {
    TextStyle style(double size, double lineHeight, FontWeight weight) {
      return TextStyle(
        color: color,
        // iOS 使用 PingFang SC；安卓无此字体，通过 fallback 显式回退到
        // Noto Sans SC / Roboto，避免裸回退，满足规范 §6 跨平台一致性。
        fontFamily: 'PingFang SC',
        fontFamilyFallback: const ['Noto Sans SC', 'Roboto', 'sans-serif'],
        fontSize: size,
        fontWeight: weight,
        height: lineHeight / size,
        letterSpacing: 0,
      );
    }

    final isMobile = viewMode == ViewMode.mobile;
    // 字号按端区分：移动端遵循移动规范（正文 16），桌面端遵循桌面规范（正文 13–14，高密度生产力）
    double sz(double mobile, double desktop) => isMobile ? mobile : desktop;
    double lh(double mobile, double desktop) => isMobile ? mobile : desktop;

    return base.copyWith(
      bodySmall: style(sz(12, 12), lh(20, 18), FontWeight.w400),
      bodyMedium: style(sz(14, 13), lh(22, 20), FontWeight.w400),
      bodyLarge: style(sz(16, 14), lh(24, 22), FontWeight.w400),
      labelSmall: style(10, 16, FontWeight.w600),
      labelMedium: style(12, 20, FontWeight.w600),
      labelLarge: style(sz(14, 14), lh(22, 20), FontWeight.w600),
      titleSmall: style(sz(14, 14), lh(22, 20), FontWeight.w600),
      titleMedium: style(sz(16, 14), lh(24, 20), FontWeight.w600),
      titleLarge: style(sz(18, 16), lh(26, 24), FontWeight.w600),
      headlineSmall: style(sz(24, 20), lh(32, 28), FontWeight.w600),
      headlineMedium: style(sz(28, 24), lh(36, 32), FontWeight.w600),
      headlineLarge: style(sz(36, 32), lh(44, 40), FontWeight.w600),
      displayMedium: style(sz(48, 40), lh(56, 48), FontWeight.w600),
      displayLarge: style(sz(64, 56), lh(72, 64), FontWeight.w600),
    );
  }
}

/// 圆角单一来源。注意：移动端规范与桌面端规范在多处存在硬性冲突，需按 ViewMode 区分
/// （见下方 control/sheet/tag 的方法式取值）：
///   - 控件圆角：移动 10–12 vs 桌面 6–8
///   - 面板/对话框圆角：移动 20–24 vs 桌面 12–16
///   - 标签圆角：移动 6 vs 桌面 4
/// 而「卡片圆角 12」在两端规范（移动 12–16 / 桌面 8–12）都满足，作为共享常量，无需按端区分。
class TDesignRadius {
  // 共享：卡片圆角 12，两端规范都满足
  static const double card = 12; // 卡片

  // 仅移动端取值（触控优先，圆角偏大）
  static const double _mobileControl = 12; // 按钮、输入框、FAB
  static const double _mobileSheet = 20; // 底部面板、对话框
  static const double _mobileTag = 6; // 小标签 / Chip

  // 仅桌面端取值（高密度，圆角偏小）
  static const double _desktopControl = 8;
  static const double _desktopSheet = 12;
  static const double _desktopTag = 4;

  /// 控件圆角：按端区分
  static double control(ViewMode viewMode) =>
      viewMode == ViewMode.mobile ? _mobileControl : _desktopControl;

  /// 面板/对话框圆角：按端区分
  static double sheet(ViewMode viewMode) =>
      viewMode == ViewMode.mobile ? _mobileSheet : _desktopSheet;

  /// 标签圆角：按端区分
  static double tag(ViewMode viewMode) =>
      viewMode == ViewMode.mobile ? _mobileTag : _desktopTag;
}

extension TDesignBuildContext on BuildContext {
  TDesignTokens get tDesign => Theme.of(this).extension<TDesignTokens>()!;
}
