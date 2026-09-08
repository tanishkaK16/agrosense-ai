import 'package:flutter/material.dart';

/// Named elevation shadows — warm-tinted, not the harsh Material defaults.
abstract final class AppShadows {
  /// Barely-there lift — card resting state
  static final List<BoxShadow> soft = [
    BoxShadow(
      color: const Color(0xFF1E1A14).withValues(alpha: 0.06),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  /// Medium card lift — scrolling / interaction
  static final List<BoxShadow> medium = [
    BoxShadow(
      color: const Color(0xFF1E1A14).withValues(alpha: 0.10),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  /// Floating pill nav bar
  static final List<BoxShadow> nav = [
    BoxShadow(
      color: const Color(0xFF1E1A14).withValues(alpha: 0.14),
      blurRadius: 24,
      offset: const Offset(0, 6),
    ),
  ];

  /// Pressed / active card — closer to surface
  static final List<BoxShadow> pressed = [
    BoxShadow(
      color: const Color(0xFF1E1A14).withValues(alpha: 0.04),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];
}
