import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Full-bleed farm photo header with:
///   - An [Image.asset] as background
///   - A bottom-to-top warm dark scrim for text legibility
///   - Optional top cream fade so the status bar area feels soft
///
/// [height] defaults to 52 % of screen height.
class FarmPhotoHeader extends StatelessWidget {
  const FarmPhotoHeader({
    super.key,
    required this.imagePath,
    this.height,
    this.child,
    this.showTopFade = true,
  });

  final String imagePath;

  /// Explicit height. If null, uses 52 % of [MediaQuery] screen height.
  final double? height;

  /// Content rendered on top of the scrim (text, buttons, etc.).
  final Widget? child;

  /// Whether to render the cream-to-transparent fade at the top edge
  /// that softens the status bar area.
  final bool showTopFade;

  @override
  Widget build(BuildContext context) {
    final resolvedHeight =
        height ?? MediaQuery.sizeOf(context).height * 0.52;

    return SizedBox(
      height: resolvedHeight,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background photo (decorative, excluded from screen reader noise)
          ExcludeSemantics(
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const ColoredBox(
                color: AppColors.goldSoft,
              ),
            ),
          ),

          // Bottom scrim — makes text readable
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: resolvedHeight * 0.65,
            child: const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: AppColors.photoScrimGradient,
                ),
              ),
            ),
          ),

          // Top cream fade — softens status bar integration
          if (showTopFade)
            const Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: 120,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: AppColors.photoTopFade,
                  ),
                ),
              ),
            ),

          // Foreground content
          if (child != null) child!,
        ],
      ),
    );
  }
}
