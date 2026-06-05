import 'package:flutter/material.dart';
import 'app_colors.dart';

// ── AquaLife colour palette ──────────────────────────────────────
const kBg = Color(0xFF0A1628); // deepest background
const kCard = Color(0xFF112240); // card / sheet surface
const kInput = Color(0xFF0D1F35); // input field fill
const kBorder = Color(0xFF1E3A5C); // dividers & borders
const kAccent = Color(0xFF00B4D8); // primary cyan
const kMid = Color(0xFF1A3A5C); // button background
const kSub = Color(0xFF7AB8CC); // secondary text
const kHint = Color(0xFF4A6B82);   // hint / disabled text

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: AppColors.primaryBlue,
      scaffoldBackgroundColor: kBg, // Deep dark background
      fontFamily: 'OpenSans', // OpenSans font as configured in pubspec
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: kCard,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.iconGrey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.white, fontSize: 16),
        bodyMedium: TextStyle(color: kSub, fontSize: 14),
        titleLarge: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
