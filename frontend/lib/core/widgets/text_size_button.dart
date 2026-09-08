import 'package:flutter/material.dart';

import '../../generated/l10n/app_localizations.dart';
import '../constants/app_sizes.dart';
import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';
import '../voice/voice_service.dart';
import 'text_size_sheet.dart';

/// Top-level action button opening the [TextSizeSheet].
class TextSizeButton extends StatelessWidget {
  const TextSizeButton({
    super.key,
    this.onPhoto = false,
  });

  final bool onPhoto;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final Color bgColor;
    final Color iconColor;
    final Border? border;

    if (onPhoto) {
      bgColor = const Color(0x661E1A14);
      iconColor = AppColors.onPhoto;
      border = Border.all(
        color: Colors.white.withValues(alpha: 0.25),
        width: 1.5,
      );
    } else {
      bgColor = AppColors.surface;
      iconColor = AppColors.ink;
      border = Border.all(
        color: AppColors.surfaceVariant,
        width: 1.5,
      );
    }

    return Semantics(
      label: l10n.textSize,
      button: true,
      tooltip: l10n.textSize,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            VoiceService.instance.stop();
            TextSizeSheet.show(context);
          },
          borderRadius: BorderRadius.circular(AppSizes.radiusPill),
          child: Container(
            constraints: const BoxConstraints(
              minWidth: AppSizes.minTapTarget,
              minHeight: AppSizes.minTapTarget,
            ),
            padding: const EdgeInsets.all(AppSizes.paddingS),
            alignment: Alignment.center,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
                border: border,
                boxShadow: onPhoto ? null : AppShadows.soft,
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.format_size_rounded,
                size: 24,
                color: iconColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
