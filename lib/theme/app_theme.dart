import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const seed = Color(0xFF2F6B5E); // calm green-teal
  static const sand = Color(0xFFF7F3EC);
}

class AppTheme {
  static TextStyle arabicDhikrStyle(BuildContext context, {double scale = 1.0}) {
    return GoogleFonts.amiri(
      fontSize: 26 * scale,
      height: 1.9,
      fontWeight: FontWeight.w500,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  static ThemeData light() {
    final base = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.seed, brightness: Brightness.light),
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.sand,
    );
    return base.copyWith(
      textTheme: GoogleFonts.tajawalTextTheme(base.textTheme),
      appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
    );
  }

  static ThemeData dark() {
    final base = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.seed, brightness: Brightness.dark),
      useMaterial3: true,
    );
    return base.copyWith(
      textTheme: GoogleFonts.tajawalTextTheme(base.textTheme),
      appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
    );
  }
}
