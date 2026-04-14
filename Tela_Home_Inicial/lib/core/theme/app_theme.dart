import 'package:flutter/material.dart';

// Definindo as cores em uma classe dedicada no mesmo arquivo para evitar erros de import
class AppColors {
  static const Color primary = Color(0xFFD32F2F); // Vermelho Barbú
  static const Color background = Color(0xFF0A0A0A);
  static const Color cardBackground = Color(0xFF1A1A1A);
  static const Color navBarBackground = Color(0xFF121212);
  
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.white54;
  static const Color divider = Colors.white12;
}

class AppTheme {
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,

    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.primary,
      surface: AppColors.cardBackground,
    ),

    inputDecorationTheme: InputDecorationTheme(
      floatingLabelStyle: const TextStyle(color: AppColors.primary),
      iconColor: AppColors.primary,
      prefixIconColor: AppColors.primary,
      
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.divider),
        borderRadius: BorderRadius.circular(12),
      ),
    ),

    iconTheme: const IconThemeData(color: AppColors.primary),
    
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
      bodyMedium: TextStyle(color: AppColors.textSecondary),
    ),
  );
}