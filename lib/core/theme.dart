import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ═══════════════════════════════════════════════════════════════════════════
  // PREMIUM DARK THEME COLOR PALETTE
  // ═══════════════════════════════════════════════════════════════════════════
  
  // Primary Brand Colors
  static const Color primaryColor = Color(0xFF00BFA5);      // Vibrant Teal
  static const Color primaryLight = Color(0xFF5DF2D6);      // Light Teal
  static const Color primaryDark = Color(0xFF00897B);       // Deep Teal
  
  // Accent Colors
  static const Color accentGold = Color(0xFFFFD54F);        // Premium Gold
  static const Color accentPurple = Color(0xFF7C4DFF);      // Electric Purple
  static const Color accentPink = Color(0xFFFF4081);        // Vibrant Pink
  
  // Dark Theme Backgrounds
  static const Color backgroundDark = Color(0xFF0F0F23);    // Deep Navy
  static const Color backgroundCard = Color(0xFF1A1A2E);    // Card Background
  static const Color backgroundElevated = Color(0xFF16213E); // Elevated Surface
  static const Color surfaceGlass = Color(0xFF1E2746);      // Glassmorphism Base
  
  // Text Colors
  static const Color textPrimary = Color(0xFFF8FAFC);       // Pure White
  static const Color textSecondary = Color(0xFF94A3B8);     // Muted Gray
  static const Color textMuted = Color(0xFF64748B);         // Very Muted
  
  // Status Colors
  static const Color successColor = Color(0xFF22C55E);      // Green
  static const Color warningColor = Color(0xFFFBBF24);      // Yellow
  static const Color errorColor = Color(0xFFEF4444);        // Red
  static const Color infoColor = Color(0xFF3B82F6);         // Blue

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, Color(0xFF00E5CC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFD54F), Color(0xFFFFB300)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient darkGradient = LinearGradient(
    colors: [backgroundDark, backgroundCard],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient glassGradient = LinearGradient(
    colors: [
      Color(0x33FFFFFF),
      Color(0x0DFFFFFF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // GLASSMORPHISM DECORATION
  // ═══════════════════════════════════════════════════════════════════════════
  
  static BoxDecoration glassDecoration({
    double borderRadius = 20,
    Color? borderColor,
  }) {
    return BoxDecoration(
      gradient: glassGradient,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor ?? Colors.white.withOpacity(0.1),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  static BoxDecoration cardDecoration({
    double borderRadius = 16,
    bool elevated = false,
  }) {
    return BoxDecoration(
      color: elevated ? backgroundElevated : backgroundCard,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: Colors.white.withOpacity(0.05),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: elevated ? 20 : 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // THEME DATA
  // ═══════════════════════════════════════════════════════════════════════════
  
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    
    // Color Scheme
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      onPrimary: Colors.black,
      primaryContainer: primaryDark,
      secondary: accentGold,
      onSecondary: Colors.black,
      surface: backgroundCard,
      onSurface: textPrimary,
      error: errorColor,
      onError: Colors.white,
    ),

    scaffoldBackgroundColor: backgroundDark,
    
    // Typography
    textTheme: GoogleFonts.outfitTextTheme(
      const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          letterSpacing: -1,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: textSecondary,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: textMuted,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: 0.5,
        ),
      ),
    ),

    // AppBar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: backgroundDark,
      foregroundColor: textPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: -0.5,
      ),
      iconTheme: const IconThemeData(color: textPrimary),
    ),

    // Bottom Navigation Bar
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: backgroundCard,
      selectedItemColor: primaryColor,
      unselectedItemColor: textMuted,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    ),

    // Drawer Theme
    drawerTheme: const DrawerThemeData(
      backgroundColor: backgroundDark,
    ),

    // Button Themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.black,
        disabledBackgroundColor: primaryColor.withOpacity(0.3),
        disabledForegroundColor: Colors.black.withOpacity(0.5),
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 28),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor, width: 1.5),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 28),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        textStyle: GoogleFonts.outfit(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    ),

    // Floating Action Button
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.black,
      elevation: 6,
      shape: CircleBorder(),
    ),

    // Input Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: backgroundCard,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      hintStyle: GoogleFonts.outfit(
        color: textMuted,
        fontWeight: FontWeight.normal,
      ),
      labelStyle: GoogleFonts.outfit(
        color: textSecondary,
        fontWeight: FontWeight.w500,
      ),
      floatingLabelStyle: GoogleFonts.outfit(
        color: primaryColor,
        fontWeight: FontWeight.w600,
      ),
      prefixIconColor: textMuted,
      suffixIconColor: textMuted,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: errorColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: errorColor, width: 2),
      ),
    ),

    // Card Theme
    cardTheme: CardThemeData(
      color: backgroundCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withOpacity(0.05)),
      ),
      margin: const EdgeInsets.only(bottom: 12),
    ),

    // Dialog Theme
    dialogTheme: DialogThemeData(
      backgroundColor: backgroundCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      titleTextStyle: GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
    ),

    // Bottom Sheet Theme
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: backgroundCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),

    // Snackbar Theme
    snackBarTheme: SnackBarThemeData(
      backgroundColor: backgroundElevated,
      contentTextStyle: GoogleFonts.outfit(
        color: textPrimary,
        fontSize: 14,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      behavior: SnackBarBehavior.floating,
    ),

    // Divider Theme
    dividerTheme: DividerThemeData(
      color: Colors.white.withOpacity(0.1),
      thickness: 1,
    ),
    
    // Icon Theme
    iconTheme: const IconThemeData(
      color: textSecondary,
      size: 24,
    ),

    // List Tile Theme
    listTileTheme: ListTileThemeData(
      iconColor: textSecondary,
      textColor: textPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),

    // Switch Theme
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryColor;
        }
        return textMuted;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryColor.withOpacity(0.3);
        }
        return Colors.white.withOpacity(0.1);
      }),
    ),

    // Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: backgroundCard,
      selectedColor: primaryColor.withOpacity(0.2),
      labelStyle: GoogleFonts.outfit(
        color: textPrimary,
        fontSize: 13,
      ),
      side: BorderSide(color: Colors.white.withOpacity(0.1)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),

    // Tab Bar Theme
    tabBarTheme: TabBarThemeData(
      labelColor: primaryColor,
      unselectedLabelColor: textMuted,
      indicator: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: primaryColor, width: 2),
        ),
      ),
      labelStyle: GoogleFonts.outfit(
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
      unselectedLabelStyle: GoogleFonts.outfit(
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
    ),
  );

  // Keep lightTheme for backward compatibility but redirect to dark
  static ThemeData get lightTheme => darkTheme;
}
