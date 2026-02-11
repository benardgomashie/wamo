import 'package:flutter/material.dart';

class AppTheme {
  // Brand Colors (aligned with DESIGN_SYSTEM.md)
  static const Color primaryColor = Color(0xFF2FA4A9); // Wamo Teal - trust & calm
  static const Color secondaryColor = Color(0xFFF39C3D); // Wamo Orange - warmth & hope
  static const Color accentColor = Color(0xFF3CB371); // Soft green - success
  static const Color errorColor = Color(0xFFD9534F); // Muted red - errors only
  static const Color warningColor = Color(0xFFF2B705); // Amber - warnings
  static const Color successColor = Color(0xFF3CB371); // Soft green - success
  
  // Neutral Colors (aligned with DESIGN_SYSTEM.md)
  static const Color backgroundColor = Color(0xFFF7F9FB); // color.bg.secondary
  static const Color surfaceColor = Color(0xFFFFFFFF); // color.surface.card
  static const Color textPrimaryColor = Color(0xFF1F2933); // color.text.primary
  static const Color textSecondaryColor = Color(0xFF4B5563); // color.text.secondary
  static const Color textMutedColor = Color(0xFF9CA3AF); // color.text.muted
  static const Color dividerColor = Color(0xFFE5E7EB); // color.border.light
  static const Color disabledColor = Color(0xFFE9ECEF); // color.surface.disabled
  static const Color infoColor = Color(0xFF2FA4A9); // Same as primary for info states
  
  // Spacing Constants
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  
  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      error: errorColor,
      surface: surfaceColor,
    ),
    
    appBarTheme: const AppBarTheme(
      backgroundColor: surfaceColor,
      foregroundColor: textPrimaryColor,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: textPrimaryColor,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(48), // Accessibility: min 48px
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // radius.lg
        ),
        elevation: 0,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        minimumSize: const Size.fromHeight(48), // Accessibility: min 48px
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // radius.lg
        ),
        side: const BorderSide(color: primaryColor, width: 1.5),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8), // radius.sm
        borderSide: const BorderSide(color: dividerColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8), // radius.sm
        borderSide: const BorderSide(color: dividerColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8), // radius.sm
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8), // radius.sm
        borderSide: const BorderSide(color: errorColor),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: const TextStyle(color: textMutedColor),
    ),
    
    cardTheme: const CardThemeData(
      color: surfaceColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)), // radius.md
        side: BorderSide(color: dividerColor, width: 1),
      ),
      margin: EdgeInsets.symmetric(vertical: 8),
    ),
    
    chipTheme: ChipThemeData(
      backgroundColor: backgroundColor,
      selectedColor: primaryColor.withOpacity(0.1),
      labelStyle: const TextStyle(color: textPrimaryColor),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999), // radius.full (pills)
      ),
    ),
    
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primaryColor,
      linearTrackColor: dividerColor,
    ),
    
    dividerTheme: const DividerThemeData(
      color: dividerColor,
      thickness: 1,
      space: 1,
    ),
    
    // Typography aligned with DESIGN_SYSTEM.md type scale
    textTheme: const TextTheme(
      displaySmall: TextStyle( // Display: Screen headers
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 36 / 28, // Line height 36px
        color: textPrimaryColor,
      ),
      titleLarge: TextStyle( // Title: Section titles
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: 28 / 22, // Line height 28px
        color: textPrimaryColor,
      ),
      titleMedium: TextStyle( // Subtitle: Card titles, highlights
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 24 / 18, // Line height 24px
        color: textPrimaryColor,
      ),
      bodyLarge: TextStyle( // Body: Default text
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 24 / 16, // Line height 24px
        color: textPrimaryColor,
      ),
      bodyMedium: TextStyle( // Small: Secondary text, helper copy
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 20 / 14, // Line height 20px
        color: textSecondaryColor,
      ),
      labelSmall: TextStyle( // Caption: Labels, metadata, timestamps
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 16 / 12, // Line height 16px
        color: textMutedColor,
      ),
    ),
  );
  
  // Dark Theme (aligned with DESIGN_SYSTEM.md dark mode tokens)
  static const Color darkPrimaryColor = Color(0xFF3FBFC4); // Softened teal for dark
  static const Color darkSecondaryColor = Color(0xFFF6B15A); // Softened orange for dark
  static const Color darkSuccessColor = Color(0xFF4FD1A5);
  static const Color darkWarningColor = Color(0x00facc15);
  static const Color darkErrorColor = Color(0xFFF87171); // Muted error for dark
  static const Color darkBackgroundColor = Color(0xFF0F172A); // color.bg.primary.dark
  static const Color darkSurfaceColor = Color(0xFF1F2933); // color.surface.card.dark
  static const Color darkTextPrimaryColor = Color(0xFFF9FAFB); // color.text.primary.dark
  static const Color darkTextSecondaryColor = Color(0xFFD1D5DB); // color.text.secondary.dark
  static const Color darkTextMutedColor = Color(0xFF9CA3AF); // color.text.muted.dark
  static const Color darkDividerColor = Color(0xFF374151); // color.border.light.dark
  static const Color darkDisabledColor = Color(0xFF374151); // color.surface.disabled.dark

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: darkPrimaryColor,
    scaffoldBackgroundColor: darkBackgroundColor,
    
    colorScheme: const ColorScheme.dark(
      primary: darkPrimaryColor,
      secondary: darkSecondaryColor,
      error: darkErrorColor,
      surface: darkSurfaceColor,
    ),
    
    appBarTheme: const AppBarTheme(
      backgroundColor: darkSurfaceColor,
      foregroundColor: darkTextPrimaryColor,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: darkTextPrimaryColor,
        fontSize: 22,
        fontWeight: FontWeight.w700,
      ),
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: darkPrimaryColor,
        foregroundColor: darkBackgroundColor, // Inverted for contrast
        minimumSize: const Size.fromHeight(48),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
      ),
    ),
    
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: darkPrimaryColor,
        minimumSize: const Size.fromHeight(48),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        side: const BorderSide(color: darkPrimaryColor, width: 1.5),
      ),
    ),
    
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkSurfaceColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: darkDividerColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: darkDividerColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: darkPrimaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: darkErrorColor),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: const TextStyle(color: darkTextMutedColor),
    ),
    
    cardTheme: const CardThemeData(
      color: darkSurfaceColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        side: BorderSide(color: darkDividerColor, width: 1),
      ),
      margin: EdgeInsets.symmetric(vertical: 8),
    ),
    
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: darkPrimaryColor,
      linearTrackColor: darkDisabledColor,
    ),
    
    textTheme: const TextTheme(
      displaySmall: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 36 / 28,
        color: darkTextPrimaryColor,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: 28 / 22,
        color: darkTextPrimaryColor,
      ),
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 24 / 18,
        color: darkTextPrimaryColor,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
        color: darkTextPrimaryColor,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 20 / 14,
        color: darkTextSecondaryColor,
      ),
      labelSmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 16 / 12,
        color: darkTextMutedColor,
      ),
    ),
  );
  
  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;
  
  // Border Radius
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusRound = 999.0;
  
  // Elevation
  static const double elevationS = 2.0;
  static const double elevationM = 4.0;
  static const double elevationL = 8.0;
}
