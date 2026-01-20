import 'package:flutter/material.dart';

class AppTheme {
  // Color palette inspired by rural India
  static const Color primaryGreen = Color(0xFF2E7D32);      // Crop green
  static const Color lightGreen = Color(0xFF66BB6A);        // Fresh leaves
  static const Color earthBrown = Color(0xFF5D4037);        // Soil
  static const Color sunYellow = Color(0xFFFFB300);         // Sunshine
  static const Color skyBlue = Color(0xFF1976D2);           // Clear sky
  static const Color warningOrange = Color(0xFFFF8F00);     // Caution
  static const Color dangerRed = Color(0xFFD32F2F);         // Alert
  
  // Stress level colors
  static const Color stressCalmGreen = Color(0xFF4CAF50);
  static const Color stressWorriedYellow = Color(0xFFFFEB3B);
  static const Color stressStressedOrange = Color(0xFFFF9800);
  static const Color stressDesperateRed = Color(0xFFF44336);
  
  // Neutral colors
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF212121);
  static const Color textMedium = Color(0xFF757575);
  static const Color textLight = Color(0xFFBDBDBD);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        brightness: Brightness.light,
      ),
      
      // Typography optimized for rural users
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textDark,
          fontFamily: 'Poppins',
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textDark,
          fontFamily: 'Poppins',
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textDark,
          fontFamily: 'Poppins',
        ),
        headlineLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textDark,
          fontFamily: 'Poppins',
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: textDark,
          fontFamily: 'Poppins',
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: textDark,
          fontFamily: 'Poppins',
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textDark,
          fontFamily: 'Poppins',
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textDark,
          fontFamily: 'Poppins',
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: textDark,
          fontFamily: 'Poppins',
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: textMedium,
          fontFamily: 'Poppins',
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: textMedium,
          fontFamily: 'Poppins',
        ),
      ),
      
      // Button themes for large touch targets
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          minimumSize: const Size(120, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryGreen,
          minimumSize: const Size(120, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: const BorderSide(color: primaryGreen, width: 2),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      
      // Card theme
      cardTheme: CardTheme(
        color: surfaceWhite,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(8),
      ),
      
      // App bar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          fontFamily: 'Poppins',
        ),
      ),
      
      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: textLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: textLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryGreen, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: const TextStyle(
          color: textMedium,
          fontSize: 16,
          fontFamily: 'Poppins',
        ),
      ),
      
      // Bottom navigation theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceWhite,
        selectedItemColor: primaryGreen,
        unselectedItemColor: textMedium,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  // Stress level color helper
  static Color getStressColor(int stressLevel) {
    switch (stressLevel) {
      case 0: return stressCalmGreen;
      case 1: return stressWorriedYellow;
      case 2: return stressStressedOrange;
      case 3: return stressDesperateRed;
      default: return stressCalmGreen;
    }
  }

  // Financial health color helper
  static Color getFinancialHealthColor(double healthScore) {
    if (healthScore > 0.8) return stressCalmGreen;
    if (healthScore > 0.6) return lightGreen;
    if (healthScore > 0.4) return stressWorriedYellow;
    if (healthScore > 0.2) return stressStressedOrange;
    return stressDesperateRed;
  }

  // Season color helper
  static Color getSeasonColor(String seasonType) {
    switch (seasonType.toLowerCase()) {
      case 'kharif':
        return primaryGreen; // Monsoon green
      case 'rabi':
        return sunYellow; // Winter harvest
      case 'zaid':
        return skyBlue; // Summer irrigation
      default:
        return primaryGreen;
    }
  }

  // Custom gradients
  static const LinearGradient stressGradient = LinearGradient(
    colors: [stressCalmGreen, stressDesperateRed],
    stops: [0.0, 1.0],
  );

  static const LinearGradient seasonGradient = LinearGradient(
    colors: [primaryGreen, lightGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient moneyGradient = LinearGradient(
    colors: [sunYellow, warningOrange],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}