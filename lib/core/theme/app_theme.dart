import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Material 3 Theme configuration for the application
class AppTheme {
  // Base seed color for generating dynamic Material 3 color schemes
  static const Color primaryColor = Color(0xFF6750A4);

  // Additional utility colors
  static const Color successColor = Color(0xFF146C2E);
  static const Color warningColor = Color(0xFFFFA113);
  static const Color errorColor = Color(0xFFBA1A1A);

  // Legacy colors for backwards compatibility
  static const Color accentColor = Color(0xFF7C4DFF);
  static const Color surfaceColor = Color(0xFFFFFBFF);
  static const Color textPrimaryColor = Color(0xFF1D1B20);
  static const Color textSecondaryColor = Color(0xFF49454F);

  // Gradient container decoration
  static BoxDecoration gradientContainer = const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [primaryColor, Color(0xFF8B6BC7)],
    ),
    borderRadius: BorderRadius.all(Radius.circular(16)),
  );

  // Light Theme
  static ThemeData get lightTheme {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
    );

    return _buildTheme(colorScheme);
  }

  // Dark Theme
  static ThemeData get darkTheme {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
    );

    return _buildTheme(colorScheme);
  }

  // Build theme based on provided color scheme
  static ThemeData _buildTheme(ColorScheme colorScheme) {
    final isDark = colorScheme.brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: colorScheme.brightness,

      // Text Theme with Google Fonts
      textTheme: GoogleFonts.nunitoSansTextTheme(
        TextTheme(
          displayLarge: TextStyle(color: colorScheme.onSurface),
          displayMedium: TextStyle(color: colorScheme.onSurface),
          displaySmall: TextStyle(color: colorScheme.onSurface),
          headlineLarge: TextStyle(color: colorScheme.onSurface),
          headlineMedium: TextStyle(color: colorScheme.onSurface),
          headlineSmall: TextStyle(color: colorScheme.onSurface),
          titleLarge: TextStyle(color: colorScheme.onSurface),
          titleMedium: TextStyle(color: colorScheme.onSurface),
          titleSmall: TextStyle(color: colorScheme.onSurface),
          bodyLarge: TextStyle(color: colorScheme.onSurface),
          bodyMedium: TextStyle(color: colorScheme.onSurfaceVariant),
          bodySmall: TextStyle(color: colorScheme.onSurfaceVariant),
          labelLarge: TextStyle(color: colorScheme.onSurface),
          labelMedium: TextStyle(color: colorScheme.onSurface),
          labelSmall: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
      ),

      // Card Theme
      cardTheme: CardTheme(
        elevation: isDark ? 1 : 0.5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
      ),

      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
      ),

      // FloatingActionButton Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        elevation: 3,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 1,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      // SnackBar Theme
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        contentTextStyle: TextStyle(
          color: isDark ? colorScheme.onInverseSurface : colorScheme.onPrimary,
          fontSize: 14,
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        backgroundColor: colorScheme.surface,
        elevation: 2,
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest,
        selectedColor: colorScheme.primaryContainer,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
