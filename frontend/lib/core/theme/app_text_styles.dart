import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// AgroSense text styles.
///
/// Headline uses Fraunces (serif editorial) for impact.
/// Body / UI uses Outfit (geometric humanist sans-serif) for readability.
/// Devanagari script text falls back to Noto Sans Devanagari via
/// [AppTextStyles.devanagari] or the system font stack.
abstract final class AppTextStyles {
  // ── Editorial serif headlines ─────────────────────────────────────────────

  /// Hero welcome line — very large, warm ink
  static TextStyle heroHeadline(BuildContext context) =>
      GoogleFonts.fraunces(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
        height: 1.15,
        letterSpacing: -0.5,
      );

  /// Section / screen title
  static TextStyle screenTitle(BuildContext context) =>
      GoogleFonts.fraunces(
        fontSize: 26,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
        height: 1.2,
      );

  // ── Sans-serif body / UI ──────────────────────────────────────────────────

  /// Large card label or tab heading
  static TextStyle labelLarge(BuildContext context) =>
      GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
        height: 1.3,
      );

  /// Standard body text
  static TextStyle body(BuildContext context) =>
      GoogleFonts.outfit(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.ink,
        height: 1.5,
      );

  /// Supporting / caption text — muted
  static TextStyle caption(BuildContext context) =>
      GoogleFonts.outfit(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.muted,
        height: 1.4,
      );

  /// Button label
  static TextStyle button(BuildContext context) =>
      GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.surface,
        letterSpacing: 0.2,
        height: 1.0,
      );

  /// Language mark badge — small circular abbreviation (EN / हि / मर)
  static TextStyle languageMark(BuildContext context) =>
      GoogleFonts.outfit(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.surface,
        letterSpacing: 0.5,
      );

  /// Devanagari script (hi / mr) — uses Noto Sans Devanagari
  static TextStyle devanagari({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w400,
    Color color = AppColors.ink,
  }) =>
      GoogleFonts.notoSansDevanagari(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: 1.4,
      );

  /// Text on top of a photo with the dark scrim
  static TextStyle onPhoto(BuildContext context) =>
      GoogleFonts.fraunces(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: AppColors.onPhoto,
        height: 1.15,
      );

  /// Supporting text on photo scrim
  static TextStyle onPhotoSub(BuildContext context) =>
      GoogleFonts.outfit(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.onPhoto.withValues(alpha: 0.85),
        height: 1.5,
      );
}
