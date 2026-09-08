import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/routing/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/voice/mic_button.dart';
import '../../core/voice/voice_service.dart';
import '../../core/widgets/listen_button.dart';
import '../../generated/l10n/app_localizations.dart';
import '../fields/data/app_fields_repository.dart';
import '../fields/models/farm_field.dart';
import 'data/app_alerts_repository.dart';
import 'models/farm_alert.dart';

/// Alerts Screen — Phase 6.
///
/// Features:
/// - List of actionable alerts prioritized by severity (Act now, then Watch)
/// - Plain-language problems, recommended today-actions, and field names
/// - Calm green empty state when no alerts exist
/// - Trailing Listen button reading count and first alert details
class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  List<FarmAlert> _alerts = const [];
  Map<String, FarmField> _fieldMap = const {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    AppAlertsRepository.instance.addListener(_onAlertsUpdate);
    AppFieldsRepository.instance.addListener(_onAlertsUpdate);
  }

  @override
  void dispose() {
    VoiceService.instance.stop();
    AppAlertsRepository.instance.removeListener(_onAlertsUpdate);
    AppFieldsRepository.instance.removeListener(_onAlertsUpdate);
    super.dispose();
  }

  void _onAlertsUpdate() {
    _loadData();
  }

  Future<void> _loadData() async {
    final alerts = await AppAlertsRepository.instance.getAlerts();
    final fields = await AppFieldsRepository.instance.getFields();
    final map = {for (final f in fields) f.id: f};

    if (mounted) {
      setState(() {
        _alerts = alerts;
        _fieldMap = map;
        _isLoading = false;
      });
    }
  }

  String _getAlertProblem(FarmAlert alert, AppLocalizations l10n) {
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

  String _getAlertAction(FarmAlert alert, AppLocalizations l10n) {
    switch (alert.kind) {
      case AlertKind.water:
        return l10n.alertActionWater;
      case AlertKind.pest:
        return l10n.alertActionPest;
      case AlertKind.health:
        return l10n.alertActionHealth;
    }
  }

  IconData _getAlertIcon(AlertKind kind) {
    switch (kind) {
      case AlertKind.water:
        return Icons.water_drop_rounded;
      case AlertKind.pest:
        return Icons.bug_report_rounded;
      case AlertKind.health:
        return Icons.spa_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final topPad = MediaQuery.paddingOf(context).top;

    String speechText = l10n.alertsSpeechEmpty;
    if (_alerts.isNotEmpty) {
      final firstAlert = _alerts.first;
      final firstFieldName =
          _fieldMap[firstAlert.fieldId]?.name ?? l10n.fieldNameHint;
      final firstProblem = _getAlertProblem(firstAlert, l10n);
      speechText = l10n.alertsSpeechCount(
        _alerts.length,
        firstProblem,
        firstFieldName,
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top Bar ──────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.only(
                top: topPad > 0 ? 0 : AppSizes.paddingM,
                left: AppSizes.paddingL,
                right: AppSizes.paddingM,
                bottom: AppSizes.paddingS,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.alerts,
                      style: AppTextStyles.screenTitle(context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingS),
                  MicButton(currentListenText: speechText),
                  const SizedBox(width: AppSizes.paddingS),
                  ListenButton(text: speechText),
                ],
              ),
            ),

            // ── Content ──────────────────────────────────────────────
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    )
                  : _alerts.isEmpty
                      ? _buildEmptyState(context, l10n)
                      : _buildAlertsList(context, l10n),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.paddingXL,
          AppSizes.paddingM,
          AppSizes.paddingXL,
          AppSizes.navBarHeight + AppSizes.navBarBottomMargin + AppSizes.paddingXL,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingXL,
            vertical: AppSizes.paddingXXL,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
            boxShadow: AppShadows.soft,
            border: Border.all(color: AppColors.surfaceVariant),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: AppColors.healthyContainer,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.check_circle_outline_rounded,
                    size: 42,
                    color: AppColors.healthy,
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.paddingL),
              Text(
                l10n.noAlertsToday,
                style: AppTextStyles.labelLarge(context),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.fieldsLookFine,
                style: AppTextStyles.caption(context),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.paddingL),
              Semantics(
                button: true,
                child: TextButton.icon(
                  onPressed: () => context.push(AppRoutes.smsInfo),
                  style: TextButton.styleFrom(
                    minimumSize: const Size(200, 48),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    foregroundColor: AppColors.primary,
                  ),
                  icon: const Icon(Icons.chat_outlined, size: 20),
                  label: Text(
                    l10n.howWillIGetAlerts,
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlertsList(BuildContext context, AppLocalizations l10n) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.paddingL,
        AppSizes.paddingM,
        AppSizes.paddingL,
        AppSizes.navBarHeight + AppSizes.navBarBottomMargin + AppSizes.paddingXL,
      ),
      itemCount: _alerts.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSizes.paddingM),
      itemBuilder: (context, index) {
        final alert = _alerts[index];
        final field = _fieldMap[alert.fieldId];
        return _buildAlertCard(context, alert, field, l10n);
      },
    );
  }

  Widget _buildAlertCard(
    BuildContext context,
    FarmAlert alert,
    FarmField? field,
    AppLocalizations l10n,
  ) {
    final isActNow = alert.severity == AlertSeverity.actNow;
    final stripColor = isActNow ? AppColors.danger : AppColors.warning;
    final statusBgColor =
        isActNow ? AppColors.dangerContainer : AppColors.warningContainer;
    final statusText = isActNow ? l10n.danger : l10n.warning;
    final fieldName = field?.name ?? l10n.fieldNameHint;
    final problem = _getAlertProblem(alert, l10n);
    final action = _getAlertAction(alert, l10n);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/alerts/${alert.id}'),
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
            boxShadow: AppShadows.soft,
            border: Border.all(
              color: stripColor.withValues(alpha: 0.35),
              width: 1.5,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left severity color strip
                Container(
                  width: 8,
                  color: stripColor,
                ),

                // Card details
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.paddingL),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top row: Field name + Time + Severity pill
                        Row(
                          children: [
                            Icon(
                              _getAlertIcon(alert.kind),
                              size: 18,
                              color: stripColor,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                fieldName,
                                style: const TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.muted,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l10n.alertTimeToday,
                              style: AppTextStyles.caption(context),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: statusBgColor,
                                borderRadius:
                                    BorderRadius.circular(AppSizes.radiusPill),
                              ),
                              child: Text(
                                statusText,
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: stripColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // One-line problem
                        Text(
                          problem,
                          style: const TextStyle(
                            fontFamily: 'Fraunces',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // One-line action
                        Text(
                          action,
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.ink.withValues(alpha: 0.85),
                            height: 1.3,
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
      ),
    );
  }
}
