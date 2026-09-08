import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/routing/app_router.dart';
import '../../core/storage/app_prefs.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/voice/voice_service.dart';
import '../../core/widgets/listen_button.dart';
import '../../core/widgets/primary_pill_button.dart';
import '../../generated/l10n/app_localizations.dart';
import 'data/mock_auth_repository.dart';

/// Screen 2 of Auth: 4-digit OTP verification.
///
/// Features:
/// - 4 large visual digit boxes
/// - Auto-advance and auto-submit on 4th digit
/// - Resend button with 30s cooldown
/// - Listen button
/// - Demo code hint behind [kShowDemoOtp]
/// - Back navigation preserves phone number
class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key, required this.phoneNumber});

  final String phoneNumber;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool _isVerifying = false;
  String? _errorMessage;
  int _resendCooldown = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCooldownTimer();
    _otpController.addListener(_onOtpChanged);
  }

  @override
  void dispose() {
    VoiceService.instance.stop();
    _timer?.cancel();
    _otpController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startCooldownTimer() {
    _timer?.cancel();
    setState(() => _resendCooldown = 30);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCooldown > 1) {
        setState(() => _resendCooldown--);
      } else {
        setState(() => _resendCooldown = 0);
        timer.cancel();
      }
    });
  }

  bool _clearingForError = false;

  void _onOtpChanged() {
    if (_clearingForError) return;
    if (_errorMessage != null) {
      setState(() => _errorMessage = null);
    }
    if (_otpController.text.length == 4 && !_isVerifying) {
      _verifyCode(_otpController.text);
    } else {
      setState(() {});
    }
  }

  String _formatMaskedPhone(String raw) {
    if (raw.length == 10) {
      final prefix = raw.substring(0, 2);
      final suffix = raw.substring(8);
      return '+91 $prefix*** **$suffix';
    }
    return '+91 $raw';
  }

  Future<void> _verifyCode(String code) async {
    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    await VoiceService.instance.stop();

    final session = await MockAuthRepository.instance.verifyOtp(
      widget.phoneNumber,
      code,
    );

    if (!mounted) return;

    if (session != null) {
      // Check if profile is already complete
      if (AppPrefs.instance.hasProfile) {
        context.go(AppRoutes.home);
      } else {
        context.go(AppRoutes.profile);
      }
    } else {
      final l10n = AppLocalizations.of(context)!;
      _clearingForError = true;
      _otpController.clear();
      _clearingForError = false;
      setState(() {
        _isVerifying = false;
        _errorMessage = l10n.otpWrongCode;
      });
      _focusNode.requestFocus();
    }
  }

  Future<void> _onResend() async {
    if (_resendCooldown > 0) return;
    _startCooldownTimer();
    await MockAuthRepository.instance.requestOtp(widget.phoneNumber);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final maskedPhone = _formatMaskedPhone(widget.phoneNumber);
    final subtitleText = l10n.otpSubtitle(maskedPhone);
    final speechText = '${l10n.otpTitle}. $subtitleText.';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Bar with Back and Listen buttons ────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingM,
                vertical: AppSizes.paddingS,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button
                  Semantics(
                    label: 'Back to phone number',
                    button: true,
                    child: InkWell(
                      onTap: () {
                        VoiceService.instance.stop();
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go(AppRoutes.phone);
                        }
                      },
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusPill),
                      child: Container(
                        width: AppSizes.minTapTarget,
                        height: AppSizes.minTapTarget,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          size: AppSizes.iconMedium,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                  ),

                  // Listen button
                  ListenButton(
                    onPhoto: false,
                    text: speechText,
                  ),
                ],
              ),
            ),

            // ── Form Area ───────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.paddingL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSizes.paddingM),

                    // Title
                    Text(
                      l10n.otpTitle,
                      style: AppTextStyles.screenTitle(context),
                    ),
                    const SizedBox(height: 6),

                    // Subtitle with masked phone
                    Text(
                      subtitleText,
                      style: AppTextStyles.body(context).copyWith(
                        color: AppColors.muted,
                      ),
                    ),

                    const SizedBox(height: AppSizes.paddingXL),

                    // 4 Digit Input Boxes with hidden TextField
                    GestureDetector(
                      onTap: () => _focusNode.requestFocus(),
                      behavior: HitTestBehavior.opaque,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // 4 Visual Boxes
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(4, (index) {
                              final text = _otpController.text;
                              final char =
                                  index < text.length ? text[index] : '';
                              final isCurrent = index == text.length;

                              return Container(
                                width: 68,
                                height: 76,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.radiusMedium,
                                  ),
                                  border: Border.all(
                                    color: _errorMessage != null
                                        ? AppColors.danger
                                        : isCurrent
                                            ? AppColors.primary
                                            : AppColors.surfaceVariant,
                                    width: isCurrent ? 2.5 : 1.5,
                                  ),
                                  boxShadow: isCurrent
                                      ? AppShadows.medium
                                      : AppShadows.soft,
                                ),
                                child: Text(
                                  char,
                                  style: const TextStyle(
                                    fontFamily: 'Outfit',
                                    fontSize: 32,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.ink,
                                  ),
                                ),
                              );
                            }),
                          ),

                          // Transparent real TextField overlay
                          Opacity(
                            opacity: 0.0,
                            child: TextField(
                              controller: _otpController,
                              focusNode: _focusNode,
                              autofocus: true,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(4),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Error text
                    if (_errorMessage != null) ...[
                      const SizedBox(height: AppSizes.paddingM),
                      Row(
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            size: 18,
                            color: AppColors.danger,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.danger,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: AppSizes.paddingXL),

                    // Resend button
                    SizedBox(
                      height: 52,
                      child: TextButton(
                        onPressed: _resendCooldown == 0 ? _onResend : null,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.paddingM,
                          ),
                        ),
                        child: Text(
                          _resendCooldown > 0
                              ? l10n.resendCodeIn(_resendCooldown)
                              : l10n.resendCode,
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _resendCooldown > 0
                                ? AppColors.muted
                                : AppColors.primary,
                          ),
                        ),
                      ),
                    ),

                    // Demo code hint
                    if (kShowDemoOtp) ...[
                      const SizedBox(height: 8),
                      Text(
                        l10n.demoCodeNotice,
                        style: AppTextStyles.caption(context).copyWith(
                          color: AppColors.wheat,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],

                    const SizedBox(height: AppSizes.paddingXL),

                    // Manual Continue Button
                    PrimaryPillButton(
                      label: _isVerifying
                          ? '...'
                          : l10n.continueLabel,
                      enabled:
                          _otpController.text.length == 4 && !_isVerifying,
                      onPressed: () => _verifyCode(_otpController.text),
                      icon: Icons.arrow_forward_rounded,
                    ),
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
