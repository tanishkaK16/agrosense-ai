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
import '../alerts/data/mock_alerts_repository.dart';
import '../alerts/models/farm_alert.dart';
import 'data/local_fields_repository.dart';
import 'data/mock_field_status_repository.dart';
import 'models/farm_field.dart';
import 'models/field_status.dart';

/// Screen displaying farmer-plain telemetry for a single field (Phase 5).
///
/// Features:
/// - Full-width field hero photo with visual corner overlay
/// - 3-zone color legend (Healthy, Watch, Needs care)
/// - 3 big meters: Health, Water, Pest
/// - Summary card with single plain-language recommendation
/// - Listen button reading full status aloud
class FieldDetailScreen extends StatefulWidget {
  const FieldDetailScreen({
    super.key,
    required this.fieldId,
  });

  final String fieldId;

  @override
  State<FieldDetailScreen> createState() => _FieldDetailScreenState();
}

class _FieldDetailScreenState extends State<FieldDetailScreen> {
  FarmField? _field;
  FieldStatus? _status;
  FarmAlert? _alert;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFieldAndStatus();
  }

  @override
  void dispose() {
    VoiceService.instance.stop();
    super.dispose();
  }

  Future<void> _loadFieldAndStatus() async {
    final fields = await LocalFieldsRepository.instance.getFields();
    final match = fields.where((f) => f.id == widget.fieldId);

    if (match.isEmpty) {
      if (mounted) {
        // Missing field id — quietly return to fields list without crashing
        try {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go(AppRoutes.fields);
          }
        } catch (_) {
          Navigator.of(context).maybePop();
        }
      }
      return;
    }

    final field = match.first;
    final status = await MockFieldStatusRepository.instance.getFieldStatus(
      widget.fieldId,
    );

    final alerts = await MockAlertsRepository.instance.getAlerts();
    FarmAlert? fieldAlert;
    for (final a in alerts) {
      if (a.fieldId == widget.fieldId) {
        fieldAlert = a;
        break;
      }
    }

    if (mounted) {
      setState(() {
        _field = field;
        _status = status;
        _alert = fieldAlert;
        _isLoading = false;
      });
    }
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

  String _getHealthStatusLabel(HealthLevel level, AppLocalizations l10n) {
    switch (level) {
      case HealthLevel.good:
        return l10n.good;
      case HealthLevel.watch:
        return l10n.warning;
      case HealthLevel.actNow:
        return l10n.danger;
    }
  }

  String _getWaterStatusLabel(WaterLevel level, AppLocalizations l10n) {
    switch (level) {
      case WaterLevel.good:
        return l10n.statusOkay;
      case WaterLevel.low:
        return l10n.statusLow;
      case WaterLevel.actNow:
        return l10n.danger;
    }
  }

  String _getPestStatusLabel(PestLevel level, AppLocalizations l10n) {
    switch (level) {
      case PestLevel.good:
        return l10n.statusOkay;
      case PestLevel.watch:
        return l10n.warning;
      case PestLevel.actNow:
        return l10n.danger;
    }
  }

  String _getSummarySentence(FieldStatus status, AppLocalizations l10n) {
    if (status.health == HealthLevel.actNow ||
        status.water == WaterLevel.actNow ||
        status.pest == PestLevel.actNow) {
      return l10n.detailSummaryActNow;
    }
    if (status.water == WaterLevel.low) {
      return l10n.detailSummaryWaterLow;
    }
    if (status.pest == PestLevel.watch) {
      return l10n.detailSummaryPestWatch;
    }
    return l10n.detailSummaryAllGood;
  }

  Color _getMeterColor({
    required bool isDanger,
    required bool isWarning,
  }) {
    if (isDanger) return AppColors.danger;
    if (isWarning) return AppColors.warning;
    return AppColors.healthy;
  }

  Widget _buildOverlay(OverlayHint hint, FieldStatus status) {
    if (hint == OverlayHint.none) {
      return Container(
        color: AppColors.healthy.withValues(alpha: 0.08),
      );
    }

    final isSevere = status.health == HealthLevel.actNow ||
        status.water == WaterLevel.actNow ||
        status.pest == PestLevel.actNow;
    final color = isSevere ? AppColors.danger : AppColors.warning;

    Alignment center;
    switch (hint) {
      case OverlayHint.left:
        center = Alignment.centerLeft;
        break;
      case OverlayHint.right:
        center = Alignment.centerRight;
        break;
      case OverlayHint.far:
        center = Alignment.topCenter;
        break;
      case OverlayHint.none:
        center = Alignment.center;
        break;
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: center,
          radius: 0.95,
          colors: [
            color.withValues(alpha: 0.40),
            color.withValues(alpha: 0.15),
            Colors.transparent,
          ],
          stops: const [0.0, 0.4, 1.0],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final topPad = MediaQuery.paddingOf(context).top;

    if (_isLoading || _field == null || _status == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      );
    }

    final field = _field!;
    final status = _status!;
    final summaryText = _getSummarySentence(status, l10n);
    final cropLabel = _getCropName(field.crop, l10n);

    final healthWord = _getHealthStatusLabel(status.health, l10n);
    final waterWord = _getWaterStatusLabel(status.water, l10n);
    final pestWord = _getPestStatusLabel(status.pest, l10n);

    final speechText = l10n.fieldDetailSpeech(
      field.name,
      healthWord,
      waterWord,
      pestWord,
      summaryText,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top Hero Photo Card with Scrim & Actions ───────────────
            Stack(
              children: [
                SizedBox(
                  height: 270,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        field.photoAsset,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColors.primarySoft,
                          child: const Center(
                            child: Icon(
                              Icons.agriculture_rounded,
                              size: 64,
                              color: AppColors.onPhoto,
                            ),
                          ),
                        ),
                      ),

                      // Soft visual overlay matching stressed sector
                      _buildOverlay(status.overlayHint, status),

                      // Gradient overlay for contrast
                      Container(
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
                    ],
                  ),
                ),

                // Top navigation bar overlay
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
                              context.go(AppRoutes.fields);
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
                        child: MicButton(currentListenText: speechText),
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

                // Field name and crop at bottom of photo
                Positioned(
                  left: AppSizes.paddingL,
                  right: AppSizes.paddingL,
                  bottom: AppSizes.paddingL,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        field.name,
                        style: const TextStyle(
                          fontFamily: 'Fraunces',
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onPhoto,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.ink.withValues(alpha: 0.55),
                              borderRadius:
                                  BorderRadius.circular(AppSizes.radiusPill),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.35),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.eco_rounded,
                                  size: 14,
                                  color: AppColors.onPhoto,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  cropLabel,
                                  style: const TextStyle(
                                    fontFamily: 'Outfit',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.onPhoto,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (field.village != null &&
                              field.village!.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.ink.withValues(alpha: 0.55),
                                borderRadius:
                                    BorderRadius.circular(AppSizes.radiusPill),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.location_on_outlined,
                                    size: 14,
                                    color: AppColors.onPhoto,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    field.village!,
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
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // ── 3-Zone Legend Chips ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.paddingL,
                AppSizes.paddingL,
                AppSizes.paddingL,
                AppSizes.paddingS,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildLegendChip(
                      dotColor: AppColors.healthy,
                      label: l10n.legendHealthy,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildLegendChip(
                      dotColor: AppColors.warning,
                      label: l10n.legendWatch,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildLegendChip(
                      dotColor: AppColors.danger,
                      label: l10n.legendNeedsCare,
                    ),
                  ),
                ],
              ),
            ),

            // ── Three Meters Column ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingL,
                vertical: AppSizes.paddingS,
              ),
              child: Container(
                padding: const EdgeInsets.all(AppSizes.paddingL),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                  boxShadow: AppShadows.soft,
                  border: Border.all(color: AppColors.surfaceVariant),
                ),
                child: Column(
                  children: [
                    // Meter 1: Health
                    _buildMeterRow(
                      icon: Icons.spa_rounded,
                      label: l10n.meterHealth,
                      statusWord: healthWord,
                      fraction: status.health == HealthLevel.good
                          ? 0.95
                          : (status.health == HealthLevel.watch ? 0.55 : 0.25),
                      color: _getMeterColor(
                        isDanger: status.health == HealthLevel.actNow,
                        isWarning: status.health == HealthLevel.watch,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Divider(
                        height: 1,
                        color: AppColors.surfaceVariant,
                      ),
                    ),

                    // Meter 2: Water
                    _buildMeterRow(
                      icon: Icons.water_drop_rounded,
                      label: l10n.meterWater,
                      statusWord: waterWord,
                      hintWord: status.water == WaterLevel.low
                          ? l10n.statusDry
                          : l10n.statusOkay,
                      fraction: status.water == WaterLevel.good
                          ? 0.90
                          : (status.water == WaterLevel.low ? 0.40 : 0.15),
                      color: _getMeterColor(
                        isDanger: status.water == WaterLevel.actNow,
                        isWarning: status.water == WaterLevel.low,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Divider(
                        height: 1,
                        color: AppColors.surfaceVariant,
                      ),
                    ),

                    // Meter 3: Pest
                    _buildMeterRow(
                      icon: Icons.bug_report_rounded,
                      label: l10n.meterPest,
                      statusWord: pestWord,
                      hintWord: status.pest == PestLevel.watch
                          ? l10n.statusRisk
                          : l10n.statusOkay,
                      fraction: status.pest == PestLevel.good
                          ? 0.95
                          : (status.pest == PestLevel.watch ? 0.45 : 0.20),
                      color: _getMeterColor(
                        isDanger: status.pest == PestLevel.actNow,
                        isWarning: status.pest == PestLevel.watch,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Farmer-Plain Summary Card ───────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.paddingL,
                AppSizes.paddingS,
                AppSizes.paddingL,
                AppSizes.paddingXL,
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSizes.paddingL),
                decoration: BoxDecoration(
                  color: _getSummaryBgColor(status),
                  borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                  boxShadow: AppShadows.soft,
                  border: Border.all(
                    color: _getSummaryBorderColor(status),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      _getSummaryIcon(status),
                      color: _getSummaryTextColor(status),
                      size: 26,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            summaryText,
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: _getSummaryTextColor(status),
                              height: 1.4,
                            ),
                          ),
                          if (_alert != null) ...[
                            const SizedBox(height: 10),
                            InkWell(
                              onTap: () => context.push('/alerts/${_alert!.id}'),
                              borderRadius:
                                  BorderRadius.circular(AppSizes.radiusPill),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius:
                                      BorderRadius.circular(AppSizes.radiusPill),
                                  border: Border.all(
                                    color: _getSummaryBorderColor(status),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      l10n.seeWhatToDo,
                                      style: TextStyle(
                                        fontFamily: 'Outfit',
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: _getSummaryTextColor(status),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 14,
                                      color: _getSummaryTextColor(status),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
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

  Widget _buildLegendChip({
    required Color dotColor,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        boxShadow: AppShadows.soft,
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Outfit',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeterRow({
    required IconData icon,
    required String label,
    required String statusWord,
    required double fraction,
    required Color color,
    String? hintWord,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(icon, color: color, size: 20),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  if (hintWord != null)
                    Text(
                      hintWord,
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.muted,
                      ),
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppSizes.radiusPill),
              ),
              child: Text(
                statusWord,
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Thick rounded status bar
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 10,
            width: double.infinity,
            color: AppColors.surfaceVariant,
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: fraction.clamp(0.05, 1.0),
              child: Container(color: color),
            ),
          ),
        ),
      ],
    );
  }

  Color _getSummaryBgColor(FieldStatus status) {
    if (status.health == HealthLevel.actNow ||
        status.water == WaterLevel.actNow ||
        status.pest == PestLevel.actNow) {
      return AppColors.dangerContainer;
    }
    if (status.water == WaterLevel.low || status.pest == PestLevel.watch) {
      return AppColors.warningContainer;
    }
    return AppColors.healthyContainer;
  }

  Color _getSummaryBorderColor(FieldStatus status) {
    if (status.health == HealthLevel.actNow ||
        status.water == WaterLevel.actNow ||
        status.pest == PestLevel.actNow) {
      return AppColors.danger.withValues(alpha: 0.4);
    }
    if (status.water == WaterLevel.low || status.pest == PestLevel.watch) {
      return AppColors.warning.withValues(alpha: 0.5);
    }
    return AppColors.healthy.withValues(alpha: 0.4);
  }

  Color _getSummaryTextColor(FieldStatus status) {
    if (status.health == HealthLevel.actNow ||
        status.water == WaterLevel.actNow ||
        status.pest == PestLevel.actNow) {
      return AppColors.danger;
    }
    if (status.water == WaterLevel.low || status.pest == PestLevel.watch) {
      return AppColors.ink;
    }
    return AppColors.healthy;
  }

  IconData _getSummaryIcon(FieldStatus status) {
    if (status.health == HealthLevel.actNow ||
        status.water == WaterLevel.actNow ||
        status.pest == PestLevel.actNow) {
      return Icons.error_outline_rounded;
    }
    if (status.water == WaterLevel.low || status.pest == PestLevel.watch) {
      return Icons.info_outline_rounded;
    }
    return Icons.check_circle_outline_rounded;
  }
}
