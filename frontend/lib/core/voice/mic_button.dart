import 'package:flutter/material.dart';

import '../../generated/l10n/app_localizations.dart';
import '../constants/app_sizes.dart';
import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';
import 'voice_overlay.dart';
import 'voice_service.dart';

/// Large themed microphone button for farmer speech-in interaction (Phase 7).
///
/// Features:
/// - Generous 64x64 tap target for one-thumb ease
/// - Matches [ListenButton] visual tokens (regular vs onPhoto)
/// - Ignores accidental double-taps while an active listening session is open
/// - Launches [VoiceOverlay.startListeningFlow]
class MicButton extends StatelessWidget {
  const MicButton({
    super.key,
    this.currentListenText,
    this.onPhoto = false,
  });

  /// Optional text summary of the current screen to speak if the farmer says "Listen".
  final String? currentListenText;

  /// High-contrast theme adaptation for placement directly over photo scrims.
  final bool onPhoto;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tooltip = l10n?.voiceMicTooltip ?? 'Voice command';

    return ListenableBuilder(
      listenable: VoiceService.instance,
      builder: (context, _) {
        final isListening = VoiceService.instance.isListening;

        final Color iconColor;
        final Color bgColor;
        final Border? border;

        if (onPhoto) {
          bgColor = isListening
              ? AppColors.primary
              : const Color(0x661E1A14);
          iconColor = AppColors.onPhoto;
          border = Border.all(
            color: isListening
                ? AppColors.sageRing
                : Colors.white.withValues(alpha: 0.25),
            width: 1.5,
          );
        } else {
          bgColor = isListening
              ? AppColors.primary
              : AppColors.surface;
          iconColor = isListening
              ? AppColors.surface
              : AppColors.primary;
          border = Border.all(
            color: isListening
                ? AppColors.primary
                : AppColors.surfaceVariant,
            width: 1.5,
          );
        }

        return Semantics(
          label: tooltip,
          button: true,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                if (isListening) return;
                VoiceOverlay.startListeningFlow(
                  context,
                  currentListenText: currentListenText,
                );
              },
              borderRadius: BorderRadius.circular(AppSizes.radiusPill),
              child: Container(
                width: AppSizes.minTapTarget,
                height: AppSizes.minTapTarget,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                  border: border,
                  boxShadow: isListening ? AppShadows.medium : AppShadows.soft,
                ),
                child: Icon(
                  Icons.mic_rounded,
                  size: AppSizes.iconMedium,
                  color: iconColor,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
