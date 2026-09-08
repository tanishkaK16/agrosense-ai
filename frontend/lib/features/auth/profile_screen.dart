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
import 'data/app_auth_repository.dart';
import 'models/farmer_profile.dart';

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

/// Screen 3 of Auth: Short, icon-first farmer profile.
///
/// Collects:
/// 1. Name (optional, defaults to "Farmer")
/// 2. Village / Town (optional)
/// 3. Main Crop (single select, required to continue)
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _villageController = TextEditingController();

  String? _selectedCrop;
  bool _isSaving = false;

  @override
  void dispose() {
    VoiceService.instance.stop();
    _nameController.dispose();
    _villageController.dispose();
    super.dispose();
  }

  void _showSaveError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: 'Outfit',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.onPhoto,
          ),
        ),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        ),
        margin: const EdgeInsets.fromLTRB(
          AppSizes.paddingL,
          0,
          AppSizes.paddingL,
          AppSizes.paddingL,
        ),
      ),
    );
  }

  Future<void> _onSave() async {
    if (_selectedCrop == null || _isSaving) return;

    setState(() => _isSaving = true);
    await VoiceService.instance.stop();

    final enteredName = _nameController.text.trim();
    final profile = FarmerProfile(
      name: enteredName.isEmpty ? 'Farmer' : enteredName,
      village: _villageController.text.trim(),
      mainCrop: _selectedCrop!,
    );

    try {
      await AppAuthRepository.instance.saveProfile(profile);
      if (mounted) {
        context.go(AppRoutes.home);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isSaving = false);
        final l10n = AppLocalizations.of(context)!;
        _showSaveError(l10n.saveFailed);
        VoiceService.instance.speak(l10n.saveFailed);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final speechText =
        '${l10n.profileTitle}. ${l10n.nameQuestion}. ${l10n.villageQuestion}. ${l10n.cropQuestion}.';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Bar with Title and Listen button ────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.paddingL,
                AppSizes.paddingM,
                AppSizes.paddingL,
                AppSizes.paddingS,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      l10n.profileTitle,
                      style: AppTextStyles.screenTitle(context),
                    ),
                  ),
                  ListenButton(
                    onPhoto: false,
                    text: speechText,
                  ),
                ],
              ),
            ),

            // ── Form Content ────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.paddingL,
                  AppSizes.paddingS,
                  AppSizes.paddingL,
                  AppSizes.paddingXXL,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question 1: Name
                    Text(
                      l10n.nameQuestion,
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
                          hintText: l10n.nameHint,
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

                    // Question 2: Village / Town
                    Text(
                      l10n.villageQuestion,
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
                        controller: _villageController,
                        style: const TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                        decoration: InputDecoration(
                          hintText: l10n.villageHint,
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

                    // Question 3: Main Crop (Chips)
                    Text(
                      l10n.cropQuestion,
                      style: AppTextStyles.labelLarge(context),
                    ),
                    const SizedBox(height: 12),

                    // Crop Selection Grid
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
                                  // Circular crop thumbnail or icon
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.surfaceVariant
                                              .withValues(alpha: 0.5),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: crop.imagePath != null
                                        ? Image.asset(
                                            crop.imagePath!,
                                            fit: BoxFit.cover,
                                          )
                                        : Icon(
                                            crop.icon,
                                            size: 24,
                                            color: isSelected
                                                ? AppColors.surface
                                                : AppColors.primary,
                                          ),
                                  ),
                                  const SizedBox(height: 8),

                                  // Crop label
                                  Text(
                                    label,
                                    style: TextStyle(
                                      fontFamily: 'Outfit',
                                      fontSize: 13,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.ink,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: AppSizes.paddingXXL),

                    // Save and continue CTA
                    PrimaryPillButton(
                      label: _isSaving ? '...' : l10n.saveAndContinue,
                      enabled: _selectedCrop != null && !_isSaving,
                      onPressed: _onSave,
                      icon: Icons.check_circle_rounded,
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
