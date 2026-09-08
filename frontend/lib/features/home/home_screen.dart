import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/routing/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/listen_button.dart';
import '../../generated/l10n/app_localizations.dart';
import '../auth/data/mock_auth_repository.dart';
import '../fields/data/local_fields_repository.dart';
import '../fields/models/farm_field.dart';
import 'data/mock_home_repository.dart';
import 'models/home_snapshot.dart';

/// Farmer Home Screen — Phase 3.
///
/// Features:
/// - Personalized farmer greeting with village location
/// - Trailing Listen button reading full home summary aloud
/// - Weather strip with large icons and plain units
/// - Main field health card with green/amber/red status pill
/// - Single-sentence health advice (no jargon)
/// - Thin alerts card (0 alerts or tap to inspect)
/// - One-handed ergonomics with floating navigation pill
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HomeSnapshot? _snapshot;
  FarmField? _firstField;

  @override
  void initState() {
    super.initState();
    _loadSnapshot();
    LocalFieldsRepository.instance.addListener(_onFieldsUpdate);
  }

  @override
  void dispose() {
    LocalFieldsRepository.instance.removeListener(_onFieldsUpdate);
    super.dispose();
  }

  void _onFieldsUpdate() {
    _loadSnapshot();
  }

  Future<void> _loadSnapshot() async {
    final profile = MockAuthRepository.instance.currentProfile();
    final fields = await LocalFieldsRepository.instance.getFields();
    final firstField = fields.isNotEmpty ? fields.first : null;

    final snapshot = await MockHomeRepository.instance.getHomeSnapshot(
      defaultCrop: firstField?.crop ?? profile?.mainCrop,
      fieldName: firstField?.name,
      fieldHealth: firstField?.health,
    );
    if (mounted) {
      setState(() {
        _firstField = firstField;
        _snapshot = snapshot;
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

  String _getHealthLabel(FieldHealth health, AppLocalizations l10n) {
    switch (health) {
      case FieldHealth.healthy:
        return l10n.healthyStatus;
      case FieldHealth.watch:
        return l10n.watchStatus;
      case FieldHealth.actNow:
        return l10n.actNowStatus;
    }
  }

  Color _getHealthColor(FieldHealth health) {
    switch (health) {
      case FieldHealth.healthy:
        return AppColors.healthy;
      case FieldHealth.watch:
        return AppColors.warning;
      case FieldHealth.actNow:
        return AppColors.danger;
    }
  }

  Color _getHealthBgColor(FieldHealth health) {
    switch (health) {
      case FieldHealth.healthy:
        return AppColors.healthyContainer;
      case FieldHealth.watch:
        return AppColors.warningContainer;
      case FieldHealth.actNow:
        return AppColors.dangerContainer;
    }
  }

  IconData _getHealthIcon(FieldHealth health) {
    switch (health) {
      case FieldHealth.healthy:
        return Icons.check_circle_rounded;
      case FieldHealth.watch:
        return Icons.warning_amber_rounded;
      case FieldHealth.actNow:
        return Icons.error_outline_rounded;
    }
  }

  String _getHealthSummary(FieldHealth health, AppLocalizations l10n) {
    switch (health) {
      case FieldHealth.healthy:
        return l10n.healthSummaryHealthy;
      case FieldHealth.watch:
        return l10n.healthSummaryWatch;
      case FieldHealth.actNow:
        return l10n.healthSummaryActNow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final profile = MockAuthRepository.instance.currentProfile();

    final greetingName =
        (profile?.name.isNotEmpty == true && profile?.name != 'Farmer')
            ? profile!.name
            : null;
    final greetingText = greetingName != null
        ? l10n.helloName(greetingName)
        : l10n.helloFarmer;

    final snapshot = _snapshot;
    final health = snapshot?.health ?? FieldHealth.healthy;
    final healthLabel = _getHealthLabel(health, l10n);
    final summaryText = _getHealthSummary(health, l10n);
    final cropLabel = _getCropName(snapshot?.crop, l10n);

    final alertCount = snapshot?.alertCount ?? 0;
    final alertsText = alertCount > 0
        ? l10n.alertsTapToSee(alertCount)
        : l10n.noAlertsToday;

    // Speech text for voice guidance
    final speechText = l10n.homeSpeech(
      greetingText,
      snapshot?.temperatureC ?? 32,
      snapshot?.rainMm ?? 0,
      healthLabel,
      alertsText,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.paddingL,
            AppSizes.paddingM,
            AppSizes.paddingL,
            // Space so floating nav bar does not cover contents
            AppSizes.navBarHeight + AppSizes.navBarBottomMargin + 32,
          ),
          children: [
            // ── Top Bar: Greeting, Village & Listen Button ───────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        greetingText,
                        style: AppTextStyles.screenTitle(context).copyWith(
                          fontSize: 28,
                        ),
                      ),
                      if (profile?.village.isNotEmpty == true) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.place_outlined,
                              size: 16,
                              color: AppColors.muted,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              profile!.village,
                              style: AppTextStyles.caption(context).copyWith(
                                fontSize: 14,
                                color: AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                ListenButton(
                  onPhoto: false,
                  text: speechText,
                ),
              ],
            ),

            const SizedBox(height: AppSizes.paddingL),

            // ── Weather Strip (3 items: Temp, Rain, Wind) ───────────────────
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                boxShadow: AppShadows.soft,
                border: Border.all(color: AppColors.surfaceVariant),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingM,
                vertical: AppSizes.paddingM,
              ),
              child: Row(
                children: [
                  // Temperature
                  Expanded(
                    child: _WeatherItem(
                      icon: Icons.wb_sunny_rounded,
                      iconColor: AppColors.wheat,
                      value: '${snapshot?.temperatureC ?? 32}°',
                      label: l10n.weatherTemp,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: AppColors.surfaceVariant,
                  ),
                  // Rain
                  Expanded(
                    child: _WeatherItem(
                      icon: Icons.water_drop_rounded,
                      iconColor: const Color(0xFF5B8E7D),
                      value: '${snapshot?.rainMm ?? 0} mm',
                      label: l10n.weatherRain,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: AppColors.surfaceVariant,
                  ),
                  // Wind
                  Expanded(
                    child: _WeatherItem(
                      icon: Icons.air_rounded,
                      iconColor: AppColors.primarySoft,
                      value: '${snapshot?.windKmh ?? 12} km/h',
                      label: l10n.weatherWind,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSizes.paddingL),

            // ── Main Card: My Field Today ───────────────────────────────────
            Semantics(
              label: '${l10n.myFieldToday}, $healthLabel. $summaryText',
              button: true,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    if (_firstField != null) {
                      context.push('/fields/${_firstField!.id}');
                    } else {
                      context.go(AppRoutes.fields);
                    }
                  },
                  borderRadius: BorderRadius.circular(AppSizes.radiusLarge + 4),
                  child: Container(
                    height: 250,
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusLarge + 4),
                      boxShadow: AppShadows.medium,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Real farm photograph
                        Image.asset(
                          _firstField?.photoAsset ??
                              'assets/images/hero_field_wide.jpg',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const ColoredBox(
                            color: AppColors.goldSoft,
                          ),
                        ),

                        // Bottom-to-top scrim
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: AppColors.photoScrimGradient,
                              stops: [0.3, 1.0],
                            ),
                          ),
                        ),

                        // Card Content
                        Padding(
                          padding: const EdgeInsets.all(AppSizes.paddingL),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Top row: Title + Crop badge & Health Status Pill
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _firstField != null
                                              ? _firstField!.name
                                              : l10n.myFieldToday,
                                          style: const TextStyle(
                                            fontFamily: 'Fraunces',
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.onPhoto,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.ink
                                                  .withValues(alpha: 0.5),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                AppSizes.radiusPill,
                                              ),
                                              border: Border.all(
                                                color: Colors.white
                                                    .withValues(alpha: 0.3),
                                              ),
                                            ),
                                            child: Text(
                                              cropLabel,
                                              style: const TextStyle(
                                                fontFamily: 'Outfit',
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.onPhoto,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),

                                  // Status Pill (Healthy / Watch / Act now)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getHealthBgColor(health),
                                      borderRadius: BorderRadius.circular(
                                        AppSizes.radiusPill,
                                      ),
                                      boxShadow: AppShadows.soft,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          _getHealthIcon(health),
                                          size: 18,
                                          color: _getHealthColor(health),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          healthLabel,
                                          style: TextStyle(
                                            fontFamily: 'Outfit',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: _getHealthColor(health),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              // Bottom advice sentence
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      summaryText,
                                      style: const TextStyle(
                                        fontFamily: 'Outfit',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.onPhoto,
                                        height: 1.35,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withValues(alpha: 0.2),
                                    ),
                                    child: const Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 16,
                                      color: AppColors.onPhoto,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSizes.paddingL),

            // ── Alerts Card ─────────────────────────────────────────────────
            Semantics(
              label: alertsText,
              button: true,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => context.go(AppRoutes.alerts),
                  borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingL,
                      vertical: AppSizes.paddingM + 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusLarge),
                      boxShadow: AppShadows.soft,
                      border: Border.all(
                        color: alertCount > 0
                            ? AppColors.warning
                            : AppColors.surfaceVariant,
                        width: alertCount > 0 ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: alertCount > 0
                                ? AppColors.warningContainer
                                : AppColors.healthyContainer,
                          ),
                          child: Icon(
                            alertCount > 0
                                ? Icons.warning_amber_rounded
                                : Icons.check_circle_outline_rounded,
                            color: alertCount > 0
                                ? AppColors.warning
                                : AppColors.healthy,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: AppSizes.paddingM),
                        Expanded(
                          child: Text(
                            alertsText,
                            style: AppTextStyles.labelLarge(context).copyWith(
                              fontSize: 15,
                              color: alertCount > 0
                                  ? AppColors.ink
                                  : AppColors.muted,
                            ),
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
            ),
          ],
        ),
      ),
    );
  }
}

/// Weather strip individual metric column.
class _WeatherItem extends StatelessWidget {
  const _WeatherItem({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 24, color: iconColor),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Outfit',
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Outfit',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.muted,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
