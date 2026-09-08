import 'package:flutter/material.dart';

import '../constants/app_sizes.dart';
import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';
import '../voice/voice_service.dart';

/// Audio / TTS listen button.
///
/// Reads the specified [text] aloud when tapped.
/// Toggles between speaking and stopping:
/// - If idle: starts reading aloud in the active locale.
/// - If speaking: stops speech immediately.
///
/// Meets the 64x64 minimum tap target for high accessibility.
class ListenButton extends StatelessWidget {
  const ListenButton({
    super.key,
    this.text,
    this.languageCode,
    this.onTap,
    this.onPhoto = false,
  });

  /// The text to read aloud.
  final String? text;

  /// Optional specific language code (e.g. 'en', 'hi', 'mr').
  /// If null, uses the active app locale.
  final String? languageCode;

  /// Custom tap handler if specified. Otherwise calls [VoiceService.toggle].
  final VoidCallback? onTap;

  /// When true, styled for placement over farm photos with high contrast.
  final bool onPhoto;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: VoiceService.instance,
      builder: (context, _) {
        final voiceService = VoiceService.instance;
        final isSpeakingThis = voiceService.isSpeaking &&
            (text != null && voiceService.lastSpokenText == text);
        final isSpeakingAny = voiceService.isSpeaking;

        final Color iconColor;
        final Color bgColor;
        final Border? border;

        if (onPhoto) {
          bgColor = isSpeakingThis
              ? AppColors.primary
              : const Color(0x661E1A14);
          iconColor = AppColors.onPhoto;
          border = Border.all(
            color: isSpeakingThis
                ? AppColors.sageRing
                : Colors.white.withValues(alpha: 0.25),
            width: 1.5,
          );
        } else {
          bgColor = isSpeakingThis
              ? AppColors.primary
              : AppColors.surface;
          iconColor = isSpeakingThis
              ? AppColors.surface
              : AppColors.primary;
          border = Border.all(
            color: isSpeakingThis
                ? AppColors.primary
                : AppColors.surfaceVariant,
            width: 1.5,
          );
        }

        return Semantics(
          label: 'Listen',
          button: true,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                if (onTap != null) {
                  onTap!();
                } else if (text != null && text!.trim().isNotEmpty) {
                  voiceService.toggle(
                    text: text!,
                    languageCode: languageCode,
                  );
                } else if (isSpeakingAny) {
                  voiceService.stop();
                }
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
                  boxShadow: isSpeakingThis ? AppShadows.medium : AppShadows.soft,
                ),
                child: Icon(
                  isSpeakingThis ? Icons.stop_rounded : Icons.volume_up_rounded,
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
