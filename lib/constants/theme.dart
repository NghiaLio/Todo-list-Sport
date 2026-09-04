import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color primaryColor = Color(0xFF00B2FF);
  static const Color secondaryColor = Color(0xFF03DAC6);
  static const Color backgroundColor = Color(0xFFFAFAFA);
  static const Color errorColor = Color(0xFFB00020);
  static const Color whiteColor = Color(0xFFFFFFFF);
  static const Color blackColor = Color(0xFF000000);
  static const Color transparentColor = Color(0x00000000);
  static const Color greyColor = Color(0xFF9E9E9E);
  static const Color grey100Color = Color(0xFFF5F5F5);
  static const Color grey300Color = Color(0xFFE0E0E0);
  static const Color grey400Color = Color(0xFFBDBDBD);
  static const Color grey600Color = Color(0xFF757575);
  static const Color grey700Color = Color(0xFF616161);
  static const Color black87Color = Color(0xDD000000);
  static const Color black54Color = Color(0x8A000000);
  static const Color white20Color = Color(0x33FFFFFF);
  static const Color white30Color = Color(0x4DFFFFFF);
  static const Color white50Color = Color(0x80FFFFFF);
  static const Color black10Color = Color(0x1A000000);
  static const Color primary30Color = Color.fromARGB(77, 4, 62, 87);
  static const Color cardBorderColor = Color(0xFFF7C1F8);
  static const Color placeholderDarkColor = Color(0xFF1E2124);
  static const Color dividerSoftColor = Color(0xFFEEEEEE);
  static const Color statisticalCompletedColor = Color(0xFF09B300);
  static const Color statisticalNotStartedColor = Color(0xFFFF1F1F);

  // Theme Data
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
      // Typography with Fredoka One as primary font
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'FredokaOne',
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: blackColor,
        ),
        displayMedium: TextStyle(
          fontFamily: 'FredokaOne',
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: blackColor,
        ),
        displaySmall: TextStyle(
          fontFamily: 'FredokaOne',
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: blackColor,
        ),
        headlineLarge: TextStyle(
          fontFamily: 'FredokaOne',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: blackColor,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'FredokaOne',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: blackColor,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'FredokaOne',
          fontSize: 16,
          color: blackColor,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'FredokaOne',
          fontSize: 14,
          color: blackColor,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: whiteColor,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: 'FredokaOne',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: whiteColor,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: whiteColor,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: const TextStyle(
            fontFamily: 'FredokaOne',
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: const TextStyle(
            fontFamily: 'FredokaOne',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          side: const BorderSide(color: primaryColor, width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
