import 'package:flutter/material.dart';

class AppColors {
  static const bg = Color(0xFF0A0F1E);
  static const surface = Color(0xFF111827);
  static const surface2 = Color(0xFF1A2236);
  static const teal = Color(0xFF0EE6C0);
  static const tealDim = Color(0x1F0EE6C0);
  static const blue = Color(0xFF3B82F6);
  static const blueDim = Color(0x1F3B82F6);
  static const amber = Color(0xFFF59E0B);
  static const red = Color(0xFFEF4444);
  static const redDim = Color(0x1FEF4444);
  static const green = Color(0xFF22C55E);
  static const greenDim = Color(0x1F22C55E);
  static const text = Color(0xFFF1F5F9);
  static const textMuted = Color(0xFF64748B);
  static const textDim = Color(0xFF94A3B8);
  static const border = Color(0x12FFFFFF);
}

final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: AppColors.bg,
  colorScheme: const ColorScheme.dark(
    primary: AppColors.teal,
    onPrimary: AppColors.bg,
    secondary: AppColors.blue,
    surface: AppColors.surface,
    error: AppColors.red,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.bg,
    foregroundColor: AppColors.text,
    elevation: 0,
    centerTitle: false,
  ),
  cardTheme: CardThemeData(
    color: AppColors.surface,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: AppColors.border),
    ),
    margin: const EdgeInsets.symmetric(vertical: 4),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surface2,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.teal, width: 1.5),
    ),
    labelStyle: const TextStyle(color: AppColors.textMuted),
    hintStyle: const TextStyle(color: AppColors.textMuted),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.teal,
      foregroundColor: AppColors.bg,
      minimumSize: const Size(double.infinity, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.textDim,
      side: const BorderSide(color: AppColors.border),
      minimumSize: const Size(double.infinity, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.teal,
    ),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: AppColors.surface,
    selectedItemColor: AppColors.teal,
    unselectedItemColor: AppColors.textMuted,
    type: BottomNavigationBarType.fixed,
    elevation: 0,
  ),
  dividerTheme: const DividerThemeData(
    color: AppColors.border,
    thickness: 1,
  ),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: AppColors.surface2,
    contentTextStyle: const TextStyle(color: AppColors.text),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    behavior: SnackBarBehavior.floating,
  ),
);
