import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/voice/mic_button.dart';
import '../../core/widgets/listen_button.dart';
import '../../core/widgets/primary_pill_button.dart';
import '../../generated/l10n/app_localizations.dart';
import '../home/models/home_snapshot.dart';
import 'data/app_fields_repository.dart';
import 'models/farm_field.dart';

/// My Fields Screen — Phase 4.
///
/// Features:
/// - List of farmer's fields displayed as large photo cards
/// - Real crop photos and health indicator pills
/// - Empty state with themed field mark and CTA if 0 fields
/// - Trailing Listen button reading field count or empty state speech
/// - Big Add field control above floating navigation pill
class FieldsScreen extends StatefulWidget {
  const FieldsScreen({super.key});

  @override
  State<FieldsScreen> createState() => _FieldsScreenState();
}

class _FieldsScreenState extends State<FieldsScreen> {
  List<FarmField> _fields = const [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFields();
    AppFieldsRepository.instance.addListener(_onRepositoryUpdate);
  }

  @override
  void dispose() {
    AppFieldsRepository.instance.removeListener(_onRepositoryUpdate);
    super.dispose();
  }

  void _onRepositoryUpdate() {
    _loadFields();
  }

  Future<void> _loadFields() async {
    final list = await AppFieldsRepository.instance.getFields();
    if (mounted) {
      setState(() {
        _fields = list;
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

  String _getHealthLabel(FieldHealth? health, AppLocalizations l10n) {
    switch (health) {
      case FieldHealth.healthy:
        return l10n.healthyStatus;
      case FieldHealth.watch:
        return l10n.watchStatus;
      case FieldHealth.actNow:
        return l10n.actNowStatus;
      case null:
        return '';
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final topPad = MediaQuery.paddingOf(context).top;

    final speechText = _fields.isEmpty
        ? l10n.fieldsEmptySpeech
        : l10n.fieldsCount(_fields.length);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── App bar row ──────────────────────────────────────────
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
                      l10n.myFields,
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
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    )
                  : _fields.isEmpty
                      ? _buildEmptyState(context, l10n)
                      : _buildFieldsList(context, l10n),
            ),
          ],
        ),
      ),
      // If there are fields, floating Add field button above floating nav bar
      bottomSheet: _fields.isEmpty
          ? null
          : Container(
              color: Colors.transparent,
              padding: const EdgeInsets.fromLTRB(
                AppSizes.paddingL,
                AppSizes.paddingS,
                AppSizes.paddingL,
                AppSizes.navBarHeight + AppSizes.navBarBottomMargin + 12,
              ),
              child: PrimaryPillButton(
                label: l10n.addField,
                icon: Icons.add_rounded,
                onPressed: () => context.push('/fields/add'),
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
              // Large themed field mark (no emoji)
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: AppColors.healthyContainer,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.agriculture_rounded,
                    size: 42,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.paddingL),

              Text(
                l10n.noFieldsYet,
                style: AppTextStyles.labelLarge(context),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              Text(
                l10n.addFirstField,
                style: AppTextStyles.caption(context),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.paddingXL),

              PrimaryPillButton(
                label: l10n.addField,
                icon: Icons.add_rounded,
                onPressed: () => context.push('/fields/add'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldsList(BuildContext context, AppLocalizations l10n) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.paddingL,
        AppSizes.paddingM,
        AppSizes.paddingL,
        AppSizes.navBarHeight + AppSizes.navBarBottomMargin + 90,
      ),
      itemCount: _fields.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSizes.paddingL),
      itemBuilder: (context, index) {
        final field = _fields[index];
        return _buildFieldCard(context, field, l10n);
      },
    );
  }

  Widget _buildFieldCard(
    BuildContext context,
    FarmField field,
    AppLocalizations l10n,
  ) {
    final cropLabel = _getCropName(field.crop, l10n);
    final health = field.health;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/fields/${field.id}'),
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
            boxShadow: AppShadows.medium,
            border: Border.all(color: AppColors.surfaceVariant),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          // Crop photo with gradient scrim and status pill
          SizedBox(
            height: 160,
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
                        size: 48,
                        color: AppColors.onPhoto,
                      ),
                    ),
                  ),
                ),
                // Soft gradient overlay at top and bottom of photo
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.35),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.45),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),

                // Health status pill in top right corner (if mock health exists)
                if (health != null)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: _getHealthBgColor(health),
                        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                        boxShadow: AppShadows.soft,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _getHealthColor(health),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _getHealthLabel(health, l10n),
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _getHealthColor(health),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Field details
          Padding(
            padding: const EdgeInsets.all(AppSizes.paddingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  field.name,
                  style: const TextStyle(
                    fontFamily: 'Fraunces',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius:
                            BorderRadius.circular(AppSizes.radiusSmall),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.eco_rounded,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            cropLabel,
                            style: const TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (field.village != null &&
                        field.village!.trim().isNotEmpty) ...[
                      const SizedBox(width: 10),
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: AppColors.muted,
                            ),
                            const SizedBox(width: 2),
                            Flexible(
                              child: Text(
                                field.village!.trim(),
                                style: AppTextStyles.caption(context),
                                overflow: TextOverflow.ellipsis,
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
    ),
    ),
    );
  }
}
