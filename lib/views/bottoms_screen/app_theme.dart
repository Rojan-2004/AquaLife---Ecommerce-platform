import 'package:flutter/material.dart';

const Color kBg = Color(0xFF0A1628);
const Color kCard = Color(0xFF112240);
const Color kMid = Color(0xFF1A3A5C);
const Color kInput = Color(0xFF0D1F35);
const Color kBorder = Color(0xFF1E3A5C);
const Color kAccent = Color(0xFF00B4D8);
const Color kSub = Color(0xFF7AB8CC);
const Color kHint = Color(0xFF4A6B82);

class AppTheme {
  static final lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: kBg,
    colorScheme: const ColorScheme.dark(
      primary: kAccent,
      surface: kCard,
    ),
  );
}
