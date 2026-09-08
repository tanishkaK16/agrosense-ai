import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/routing/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/voice/voice_service.dart';
import '../../core/widgets/farm_photo_header.dart';
import '../../core/widgets/listen_button.dart';
import '../../core/widgets/primary_pill_button.dart';
import '../../generated/l10n/app_localizations.dart';
import 'data/app_auth_repository.dart';

/// Screen 1 of Auth: Phone number entry.
///
/// Features:
/// - Prominent visible +91 prefix
/// - 10-digit phone limitation
/// - Large input field with numeric keyboard
/// - Working Listen button reading title and helper
/// - Continue pill button enabled only when 10 digits entered
class PhoneScreen extends StatefulWidget {
  const PhoneScreen({super.key, this.initialPhone});

  final String? initialPhone;

  @override
  State<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends State<PhoneScreen> {
  late final TextEditingController _phoneController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: widget.initialPhone ?? '');
    _phoneController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    VoiceService.instance.stop();
    _phoneController.dispose();
    super.dispose();
  }

  String get _rawDigits =>
      _phoneController.text.replaceAll(RegExp(r'\D'), '');

  bool get _isValidPhone => _rawDigits.length == 10;

  Future<void> _onContinue() async {
    if (!_isValidPhone || _isLoading) return;

    setState(() => _isLoading = true);
    await VoiceService.instance.stop();

    try {
      await AppAuthRepository.instance.requestOtp(_rawDigits);
      if (mounted) {
        context.push(AppRoutes.otp, extra: _rawDigits);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final topPad = MediaQuery.paddingOf(context).top;
    final speechText = '${l10n.phoneTitle}. ${l10n.phoneSubtitle}.';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Thin hero photo strip ───────────────────────────────────────
          FarmPhotoHeader(
            imagePath: 'assets/images/hero_wheat_closeup.jpg',
            height: 150 + topPad,
            child: Positioned(
              top: topPad + 10,
              left: AppSizes.paddingL,
              right: AppSizes.paddingL,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.eco_rounded,
                        color: AppColors.onPhoto,
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.appName,
                        style: const TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onPhoto,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  ListenButton(
                    onPhoto: true,
                    text: speechText,
                  ),
                ],
              ),
            ),
          ),

          // ── Content ─────────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSizes.paddingM),

                  // Title
                  Text(
                    l10n.phoneTitle,
                    style: AppTextStyles.screenTitle(context),
                  ),
                  const SizedBox(height: 6),

                  // Explanatory line
                  Text(
                    l10n.phoneSubtitle,
                    style: AppTextStyles.body(context).copyWith(
                      color: AppColors.muted,
                    ),
                  ),

                  const SizedBox(height: AppSizes.paddingXL),

                  // Large Indian number card
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusLarge),
                      boxShadow: AppShadows.soft,
                      border: Border.all(
                        color: _isValidPhone
                            ? AppColors.primary
                            : AppColors.surfaceVariant,
                        width: 2,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingL,
                      vertical: AppSizes.paddingM,
                    ),
                    child: Row(
                      children: [
                        // Country code prefix (+91)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            '+91',
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                            ),
                          ),
                        ),

                        const SizedBox(width: 14),

                        // Large digit input
                        Expanded(
                          child: TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            style: const TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                              letterSpacing: 2.0,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                            autofocus: true,
                            decoration: InputDecoration(
                              hintText: '98765 43210',
                              hintStyle: TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 22,
                                fontWeight: FontWeight.w400,
                                color: AppColors.muted.withValues(alpha: 0.4),
                                letterSpacing: 1.5,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),

                        // Valid checkmark
                        if (_isValidPhone)
                          const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.primary,
                            size: 26,
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSizes.paddingXXL),

                  // Continue pill button
                  PrimaryPillButton(
                    label: _isLoading ? '...' : l10n.continueLabel,
                    enabled: _isValidPhone && !_isLoading,
                    onPressed: _onContinue,
                    icon: Icons.arrow_forward_rounded,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
