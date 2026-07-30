import 'package:flutter/material.dart';

// ── AquaLife colour palette ──────────────────────────────────────
const kBgDark = Color(0xFF0A1628); // deepest background
const kCardDark = Color(0xFF112240); // card / sheet surface
const kInputDark = Color(0xFF0D1F35); // input field fill
const kBorderDark = Color(0xFF1E3A5C); // dividers & borders
const kAccent = Color(0xFF00B4D8); // primary cyan
const kMidDark = Color(0xFF1A3A5C); // button background
const kSubDark = Color(0xFF7AB8CC); // secondary text
const kHintDark = Color(0xFF4A6B82); // hint / disabled text
const kDanger = Color(0xFFFF5C7A); // destructive actions

const kBgLight = Color(0xFFF6F8FB); // light background
const kCardLight = Color(0xFFFFFFFF); // light card / sheet surface
const kInputLight = Color(0xFFEFF1F5); // light input field fill
const kBorderLight = Color(0xFFDDE3EA); // light dividers & borders
const kMidLight = Color(0xFFE6F7FB); // light button background
const kSubLight = Color(0xFF5A7184); // light secondary text
const kHintLight = Color(0xFF9AA6B2); // light hint / disabled text

// Legacy aliases kept for existing dark-mode UI
const kBg = kBgDark;
const kCard = kCardDark;
const kInput = kInputDark;
const kBorder = kBorderDark;
const kMid = kMidDark;
const kSub = kSubDark;
const kHint = kHintDark;

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: kAccent,
      scaffoldBackgroundColor: kBgDark,
      colorScheme: const ColorScheme.dark(
        primary: kAccent,
        surface: kCardDark,
        onSurface: Colors.white,
        outline: kBorderDark,
        tertiary: kMidDark,
      ),
      fontFamily: 'OpenSans',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: kInputDark,
        selectedItemColor: kAccent,
        unselectedItemColor: kSubDark,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.white, fontSize: 16),
        bodyMedium: TextStyle(color: kSubDark, fontSize: 14),
        titleLarge: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: kInputDark,
        filled: true,
        hintStyle: const TextStyle(color: kHintDark),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kBorderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kBorderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kAccent),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: kAccent,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: kAccent,
      scaffoldBackgroundColor: kBgLight,
      colorScheme: const ColorScheme.light(
        primary: kAccent,
        surface: kCardLight,
        onSurface: Color(0xFF0F1724),
        outline: kBorderLight,
        tertiary: kMidLight,
      ),
      fontFamily: 'OpenSans',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF0F1724)),
        titleTextStyle: TextStyle(color: Color(0xFF0F1724), fontSize: 18, fontWeight: FontWeight.bold),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: kCardLight,
        selectedItemColor: kAccent,
        unselectedItemColor: kSubLight,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Color(0xFF0F1724), fontSize: 16),
        bodyMedium: TextStyle(color: kSubLight, fontSize: 14),
        titleLarge: TextStyle(
          color: Color(0xFF0F1724),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: TextStyle(
          color: Color(0xFF0F1724),
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: kInputLight,
        filled: true,
        hintStyle: const TextStyle(color: kHintLight),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kBorderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kBorderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kAccent),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: kAccent,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

