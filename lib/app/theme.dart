import 'package:flutter/material.dart';

ThemeData buildLightTheme() {
  const seedColor = Color(0xFFFF8A65);
  final colorScheme = ColorScheme.fromSeed(seedColor: seedColor);
  const warmBackground = Color(0xFFFFF7F2);

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: warmBackground,
    appBarTheme: AppBarTheme(
      centerTitle: false,
      backgroundColor: warmBackground,
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      indicatorColor: colorScheme.primaryContainer,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
    ),
  );
}
