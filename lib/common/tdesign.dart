import 'package:flutter/material.dart';

@immutable
class TDesignTokens extends ThemeExtension<TDesignTokens> {
  final Color pageBackground;
  final Color container;
  final Color secondaryContainer;
  final Color component;
  final Color componentStroke;
  final Color componentBorder;
  final Color success;
  final Color warning;

  const TDesignTokens({
    required this.pageBackground,
    required this.container,
    required this.secondaryContainer,
    required this.component,
    required this.componentStroke,
    required this.componentBorder,
    required this.success,
    required this.warning,
  });

  static const light = TDesignTokens(
    pageBackground: Color(0xFFEEEEEE),
    container: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFF3F3F3),
    component: Color(0xFFE8E8E8),
    componentStroke: Color(0xFFE8E8E8),
    componentBorder: Color(0xFFDDDDDD),
    success: Color(0xFF2BA471),
    warning: Color(0xFFE37318),
  );

  static const dark = TDesignTokens(
    pageBackground: Color(0xFF181818),
    container: Color(0xFF242424),
    secondaryContainer: Color(0xFF2C2C2C),
    component: Color(0xFF393939),
    componentStroke: Color(0xFF393939),
    componentBorder: Color(0xFF5E5E5E),
    success: Color(0xFF059465),
    warning: Color(0xFFCF6E2D),
  );

  @override
  TDesignTokens copyWith({
    Color? pageBackground,
    Color? container,
    Color? secondaryContainer,
    Color? component,
    Color? componentStroke,
    Color? componentBorder,
    Color? success,
    Color? warning,
  }) {
    return TDesignTokens(
      pageBackground: pageBackground ?? this.pageBackground,
      container: container ?? this.container,
      secondaryContainer: secondaryContainer ?? this.secondaryContainer,
      component: component ?? this.component,
      componentStroke: componentStroke ?? this.componentStroke,
      componentBorder: componentBorder ?? this.componentBorder,
      success: success ?? this.success,
      warning: warning ?? this.warning,
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
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
    );
  }
}

class TDesignThemeData {
  static const _lightBrand = Color(0xFF0052D9);
  static const _darkBrand = Color(0xFF4582E6);
  static const _lightError = Color(0xFFD54941);
  static const _darkError = Color(0xFFC64751);

  static ThemeData build({required Brightness brightness}) {
    final isDark = brightness == Brightness.dark;
    final tokens = isDark ? TDesignTokens.dark : TDesignTokens.light;
    final brand = isDark ? _darkBrand : _lightBrand;
    final baseScheme = isDark
        ? const ColorScheme.dark(
            primary: _darkBrand,
            secondary: Color(0x8CFFFFFF),
            tertiary: Color(0xFFCF6E2D),
            surface: Color(0xFF242424),
            error: _darkError,
            onPrimary: Colors.white,
            onSurface: Color(0xE5FFFFFF),
            onError: Colors.white,
          )
        : const ColorScheme.light(
            primary: _lightBrand,
            secondary: Color(0x99000000),
            tertiary: Color(0xFFE37318),
            surface: Colors.white,
            error: _lightError,
            onPrimary: Colors.white,
            onSurface: Color(0xE5000000),
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
      error: isDark ? _darkError : _lightError,
      onError: Colors.white,
    );
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: tokens.pageBackground,
    );
    final textTheme = _buildTextTheme(base.textTheme, colorScheme.onSurface);
    final radius6 = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(6),
    );
    final radius9 = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(9),
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
        shape: radius9,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: radius6,
          textStyle: textTheme.titleMedium,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          side: BorderSide(color: tokens.componentBorder),
          shape: radius6,
          textStyle: textTheme.titleMedium,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: tokens.container,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 13,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: tokens.componentBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: tokens.componentBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
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
        indicatorColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? textTheme.labelSmall?.copyWith(color: brand)
              : textTheme.bodySmall;
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        elevation: 0,
        backgroundColor: tokens.container,
        indicatorColor: const Color(0x00000000),
        selectedIconTheme: IconThemeData(color: brand),
        selectedLabelTextStyle: textTheme.labelMedium?.copyWith(color: brand),
        unselectedLabelTextStyle: textTheme.bodySmall,
      ),
      dialogTheme: DialogThemeData(
        elevation: 8,
        backgroundColor: tokens.container,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        elevation: 8,
        backgroundColor: tokens.container,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? brand
              : colorScheme.onSurfaceVariant;
        }),
      ),
      switchTheme: SwitchThemeData(
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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

  static TextTheme _buildTextTheme(TextTheme base, Color color) {
    TextStyle style(double size, double lineHeight, FontWeight weight) {
      return TextStyle(
        color: color,
        fontFamily: 'PingFang SC',
        fontSize: size,
        fontWeight: weight,
        height: lineHeight / size,
        letterSpacing: 0,
      );
    }

    return base.copyWith(
      bodySmall: style(12, 20, FontWeight.w400),
      bodyMedium: style(14, 22, FontWeight.w400),
      bodyLarge: style(16, 24, FontWeight.w400),
      labelSmall: style(10, 16, FontWeight.w600),
      labelMedium: style(12, 20, FontWeight.w600),
      labelLarge: style(14, 22, FontWeight.w600),
      titleSmall: style(14, 22, FontWeight.w600),
      titleMedium: style(16, 24, FontWeight.w600),
      titleLarge: style(18, 26, FontWeight.w600),
      headlineSmall: style(24, 32, FontWeight.w600),
      headlineMedium: style(28, 36, FontWeight.w600),
      headlineLarge: style(36, 44, FontWeight.w600),
      displayMedium: style(48, 56, FontWeight.w600),
      displayLarge: style(64, 72, FontWeight.w600),
    );
  }
}

extension TDesignBuildContext on BuildContext {
  TDesignTokens get tDesign => Theme.of(this).extension<TDesignTokens>()!;
}
