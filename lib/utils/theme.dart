import 'package:flutter/material.dart';

/// Central theme so white-labelling (Phase 2 commercial licensing) is a
/// matter of swapping these seed values per organisation rather than
/// hunting colors through the widget tree.
class AppTheme {
  static const Color primary = Color(0xFF1B4B6B); // deep alpine blue
  static const Color accent = Color(0xFFE8622C); // hi-vis orange, ski-jacket energy
  static const Color success = Color(0xFF2E8B57);
  static const Color warning = Color(0xFFE0A800);
  static const Color danger = Color(0xFFD64545);

  static ThemeData light({Color? primaryOverride, Color? accentOverride}) {
    final primaryColor = primaryOverride ?? primary;
    final accentColor = accentOverride ?? accent;
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: accentColor,
        brightness: Brightness.light,
      ),
    );
    return base.copyWith(
      scaffoldBackgroundColor: const Color(0xFFF5F7F9),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

/// Colors for pace/status badges used across dashboards and reports.
class StatusColors {
  static Color forPaceStatus(String statusLabel) {
    switch (statusLabel) {
      case 'Ahead of pace':
      case '70 hours complete':
        return AppTheme.success;
      case 'On pace':
        return AppTheme.primary;
      case 'Behind pace':
        return AppTheme.danger;
      default:
        return Colors.grey;
    }
  }
}