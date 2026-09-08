/// Shared spacing and sizing constants.
/// All tap targets meet the 64 × 64 minimum for low-literacy farmer UX.
abstract final class AppSizes {
  // ── Radii ─────────────────────────────────────────────────────────────────
  static const double radiusSmall = 12.0;
  static const double radiusMedium = 20.0;
  static const double radiusLarge = 28.0;
  static const double radiusPill = 100.0; // fully rounded

  // ── Padding ───────────────────────────────────────────────────────────────
  static const double paddingXS = 8.0;
  static const double paddingS = 12.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;
  static const double paddingXXL = 48.0;

  // ── Tap targets ───────────────────────────────────────────────────────────
  /// Minimum tap target for any interactive element (farmer UX rule)
  static const double minTapTarget = 64.0;

  /// Language card minimum height
  static const double languageCardHeight = 80.0;

  // ── Nav bar ───────────────────────────────────────────────────────────────
  static const double navBarHeight = 64.0;
  static const double navBarHorizontalPadding = 8.0;
  static const double navBarBottomMargin = 20.0;
  static const double navBarSidePadding = 24.0;

  // ── Icons ─────────────────────────────────────────────────────────────────
  static const double iconSmall = 20.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;

  // ── Photo / Hero ──────────────────────────────────────────────────────────
  static const double heroHeightRatio = 0.52; // fraction of screen height
  static const double homePhotoStripHeight = 180.0;

  // ── Cards ─────────────────────────────────────────────────────────────────
  static const double cardElevation = 0.0; // we use custom BoxShadow only
}
