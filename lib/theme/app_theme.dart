import 'package:flutter/material.dart';

/// Central theme definitions for the app. Every screen should read colors
/// from `Theme.of(context).colorScheme` / `Theme.of(context).extension<AppColors>()`
/// rather than hardcoding `Colors.white` / `Colors.black` / `Colors.grey[...]`,
/// so both light and dark mode render correctly everywhere.
class AppTheme {
  static const Color seed = Colors.blue;

  /// Extra semantic colors that don't map cleanly onto Material's
  /// ColorScheme slots but are used throughout the app (success/warning
  /// states, subtle card backgrounds, dividers, etc.)
  static ThemeData light = _build(Brightness.light);
  static ThemeData dark = _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      dividerColor: scheme.outlineVariant,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: scheme.onSurface),
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainer,
        elevation: isDark ? 0 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isDark
              ? BorderSide(color: scheme.outlineVariant, width: 1)
              : BorderSide.none,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        hintStyle: TextStyle(color: scheme.onSurfaceVariant),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: scheme.surface,
        selectedItemColor: scheme.primary,
        unselectedItemColor: scheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: scheme.onSurfaceVariant,
        textColor: scheme.onSurface,
      ),
      iconTheme: IconThemeData(color: scheme.onSurfaceVariant),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: TextStyle(color: scheme.onInverseSurface),
        behavior: SnackBarBehavior.floating,
      ),
      extensions: [
        AppColors(
          success: isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A),
          warning: isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706),
          danger: isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626),
          cardAlt: scheme.surfaceContainerHigh,
          shadow: isDark ? Colors.black.withValues(alpha: 0.4) : Colors.black.withValues(alpha: 0.08),
        ),
      ],
    );
  }
}

/// Semantic colors not covered by Material's ColorScheme (status colors,
/// a secondary card surface, and a theme-aware shadow color).
class AppColors extends ThemeExtension<AppColors> {
  final Color success;
  final Color warning;
  final Color danger;
  final Color cardAlt;
  final Color shadow;

  const AppColors({
    required this.success,
    required this.warning,
    required this.danger,
    required this.cardAlt,
    required this.shadow,
  });

  @override
  AppColors copyWith({
    Color? success,
    Color? warning,
    Color? danger,
    Color? cardAlt,
    Color? shadow,
  }) {
    return AppColors(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      cardAlt: cardAlt ?? this.cardAlt,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      cardAlt: Color.lerp(cardAlt, other.cardAlt, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
    );
  }
}

/// Shorthand so call sites can write `context.colors.danger` /
/// `context.scheme.surface` instead of the fully qualified Theme calls.
extension BuildContextThemeX on BuildContext {
  ColorScheme get scheme => Theme.of(this).colorScheme;
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}
