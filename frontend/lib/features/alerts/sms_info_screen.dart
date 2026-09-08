import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/voice/voice_service.dart';
import '../../core/widgets/listen_button.dart';
import '../../core/widgets/primary_pill_button.dart';
import '../../generated/l10n/app_localizations.dart';
import '../auth/data/app_auth_repository.dart';
import '../auth/models/farmer_profile.dart';

/// Screen explaining SMS alerts and managing farmer SMS opt-in preference (Phase 9).
class SmsInfoScreen extends StatefulWidget {
  const SmsInfoScreen({super.key});

  @override
  State<SmsInfoScreen> createState() => _SmsInfoScreenState();
}

class _SmsInfoScreenState extends State<SmsInfoScreen> {
  late bool _smsOptIn;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final profile = AppAuthRepository.instance.currentProfile();
    _smsOptIn = profile?.smsOptIn ?? true;
  }

  @override
  void dispose() {
    VoiceService.instance.stop();
    super.dispose();
  }

  String _getMaskedPhone() {
    final session = AppAuthRepository.instance.currentSession();
    final raw = session?.phoneNumber.trim() ?? '';
    if (raw.length >= 4) {
      final suffix = raw.substring(raw.length - 4);
      return '+91 XXXXX $suffix';
    }
    return '+91 XXXXX 1234';
  }

  Future<void> _onSave() async {
    if (_isSaving) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isSaving = true);
    await VoiceService.instance.stop();
    if (!mounted) return;

    final currentProfile = AppAuthRepository.instance.currentProfile();

    final updated = (currentProfile != null)
        ? currentProfile.copyWith(smsOptIn: _smsOptIn)
        : FarmerProfile(
            name: 'Farmer',
            village: '',
            mainCrop: 'wheat',
            smsOptIn: _smsOptIn,
          );

    try {
      await AppAuthRepository.instance.saveProfile(updated);
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.smsSaveSuccess,
              style: const TextStyle(
                fontFamily: 'Outfit',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.onPhoto,
              ),
            ),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            ),
          ),
        );
        if (context.canPop()) {
          context.pop();
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.saveFailed,
              style: const TextStyle(
                fontFamily: 'Outfit',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.onPhoto,
              ),
            ),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
        VoiceService.instance.speak(l10n.saveFailed);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final maskedPhone = _getMaskedPhone();

    final speechText =
        '${l10n.smsScreenTitle}. ${l10n.smsSentence1}. ${l10n.smsSentence2(maskedPhone)}. ${_smsOptIn ? l10n.smsStatusOn : l10n.smsStatusOff}';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Bar with Back and Listen buttons ────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingL,
                vertical: AppSizes.paddingM,
              ),
              child: Row(
                children: [
                  Semantics(
                    label: 'Back',
                    button: true,
                    child: InkWell(
                      onTap: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/alerts');
                        }
                      },
                      borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          shape: BoxShape.circle,
                          boxShadow: AppShadows.soft,
                        ),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: AppColors.ink,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingM),
                  Expanded(
                    child: Text(
                      l10n.smsScreenTitle,
                      style: AppTextStyles.screenTitle(context).copyWith(
                        fontSize: 22,
                      ),
                    ),
                  ),
                  ListenButton(
                    onPhoto: false,
                    text: speechText,
                  ),
                ],
              ),
            ),

            // ── Body Content ────────────────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingL,
                  vertical: AppSizes.paddingS,
                ),
                children: [
                  const SizedBox(height: 8),

                  // Sentence 1
                  Text(
                    l10n.smsSentence1,
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                      height: 1.35,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Sentence 2
                  Text(
                    l10n.smsSentence2(maskedPhone),
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: AppColors.muted,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: AppSizes.paddingL),

                  // ── Real SMS Sample Card ──────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSizes.paddingL),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusLarge),
                      border: Border.all(
                        color: AppColors.surfaceVariant,
                        width: 1.5,
                      ),
                      boxShadow: AppShadows.soft,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'SMS',
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.muted,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'AgroSense',
                              style: TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.smsExampleMessage,
                          style: const TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.ink,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSizes.paddingXL),

                  // ── Two Big Choices (Tap Targets 64+) ──────────────────────
                  _buildChoiceCard(
                    title: l10n.smsOptInOn,
                    description: l10n.smsOptInOnDesc,
                    isSelected: _smsOptIn,
                    onTap: () {
                      setState(() => _smsOptIn = true);
                    },
                  ),

                  const SizedBox(height: AppSizes.paddingM),

                  _buildChoiceCard(
                    title: l10n.smsOptInOff,
                    description: l10n.smsOptInOffDesc,
                    isSelected: !_smsOptIn,
                    onTap: () {
                      setState(() => _smsOptIn = false);
                    },
                  ),

                  const SizedBox(height: AppSizes.paddingXL),

                  // ── Save Pill Button ──────────────────────────────────────
                  PrimaryPillButton(
                    label: _isSaving ? '...' : l10n.saveAndContinue,
                    onPressed: _onSave,
                  ),

                  const SizedBox(height: AppSizes.paddingL),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceCard({
    required String title,
    required String description,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Semantics(
      button: true,
      selected: isSelected,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        child: Container(
          constraints: const BoxConstraints(minHeight: 68),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingL,
            vertical: AppSizes.paddingM,
          ),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.surface : AppColors.surfaceVariant.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
            boxShadow: isSelected ? AppShadows.soft : null,
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.muted,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check_rounded,
                        size: 18,
                        color: AppColors.onPhoto,
                      )
                    : null,
              ),
              const SizedBox(width: AppSizes.paddingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    Text(
                      description,
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
