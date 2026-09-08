import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/l10n/locale_controller.dart';
import '../../core/routing/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/voice/voice_service.dart';
import '../../core/widgets/language_sheet.dart';
import '../../core/widgets/listen_button.dart';
import '../../generated/l10n/app_localizations.dart';
import '../auth/data/app_auth_repository.dart';

/// Account & Settings screen — Phase 9 UX.
///
/// Features:
/// - Farmer profile summary: masked phone, name, village, crop
/// - Language preference row opening the consistent [LanguageSheet]
/// - SMS alerts on/off row opening the SMS explanation screen
/// - Outlined danger-tinted Sign out block with confirmed two-pill dialog
/// - High contrast EcoFarm aesthetic with 64+ tap targets
/// - Full VoiceService Listen integration
class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  @override
  void initState() {
    super.initState();
    LocaleController.instance.addListener(_onLocaleChanged);
  }

  @override
  void dispose() {
    VoiceService.instance.stop();
    LocaleController.instance.removeListener(_onLocaleChanged);
    super.dispose();
  }

  void _onLocaleChanged() {
    if (mounted) setState(() {});
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

  String _getCropName(String? cropId, AppLocalizations l10n) {
    switch (cropId?.toLowerCase()) {
      case 'wheat':
        return l10n.cropWheat;
      case 'rice':
        return l10n.cropRice;
      case 'cotton':
        return l10n.cropCotton;
      case 'sugarcane':
        return l10n.cropSugarcane;
      case 'soybean':
        return l10n.cropSoybean;
      case 'other':
        return l10n.cropOther;
      default:
        return cropId ?? l10n.cropWheat;
    }
  }

  String _getLanguageDisplayName(String code) {
    switch (code) {
      case 'hi':
        return 'हिंदी';
      case 'mr':
        return 'मराठी';
      case 'en':
      default:
        return 'English';
    }
  }

  Future<void> _showSignOutConfirmDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    await VoiceService.instance.stop();
    if (!context.mounted) return;

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (dialogContext) {
        final bottomPad = MediaQuery.paddingOf(dialogContext).bottom;

        return Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppSizes.radiusLarge),
            ),
            boxShadow: AppShadows.medium,
          ),
          padding: EdgeInsets.fromLTRB(
            AppSizes.paddingL,
            AppSizes.paddingL,
            AppSizes.paddingL,
            bottomPad + AppSizes.paddingL,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.paddingL),

              // Title: Sign out?
              Text(
                l10n.signOutConfirmTitle,
                style: AppTextStyles.labelLarge(dialogContext).copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: AppSizes.paddingM),

              // Body: You will need your mobile number to sign in again.
              Text(
                l10n.signOutConfirmBody,
                style: AppTextStyles.body(dialogContext).copyWith(
                  fontSize: 16,
                  color: AppColors.muted,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: AppSizes.paddingXL),

              // Stay Pill — Default Visual Emphasis
              Semantics(
                label: l10n.stay,
                button: true,
                child: InkWell(
                  onTap: () => Navigator.of(dialogContext).pop(false),
                  borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                  child: Container(
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                      boxShadow: AppShadows.soft,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      l10n.stay,
                      style: AppTextStyles.button(dialogContext).copyWith(
                        color: AppColors.surface,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.paddingM),

              // Sign Out Pill — Secondary / Darker Red
              Semantics(
                label: l10n.signOut,
                button: true,
                child: InkWell(
                  onTap: () {
                    Navigator.of(dialogContext).pop(true);
                  },
                  borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                  child: Container(
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                      border: Border.all(
                        color: AppColors.danger,
                        width: 2,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      l10n.signOut,
                      style: AppTextStyles.button(dialogContext).copyWith(
                        color: AppColors.danger,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (confirmed == true && context.mounted) {
      await AppAuthRepository.instance.signOut();
      if (!context.mounted) return;
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            l10n.signedOut,
            style: const TextStyle(
              fontFamily: 'Outfit',
              color: AppColors.surface,
            ),
          ),
          backgroundColor: AppColors.ink,
          duration: const Duration(seconds: 2),
        ),
      );
      // Navigate to phone and clear navigation stack so back cannot return to Home
      context.go(AppRoutes.phone);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final profile = AppAuthRepository.instance.currentProfile();
    final maskedPhone = _getMaskedPhone();

    final activeLocaleCode =
        LocaleController.instance.locale?.languageCode ??
        Localizations.localeOf(context).languageCode;
    final activeLangName = _getLanguageDisplayName(activeLocaleCode);

    final farmerName = (profile?.name.trim().isNotEmpty ?? false)
        ? profile!.name.trim()
        : 'Farmer';
    final village = profile?.village.trim() ?? '';
    final crop = _getCropName(profile?.mainCrop, l10n);
    final smsStatusText = (profile?.smsOptIn ?? true) ? l10n.smsOptInOn : l10n.smsOptInOff;

    final speechSummary =
        '${l10n.account}. $farmerName. $village. $crop. $maskedPhone. '
        '${l10n.currentLanguage}: $activeLangName. '
        '${l10n.smsAlerts}: $smsStatusText. '
        '${l10n.signOut}.';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Bar ─────────────────────────────────────────────────────
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
                        VoiceService.instance.stop();
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go(AppRoutes.home);
                        }
                      },
                      borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.surfaceVariant),
                          boxShadow: AppShadows.soft,
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          size: 24,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingM),
                  Expanded(
                    child: Text(
                      l10n.account,
                      style: AppTextStyles.screenTitle(context).copyWith(
                        fontSize: 26,
                      ),
                    ),
                  ),
                  ListenButton(
                    onPhoto: false,
                    text: speechSummary,
                  ),
                ],
              ),
            ),

            // ── Body ────────────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingL,
                  vertical: AppSizes.paddingS,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Profile Card
                    Container(
                      padding: const EdgeInsets.all(AppSizes.paddingL),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                        border: Border.all(color: AppColors.surfaceVariant),
                        boxShadow: AppShadows.soft,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: const BoxDecoration(
                              color: AppColors.goldSoft,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.person_rounded,
                              size: 36,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: AppSizes.paddingL),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  farmerName,
                                  style: AppTextStyles.labelLarge(context).copyWith(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                if (village.isNotEmpty) ...[
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.place_outlined,
                                        size: 16,
                                        color: AppColors.muted,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        village,
                                        style: AppTextStyles.caption(context).copyWith(
                                          fontSize: 14,
                                          color: AppColors.muted,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                ],
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.eco_outlined,
                                      size: 16,
                                      color: AppColors.muted,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      crop,
                                      style: AppTextStyles.caption(context).copyWith(
                                        fontSize: 14,
                                        color: AppColors.muted,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  maskedPhone,
                                  style: AppTextStyles.caption(context).copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.ink,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingL),

                    // Preferences Card: Language & SMS
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                        border: Border.all(color: AppColors.surfaceVariant),
                        boxShadow: AppShadows.soft,
                      ),
                      child: Column(
                        children: [
                          // Language Row
                          Semantics(
                            label: '${l10n.changeLanguage}: $activeLangName',
                            button: true,
                            child: InkWell(
                              onTap: () {
                                VoiceService.instance.stop();
                                LanguageSheet.show(context);
                              },
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(AppSizes.radiusLarge),
                              ),
                              child: Container(
                                constraints: const BoxConstraints(minHeight: 68),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSizes.paddingL,
                                  vertical: AppSizes.paddingM,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                                        shape: BoxShape.circle,
                                      ),
                                      alignment: Alignment.center,
                                      child: const Icon(
                                        Icons.translate_rounded,
                                        color: AppColors.primary,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: AppSizes.paddingM),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            l10n.changeLanguage,
                                            style: AppTextStyles.labelLarge(context).copyWith(
                                              fontSize: 16,
                                            ),
                                          ),
                                          Text(
                                            activeLangName,
                                            style: AppTextStyles.caption(context).copyWith(
                                              fontSize: 13,
                                              color: AppColors.muted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Icons.chevron_right_rounded,
                                      color: AppColors.muted,
                                      size: 24,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const Divider(height: 1, indent: 64),

                          // SMS Alerts Row
                          Semantics(
                            label: '${l10n.smsAlerts}: $smsStatusText',
                            button: true,
                            child: InkWell(
                              onTap: () {
                                VoiceService.instance.stop();
                                context.push(AppRoutes.smsInfo);
                              },
                              borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(AppSizes.radiusLarge),
                              ),
                              child: Container(
                                constraints: const BoxConstraints(minHeight: 68),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSizes.paddingL,
                                  vertical: AppSizes.paddingM,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                                        shape: BoxShape.circle,
                                      ),
                                      alignment: Alignment.center,
                                      child: const Icon(
                                        Icons.sms_outlined,
                                        color: AppColors.primary,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: AppSizes.paddingM),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            l10n.smsAlerts,
                                            style: AppTextStyles.labelLarge(context).copyWith(
                                              fontSize: 16,
                                            ),
                                          ),
                                          Text(
                                            smsStatusText,
                                            style: AppTextStyles.caption(context).copyWith(
                                              fontSize: 13,
                                              color: AppColors.muted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Icons.chevron_right_rounded,
                                      color: AppColors.muted,
                                      size: 24,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingXL),

                    // Sign Out Block — Outlined / Danger-Tinted
                    Semantics(
                      label: l10n.signOut,
                      button: true,
                      child: InkWell(
                        onTap: () => _showSignOutConfirmDialog(context),
                        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                        child: Container(
                          constraints: const BoxConstraints(minHeight: 68),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.paddingL,
                            vertical: AppSizes.paddingM,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                            border: Border.all(
                              color: AppColors.danger.withValues(alpha: 0.5),
                              width: 2,
                            ),
                            boxShadow: AppShadows.soft,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.logout_rounded,
                                color: AppColors.danger,
                                size: 24,
                              ),
                              const SizedBox(width: AppSizes.paddingM),
                              Text(
                                l10n.signOut,
                                style: AppTextStyles.button(context).copyWith(
                                  color: AppColors.danger,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingXL),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
