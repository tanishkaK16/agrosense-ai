import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/routing/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/voice/mic_button.dart';
import '../../core/voice/voice_service.dart';
import '../../core/widgets/listen_button.dart';
import '../../generated/l10n/app_localizations.dart';
import '../fields/data/app_fields_repository.dart';
import '../fields/models/farm_field.dart';
import 'data/app_alerts_repository.dart';
import 'models/farm_alert.dart';

/// Alert Detail Screen — Phase 6.
///
/// Designed so a farmer can finish reviewing in 15 seconds:
/// - Hero field photo with back navigation and Listen button
/// - Severity status pill (Act now / Watch)
/// - Plain-language single-sentence problem description
/// - 2–3 numbered action steps in large, clear type
/// - Farmer-safe advice (no dangerous chemicals/doses)
/// - Reassurance line for when to ask for professional help
/// - Large "Done" pill button that marks the alert as seen and pops back
class AlertDetailScreen extends StatefulWidget {
  const AlertDetailScreen({
    super.key,
    required this.alertId,
  });

  final String alertId;

  @override
  State<AlertDetailScreen> createState() => _AlertDetailScreenState();
}

class _AlertDetailScreenState extends State<AlertDetailScreen> {
  FarmAlert? _alert;
  FarmField? _field;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAlert();
  }

  @override
  void dispose() {
    VoiceService.instance.stop();
    super.dispose();
  }

  Future<void> _loadAlert() async {
    final alert =
        await AppAlertsRepository.instance.getAlertById(widget.alertId);

    if (alert == null) {
      if (mounted) {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(AppRoutes.alerts);
        }
      }
      return;
    }

    final fields = await AppFieldsRepository.instance.getFields();
    FarmField? field;
    for (final f in fields) {
      if (f.id == alert.fieldId) {
        field = f;
        break;
      }
    }

    if (mounted) {
      setState(() {
        _alert = alert;
        _field = field;
        _isLoading = false;
      });
    }
  }

  String _getProblemText(FarmAlert alert, AppLocalizations l10n) {
    switch (alert.kind) {
      case AlertKind.water:
        return alert.severity == AlertSeverity.actNow
            ? l10n.alertProblemWaterCritical
            : l10n.alertProblemWaterLow;
      case AlertKind.pest:
        return alert.severity == AlertSeverity.actNow
            ? l10n.alertProblemPestCritical
            : l10n.alertProblemPestWatch;
      case AlertKind.health:
        return alert.severity == AlertSeverity.actNow
            ? l10n.alertProblemHealthCritical
            : l10n.alertProblemHealthWatch;
    }
  }

  List<String> _getSteps(FarmAlert alert, AppLocalizations l10n) {
    switch (alert.kind) {
      case AlertKind.water:
        return [
          l10n.alertStepWater1,
          l10n.alertStepWater2,
          l10n.alertStepWater3,
        ];
      case AlertKind.pest:
        return [
          l10n.alertStepPest1,
          l10n.alertStepPest2,
          l10n.alertStepPest3,
        ];
      case AlertKind.health:
        return [
          l10n.alertStepHealth1,
          l10n.alertStepHealth2,
          l10n.alertStepHealth3,
        ];
    }
  }

  IconData _getKindIcon(AlertKind kind) {
    switch (kind) {
      case AlertKind.water:
        return Icons.water_drop_rounded;
      case AlertKind.pest:
        return Icons.bug_report_rounded;
      case AlertKind.health:
        return Icons.spa_rounded;
    }
  }

  Future<void> _handleDone() async {
    if (_alert != null) {
      await AppAlertsRepository.instance.markAlertSeen(_alert!.id);
    }
    if (mounted) {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go(AppRoutes.alerts);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      );
    }

    final alert = _alert;
    if (alert == null) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context)!;
    final topPad = MediaQuery.paddingOf(context).top;
    final bottomPad = MediaQuery.paddingOf(context).bottom;

    final isActNow = alert.severity == AlertSeverity.actNow;
    final severityColor = isActNow ? AppColors.danger : AppColors.warning;
    final severityBgColor =
        isActNow ? AppColors.dangerContainer : AppColors.warningContainer;
    final severityLabel = isActNow ? l10n.danger : l10n.warning;

    final fieldName = _field?.name ?? l10n.fieldNameHint;
    final problem = _getProblemText(alert, l10n);
    final steps = _getSteps(alert, l10n);
    final help = l10n.alertHelpNotice;

    // Detail Listen reads the problem, steps, and when to ask for help
    final stepsSpeech = steps.join('. ');
    final speechText = l10n.alertDetailSpeech(problem, stepsSpeech, help);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: bottomPad + 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Hero Field Photo Header ─────────────────────────
                  Stack(
                    children: [
                      // Field image or fallback
                      SizedBox(
                        height: 240,
                        width: double.infinity,
                        child: _field != null
                            ? Image.asset(
                                _field!.photoAsset,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: AppColors.primarySoft,
                                  child: const Center(
                                    child: Icon(
                                      Icons.agriculture_rounded,
                                      size: 56,
                                      color: AppColors.onPhoto,
                                    ),
                                  ),
                                ),
                              )
                            : Container(
                                color: AppColors.primarySoft,
                                child: const Center(
                                  child: Icon(
                                    Icons.agriculture_rounded,
                                    size: 56,
                                    color: AppColors.onPhoto,
                                  ),
                                ),
                              ),
                      ),

                      // Gradient overlay for contrast
                      Container(
                        height: 240,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.50),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.70),
                            ],
                            stops: const [0.0, 0.45, 1.0],
                          ),
                        ),
                      ),

                      // Top navigation bar (Back + Listen)
                      Positioned(
                        top: topPad > 0 ? topPad + 4 : AppSizes.paddingM,
                        left: AppSizes.paddingS,
                        right: AppSizes.paddingM,
                        child: Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: AppColors.surface.withValues(alpha: 0.92),
                                shape: BoxShape.circle,
                                boxShadow: AppShadows.medium,
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: AppColors.ink,
                                  size: 20,
                                ),
                                tooltip: 'Back',
                                onPressed: () {
                                  if (context.canPop()) {
                                    context.pop();
                                  } else {
                                    context.go(AppRoutes.alerts);
                                  }
                                },
                              ),
                            ),
                            const Spacer(),
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.surface.withValues(alpha: 0.92),
                                shape: BoxShape.circle,
                                boxShadow: AppShadows.medium,
                              ),
                              child: MicButton(
                                onPhoto: false,
                                currentListenText: speechText,
                              ),
                            ),
                            const SizedBox(width: AppSizes.paddingS),
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.surface.withValues(alpha: 0.92),
                                shape: BoxShape.circle,
                                boxShadow: AppShadows.medium,
                              ),
                              child: ListenButton(text: speechText),
                            ),
                          ],
                        ),
                      ),

                      // Field name at bottom of hero photo
                      Positioned(
                        left: AppSizes.paddingL,
                        right: AppSizes.paddingL,
                        bottom: AppSizes.paddingL,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fieldName,
                              style: const TextStyle(
                                fontFamily: 'Fraunces',
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onPhoto,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.alertTimeToday,
                              style: const TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.onPhoto,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // ── Problem & Severity Section ───────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSizes.paddingL,
                      AppSizes.paddingL,
                      AppSizes.paddingL,
                      AppSizes.paddingS,
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSizes.paddingL),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius:
                            BorderRadius.circular(AppSizes.radiusLarge),
                        boxShadow: AppShadows.soft,
                        border: Border.all(
                          color: severityColor.withValues(alpha: 0.35),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Status Pill
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: severityBgColor,
                                  borderRadius:
                                      BorderRadius.circular(AppSizes.radiusPill),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _getKindIcon(alert.kind),
                                      size: 16,
                                      color: severityColor,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      severityLabel,
                                      style: TextStyle(
                                        fontFamily: 'Outfit',
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: severityColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // What is wrong (one short sentence)
                          Text(
                            problem,
                            style: const TextStyle(
                              fontFamily: 'Fraunces',
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── What To Do Today Section ─────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSizes.paddingL,
                      AppSizes.paddingM,
                      AppSizes.paddingL,
                      AppSizes.paddingS,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.whatToDoToday,
                          style: const TextStyle(
                            fontFamily: 'Fraunces',
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: AppSizes.paddingM),

                        // 2–3 short steps max, numbered, huge type
                        for (int i = 0; i < steps.length; i++)
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSizes.paddingM,
                            ),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(AppSizes.paddingL),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius:
                                    BorderRadius.circular(AppSizes.radiusLarge),
                                boxShadow: AppShadows.soft,
                                border: Border.all(
                                  color: AppColors.surfaceVariant,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: const BoxDecoration(
                                      color: AppColors.healthyContainer,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${i + 1}',
                                        style: const TextStyle(
                                          fontFamily: 'Outfit',
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSizes.paddingM),
                                  Expanded(
                                    child: Text(
                                      steps[i],
                                      style: const TextStyle(
                                        fontFamily: 'Outfit',
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.ink,
                                        height: 1.35,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // ── When to Ask for Help Notice ──────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSizes.paddingL,
                      AppSizes.paddingS,
                      AppSizes.paddingL,
                      AppSizes.paddingM,
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSizes.paddingL),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant.withValues(alpha: 0.4),
                        borderRadius:
                            BorderRadius.circular(AppSizes.radiusLarge),
                        border: Border.all(
                          color: AppColors.surfaceVariant,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.support_agent_rounded,
                            size: 24,
                            color: AppColors.muted,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              help,
                              style: const TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.muted,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom Large "Done" Button ──────────────────────────────
          Container(
            padding: EdgeInsets.fromLTRB(
              AppSizes.paddingL,
              AppSizes.paddingM,
              AppSizes.paddingL,
              bottomPad > 0 ? bottomPad + 8 : AppSizes.paddingL,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: AppColors.ink.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 64,
                  child: ElevatedButton(
                    onPressed: _handleDone,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle_outline_rounded,
                          size: 24,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.markDone,
                          style: const TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Semantics(
                  button: true,
                  child: InkWell(
                    onTap: () => context.push(AppRoutes.smsInfo),
                    borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.sms_outlined,
                            size: 16,
                            color: AppColors.muted,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            l10n.alsoSentAsSms,
                            style: const TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.muted,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
