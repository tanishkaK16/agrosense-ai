import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../constants/app_sizes.dart';

/// Audio / TTS listen button.
///
/// Phase 0: visual only — tap is a no-op.
/// Phase N (TTS): replace the onPressed body with a TextToSpeech call
/// and pass [text] to be read aloud.
class ListenButton extends StatelessWidget {
  const ListenButton({
    super.key,
    this.onPhoto = false,
    // ignore: avoid_unused_constructor_parameters
    this.text,
  });

  /// When true, renders on a dark photo scrim — uses light icon colour.
  final bool onPhoto;

  /// Text to speak. Reserved for the TTS phase — unused in Phase 0.
  final String? text;

  @override
  Widget build(BuildContext context) {
    final color = onPhoto ? AppColors.onPhoto : AppColors.ink;

    return Semantics(
      label: 'Listen',
      button: true,
      child: InkWell(
        // Phase 0: no-op. Phase N: trigger TTS with [text].
        onTap: () {},
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
        child: Container(
          width: AppSizes.minTapTarget,
          height: AppSizes.minTapTarget,
          alignment: Alignment.center,
          child: Icon(
            Icons.volume_up_rounded,
            size: AppSizes.iconMedium,
            color: color,
          ),
        ),
      ),
    );
  }
}
