import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF1A365D);
  static const Color primaryLight = Color(0xFF2B4C7E);
  static const Color primaryDark = Color(0xFF0F2442);

  static const Color secondary = Color(0xFFB7791F);
  static const Color secondaryLight = Color(0xFFD69E2E);
  static const Color secondaryDark = Color(0xFF975A16);

  static const Color success = Color(0xFF38A169);
  static const Color successLight = Color(0xFF48BB78);
  static const Color successDark = Color(0xFF2F855A);

  static const Color warning = Color(0xFFDD6B20);
  static const Color warningLight = Color(0xFFED8936);
  static const Color warningDark = Color(0xFFC05621);

  static const Color error = Color(0xFFE53E3E);
  static const Color errorLight = Color(0xFFFC8181);
  static const Color errorDark = Color(0xFFC53030);

  static const Color info = Color(0xFF3182CE);
  static const Color infoLight = Color(0xFF63B3ED);
  static const Color infoDark = Color(0xFF2B6CB0);

  static const Color background = Color(0xFFF7FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);

  static const Color textPrimary = Color(0xFF2D3748);
  static const Color textSecondary = Color(0xFF4A5568);
  static const Color textTertiary = Color(0xFF718096);
  static const Color textHint = Color(0xFFA0AEC0);

  static const Color divider = Color(0xFFE2E8F0);
  static const Color border = Color(0xFFCBD5E0);

  static const Color shimmerBase = Color(0xFFE2E8F0);
  static const Color shimmerHighlight = Color(0xFFF7FAFC);

  static const Color overlay = Color(0x80000000);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [success, successLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ColorScheme toColorScheme(Brightness brightness) {
    return ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: Colors.white,
      primaryContainer: primaryLight,
      onPrimaryContainer: Colors.white,
      secondary: secondary,
      onSecondary: Colors.white,
      secondaryContainer: secondaryLight,
      onSecondaryContainer: Colors.white,
      tertiary: info,
      onTertiary: Colors.white,
      tertiaryContainer: infoLight,
      onTertiaryContainer: textPrimary,
      error: error,
      onError: Colors.white,
      errorContainer: errorLight,
      onErrorContainer: errorDark,
      surface: surface,
      onSurface: textPrimary,
      surfaceContainerHighest: surfaceVariant,
      onSurfaceVariant: textSecondary,
      outline: border,
      outlineVariant: divider,
    );
  }
}
