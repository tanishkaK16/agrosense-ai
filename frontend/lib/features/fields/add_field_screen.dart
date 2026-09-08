import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/routing/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/voice/voice_service.dart';
import '../../core/widgets/listen_button.dart';
import '../../core/widgets/primary_pill_button.dart';
import '../../generated/l10n/app_localizations.dart';
import '../auth/data/mock_auth_repository.dart';

class _CropOption {
  const _CropOption({
    required this.id,
    required this.getLabel,
    required this.icon,
    this.imagePath,
  });

  final String id;
  final String Function(AppLocalizations) getLabel;
  final IconData icon;
  final String? imagePath;
}

final List<_CropOption> _kCropOptions = [
  _CropOption(
    id: 'wheat',
    getLabel: (l10n) => l10n.cropWheat,
    icon: Icons.grain_rounded,
    imagePath: 'assets/images/hero_wheat_closeup.jpg',
  ),
  _CropOption(
    id: 'rice',
    getLabel: (l10n) => l10n.cropRice,
    icon: Icons.grass_rounded,
  ),
  _CropOption(
    id: 'cotton',
    getLabel: (l10n) => l10n.cropCotton,
    icon: Icons.spa_rounded,
  ),
  _CropOption(
    id: 'sugarcane',
    getLabel: (l10n) => l10n.cropSugarcane,
    icon: Icons.forest_rounded,
  ),
  _CropOption(
    id: 'soybean',
    getLabel: (l10n) => l10n.cropSoybean,
    icon: Icons.eco_rounded,
  ),
  _CropOption(
    id: 'other',
    getLabel: (l10n) => l10n.cropOther,
    icon: Icons.agriculture_rounded,
  ),
];

/// Step 1 of Add Field: Name (optional, defaults to "Main field") + Crop selection.
class AddFieldScreen extends StatefulWidget {
  const AddFieldScreen({
    super.key,
    this.initialName,
    this.initialCrop,
  });

  final String? initialName;
  final String? initialCrop;

  @override
  State<AddFieldScreen> createState() => _AddFieldScreenState();
}

class _AddFieldScreenState extends State<AddFieldScreen> {
  late final TextEditingController _nameController;
  String? _selectedCrop;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');

    // Preselect crop: widget prop > farmer profile main crop > default wheat
    if (widget.initialCrop != null && widget.initialCrop!.isNotEmpty) {
      _selectedCrop = widget.initialCrop;
    } else {
      final profileCrop =
          MockAuthRepository.instance.currentProfile()?.mainCrop;
      if (profileCrop != null && profileCrop.isNotEmpty) {
        _selectedCrop = profileCrop.toLowerCase();
      } else {
        _selectedCrop = 'wheat';
      }
    }
  }

  @override
  void dispose() {
    VoiceService.instance.stop();
    _nameController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_selectedCrop == null) return;
    VoiceService.instance.stop();

    final enteredName = _nameController.text.trim();
    final effectiveName = enteredName.isEmpty ? 'Main field' : enteredName;

    context.push(
      '/fields/pin',
      extra: {
        'name': effectiveName,
        'crop': _selectedCrop!,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final topPad = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Top Bar with Back, Title, and Listen Button ─────────────
            Padding(
              padding: EdgeInsets.only(
                top: topPad > 0 ? 0 : AppSizes.paddingM,
                left: AppSizes.paddingS,
                right: AppSizes.paddingM,
                bottom: AppSizes.paddingS,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.ink,
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
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      l10n.addField,
                      style: AppTextStyles.screenTitle(context),
                    ),
                  ),
                  ListenButton(
                    text: l10n.addFieldStep1Speech,
                  ),
                ],
              ),
            ),

            // ── Scrollable Form Area ─────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.paddingL,
                  AppSizes.paddingM,
                  AppSizes.paddingL,
                  AppSizes.navBarHeight + AppSizes.navBarBottomMargin + 90,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Field Name Section
                    Text(
                      l10n.fieldNameLabel,
                      style: AppTextStyles.labelLarge(context),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius:
                            BorderRadius.circular(AppSizes.radiusMedium),
                        boxShadow: AppShadows.soft,
                        border: Border.all(color: AppColors.surfaceVariant),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _nameController,
                        style: const TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                        decoration: InputDecoration(
                          hintText: l10n.fieldNameHint,
                          hintStyle: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 15,
                            color: AppColors.muted.withValues(alpha: 0.6),
                          ),
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSizes.paddingXL),

                    // Crop Selection Section
                    Text(
                      l10n.selectCropQuestion,
                      style: AppTextStyles.labelLarge(context),
                    ),
                    const SizedBox(height: 12),

                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _kCropOptions.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.95,
                      ),
                      itemBuilder: (context, index) {
                        final crop = _kCropOptions[index];
                        final isSelected = _selectedCrop == crop.id;
                        final label = crop.getLabel(l10n);

                        return Semantics(
                          label: label,
                          selected: isSelected,
                          button: true,
                          child: InkWell(
                            onTap: () {
                              setState(() => _selectedCrop = crop.id);
                            },
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusLarge),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeInOut,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.healthyContainer
                                    : AppColors.surface,
                                borderRadius: BorderRadius.circular(
                                  AppSizes.radiusLarge,
                                ),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.surfaceVariant,
                                  width: isSelected ? 2.5 : 1.5,
                                ),
                                boxShadow: isSelected
                                    ? AppShadows.medium
                                    : AppShadows.soft,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 10,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.background,
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: crop.imagePath != null
                                        ? Image.asset(
                                            crop.imagePath!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Icon(
                                              crop.icon,
                                              size: 22,
                                              color: isSelected
                                                  ? AppColors.onPhoto
                                                  : AppColors.primary,
                                            ),
                                          )
                                        : Icon(
                                            crop.icon,
                                            size: 22,
                                            color: isSelected
                                                ? AppColors.onPhoto
                                                : AppColors.primary,
                                          ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    label,
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: 'Outfit',
                                      fontSize: 13,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w600,
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.ink,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.fromLTRB(
          AppSizes.paddingL,
          AppSizes.paddingS,
          AppSizes.paddingL,
          AppSizes.navBarHeight + AppSizes.navBarBottomMargin + 12,
        ),
        child: PrimaryPillButton(
          label: l10n.next,
          icon: Icons.arrow_forward_rounded,
          enabled: _selectedCrop != null,
          onPressed: _onNext,
        ),
      ),
    );
  }
}
