import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Builds the Material 3 [ThemeData] for AgroSense.
/// The palette is completely overridden — this should not look like default Material.
ThemeData buildAppTheme() {
  const colorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: AppColors.onPhoto,
    primaryContainer: AppColors.goldSoft,
    onPrimaryContainer: AppColors.ink,
    secondary: AppColors.primarySoft,
    onSecondary: AppColors.onPhoto,
    secondaryContainer: AppColors.surfaceVariant,
    onSecondaryContainer: AppColors.ink,
    tertiary: AppColors.wheat,
    onTertiary: AppColors.ink,
    tertiaryContainer: AppColors.goldSoft,
    onTertiaryContainer: AppColors.ink,
    error: AppColors.danger,
    onError: AppColors.onPhoto,
    errorContainer: AppColors.dangerContainer,
    onErrorContainer: AppColors.ink,
    surface: AppColors.surface,
    onSurface: AppColors.ink,
    surfaceContainerHighest: AppColors.surfaceVariant,
    onSurfaceVariant: AppColors.muted,
    outline: AppColors.surfaceVariant,
    outlineVariant: AppColors.surfaceVariant,
    shadow: AppColors.ink,
    scrim: AppColors.ink,
    inverseSurface: AppColors.ink,
    onInverseSurface: AppColors.surface,
    inversePrimary: AppColors.sageRing,
  );

  final baseTextTheme = GoogleFonts.outfitTextTheme();

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.background,

    // Override text theme with Outfit
    textTheme: baseTextTheme.copyWith(
      displayLarge: baseTextTheme.displayLarge?.copyWith(color: AppColors.ink),
      displayMedium: baseTextTheme.displayMedium?.copyWith(color: AppColors.ink),
      displaySmall: baseTextTheme.displaySmall?.copyWith(color: AppColors.ink),
      headlineLarge: baseTextTheme.headlineLarge?.copyWith(color: AppColors.ink),
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(color: AppColors.ink),
      headlineSmall: baseTextTheme.headlineSmall?.copyWith(color: AppColors.ink),
      titleLarge: baseTextTheme.titleLarge?.copyWith(color: AppColors.ink),
      titleMedium: baseTextTheme.titleMedium?.copyWith(color: AppColors.ink),
      titleSmall: baseTextTheme.titleSmall?.copyWith(color: AppColors.muted),
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(color: AppColors.ink),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(color: AppColors.ink),
      bodySmall: baseTextTheme.bodySmall?.copyWith(color: AppColors.muted),
      labelLarge: baseTextTheme.labelLarge?.copyWith(color: AppColors.ink),
      labelMedium: baseTextTheme.labelMedium?.copyWith(color: AppColors.muted),
      labelSmall: baseTextTheme.labelSmall?.copyWith(color: AppColors.muted),
    ),

    // AppBar — transparent by default, screens manage their own header
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      iconTheme: IconThemeData(color: AppColors.ink),
      actionsIconTheme: IconThemeData(color: AppColors.ink),
      titleTextStyle: TextStyle(
        fontFamily: 'Outfit',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      ),
    ),

    // Cards — use our custom BoxShadow, no Material elevation shadow
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      margin: EdgeInsets.zero,
    ),

    // Elevated button = primary pill
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPhoto,
        minimumSize: const Size(double.infinity, 56),
        shape: const StadiumBorder(),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        textStyle: const TextStyle(
          fontFamily: 'Outfit',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    ),

    // Outlined button
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        minimumSize: const Size(double.infinity, 56),
        shape: const StadiumBorder(),
        side: const BorderSide(color: AppColors.primarySoft, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      ),
    ),

    // No bottom nav — we use a custom floating pill
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),

    dividerTheme: const DividerThemeData(
      color: AppColors.surfaceVariant,
      thickness: 1,
    ),

    iconTheme: const IconThemeData(
      color: AppColors.ink,
      size: 24,
    ),
  );
}
