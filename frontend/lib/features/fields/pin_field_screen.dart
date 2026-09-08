import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart' hide Path;

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
import '../home/models/home_snapshot.dart';
import 'data/local_fields_repository.dart';
import 'models/farm_field.dart';

/// Default coordinates centered on Pune, Maharashtra.
const LatLng _kDefaultLocation = LatLng(18.5204, 73.8567);

/// Step 2 of Add Field: Map with a single pin to locate the field.
class PinFieldScreen extends StatefulWidget {
  const PinFieldScreen({
    super.key,
    this.draftName,
    this.draftCrop,
  });

  final String? draftName;
  final String? draftCrop;

  @override
  State<PinFieldScreen> createState() => _PinFieldScreenState();
}

class _PinFieldScreenState extends State<PinFieldScreen> {
  final MapController _mapController = MapController();
  LatLng _pinPosition = _kDefaultLocation;
  bool _isSaving = false;
  bool _isLocating = false;

  @override
  void initState() {
    super.initState();
    // Try GPS on first open without blocking the user.
    _initLocation();
  }

  @override
  void dispose() {
    VoiceService.instance.stop();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _initLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 4),
          ),
        );

        if (mounted) {
          final newPos = LatLng(position.latitude, position.longitude);
          setState(() {
            _pinPosition = newPos;
          });
          _mapController.move(newPos, 14.0);
        }
      }
    } catch (_) {
      // Quiet fallback to default Maharashtra coordinates
    }
  }

  Future<void> _useMyLocation() async {
    if (_isLocating) return;
    setState(() => _isLocating = true);

    final l10n = AppLocalizations.of(context)!;

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showCalmNotice(l10n.locationDeniedNotice);
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _showCalmNotice(l10n.locationDeniedNotice);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 6),
        ),
      );

      if (mounted) {
        final newPos = LatLng(position.latitude, position.longitude);
        setState(() {
          _pinPosition = newPos;
        });
        _mapController.move(newPos, 15.0);
      }
    } catch (_) {
      if (mounted) {
        _showCalmNotice(l10n.locationDeniedNotice);
      }
    } finally {
      if (mounted) {
        setState(() => _isLocating = false);
      }
    }
  }

  void _showCalmNotice(String message) {
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
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        ),
        margin: const EdgeInsets.fromLTRB(
          AppSizes.paddingL,
          0,
          AppSizes.paddingL,
          AppSizes.navBarHeight + AppSizes.navBarBottomMargin + 80,
        ),
      ),
    );
  }

  Future<void> _onSave() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    await VoiceService.instance.stop();

    final profile = MockAuthRepository.instance.currentProfile();
    final name = (widget.draftName != null && widget.draftName!.trim().isNotEmpty)
        ? widget.draftName!.trim()
        : 'Main field';
    final crop = (widget.draftCrop != null && widget.draftCrop!.trim().isNotEmpty)
        ? widget.draftCrop!.trim().toLowerCase()
        : 'wheat';

    final field = FarmField(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      crop: crop,
      latitude: _pinPosition.latitude,
      longitude: _pinPosition.longitude,
      photoAsset: photoAssetForCrop(crop),
      village: profile?.village,
      health: FieldHealth.healthy,
    );

    await LocalFieldsRepository.instance.saveField(field);

    if (mounted) {
      context.go(AppRoutes.fields);
    }
  }

  Widget _buildCustomPin() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.wheat,
              width: 3.5,
            ),
            boxShadow: AppShadows.medium,
          ),
          child: const Center(
            child: Icon(
              Icons.agriculture_rounded,
              color: AppColors.onPhoto,
              size: 26,
            ),
          ),
        ),
        // Arrow tip pointing at the map coordinate
        const CustomPaint(
          size: Size(14, 10),
          painter: _PinTipPainter(color: AppColors.primary),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final topPad = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── The Map Layer ───────────────────────────────────────────
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _pinPosition,
                initialZoom: 13.0,
                minZoom: 3.0,
                maxZoom: 18.0,
                onTap: (tapPosition, point) {
                  setState(() => _pinPosition = point);
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.agrosense_ai',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _pinPosition,
                      width: 54,
                      height: 62,
                      alignment: Alignment.topCenter,
                      child: _buildCustomPin(),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Top Header & Instruction Pill ───────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.only(
                  top: topPad > 0 ? 0 : AppSizes.paddingS,
                  left: AppSizes.paddingS,
                  right: AppSizes.paddingM,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface.withValues(alpha: 0.95),
                            shape: BoxShape.circle,
                            boxShadow: AppShadows.soft,
                          ),
                          child: IconButton(
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
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.paddingM,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surface.withValues(alpha: 0.95),
                              borderRadius:
                                  BorderRadius.circular(AppSizes.radiusPill),
                              boxShadow: AppShadows.soft,
                            ),
                            child: Text(
                              l10n.tapYourField,
                              style: AppTextStyles.labelLarge(context),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface.withValues(alpha: 0.95),
                            shape: BoxShape.circle,
                            boxShadow: AppShadows.soft,
                          ),
                          child: ListenButton(
                            text: l10n.addFieldStep2Speech,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Farmer-plain instruction banner
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.paddingM,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withValues(alpha: 0.95),
                        borderRadius:
                            BorderRadius.circular(AppSizes.radiusMedium),
                        boxShadow: AppShadows.soft,
                        border: Border.all(
                          color: AppColors.wheat.withValues(alpha: 0.7),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.touch_app_rounded,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              l10n.tapMapInstruction,
                              style: const TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.ink,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Lower Third Controls (Above Floating Nav) ───────────────
          Positioned(
            left: AppSizes.paddingL,
            right: AppSizes.paddingL,
            bottom: AppSizes.navBarHeight + AppSizes.navBarBottomMargin + 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // "Use my location" button
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                    boxShadow: AppShadows.medium,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _isLocating ? null : _useMyLocation,
                      borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.paddingL,
                          vertical: 14,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_isLocating)
                              const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.primary,
                                  ),
                                ),
                              )
                            else
                              const Icon(
                                Icons.my_location_rounded,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            const SizedBox(width: 8),
                            Text(
                              l10n.useMyLocation,
                              style: const TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // "Save field" primary button
                PrimaryPillButton(
                  label: l10n.saveField,
                  icon: Icons.check_circle_outline_rounded,
                  enabled: !_isSaving,
                  onPressed: _onSave,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for the downward arrow tip of the pin.
class _PinTipPainter extends CustomPainter {
  const _PinTipPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _PinTipPainter oldDelegate) =>
      color != oldDelegate.color;
}
