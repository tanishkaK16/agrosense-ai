import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Small circular badge showing the locale abbreviation (EN / हि / मर).
///
/// Used on the language selection screen and in the app bar to indicate
/// the active language without using flag emojis.
class LanguageMark extends StatelessWidget {
  const LanguageMark({
    super.key,
    required this.code,
    this.size = 36.0,
  });

  /// Two-character abbreviation: 'EN', 'हि', 'मर'
  final String code;

  /// Diameter of the circle
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        code,
        style: AppTextStyles.languageMark(context).copyWith(
          fontSize: size * 0.3,
        ),
        textScaler: TextScaler.noScaling,
      ),
    );
  }
}
