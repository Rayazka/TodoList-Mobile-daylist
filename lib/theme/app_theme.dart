import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const accent = Color(0xFF6477D7);
  static const muted = Color(0xFF858993);
  static const pale = Color(0xFFEDF0FC);

  /// Mendefinisikan visual bersama agar kedua halaman konsisten.
  static ThemeData light() => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: Colors.white,
    colorScheme: ColorScheme.fromSeed(
      seedColor: accent,
      primary: accent,
      surface: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
    ),
    inputDecorationTheme: const InputDecorationTheme(border: InputBorder.none),
    dividerTheme: const DividerThemeData(
      color: Color(0xFFECEEF2),
      thickness: 1,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: pale,
    ),
  );
}
