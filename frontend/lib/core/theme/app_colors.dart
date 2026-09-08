import 'package:flutter/material.dart';

/// AgroSense colour tokens.
/// Warm, editorial farm palette — cream, wheat gold, deep forest green.
abstract final class AppColors {
  // ── Backgrounds ──────────────────────────────────────────────────────────
  /// Warm parchment — main app background
  static const Color background = Color(0xFFF4EFE4);

  /// Slightly lighter cream — card surfaces
  static const Color surface = Color(0xFFFFF9F0);

  /// Faint warm divider / skeleton shimmer base
  static const Color surfaceVariant = Color(0xFFEDE6D6);

  // ── Brand ────────────────────────────────────────────────────────────────
  /// Deep forest green — primary actions, active tab
  static const Color primary = Color(0xFF2F5D32);

  /// Soft sage — secondary accents, selected card ring
  static const Color primarySoft = Color(0xFF7A9B57);

  /// Muted sage for ring highlights on language cards
  static const Color sageRing = Color(0xFFA8C483);

  // ── Wheat / Gold ─────────────────────────────────────────────────────────
  /// Warm wheat gold — warning state, decorative accents
  static const Color wheat = Color(0xFFC4A35A);

  /// Lighter gold — card accent backgrounds
  static const Color goldSoft = Color(0xFFE7D3A1);

  // ── Text ─────────────────────────────────────────────────────────────────
  /// Near-black warm ink — main body text
  static const Color ink = Color(0xFF1E1A14);

  /// Warm mid-grey — captions, supporting lines
  static const Color muted = Color(0xFF6B6256);

  /// Light text on photo scrims
  static const Color onPhoto = Color(0xFFF8F3E8);

  // ── Health status ────────────────────────────────────────────────────────
  /// Healthy crop — deep crop green
  static const Color healthy = Color(0xFF2E6B35);

  /// Healthy container tint
  static const Color healthyContainer = Color(0xFFD4EDDA);

  /// Warning / watch — amber wheat
  static const Color warning = Color(0xFFC4A35A);

  /// Warning container tint
  static const Color warningContainer = Color(0xFFFFF3CD);

  /// Danger / act now — earth red
  static const Color danger = Color(0xFFC0392B);

  /// Danger container tint
  static const Color dangerContainer = Color(0xFFFCDEDE);

  // ── Photo overlay ────────────────────────────────────────────────────────
  /// Warm dark gradient used as scrim over photos for readable text
  static const List<Color> photoScrimGradient = [
    Color(0x00221C0E),
    Color(0xCC221C0E),
  ];

  /// Cream-to-transparent fade at top of photo (softens status bar area)
  static const List<Color> photoTopFade = [
    Color(0x99F4EFE4),
    Color(0x00F4EFE4),
  ];
}
