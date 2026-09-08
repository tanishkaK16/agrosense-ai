import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/alerts/data/app_alerts_repository.dart';
import '../../features/fields/data/app_field_status_repository.dart';
import '../../features/fields/data/app_fields_repository.dart';
import '../../features/fields/models/field_status.dart';
import '../../generated/l10n/app_localizations.dart';
import '../constants/app_sizes.dart';
import '../routing/app_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';
import 'voice_command_parser.dart';
import 'voice_service.dart';

/// Presentation and feedback overlays for farmer voice interactions (Phase 7).
///
/// Contains:
/// - Bottom sheet for listening with active audio pulse and stop button
/// - High-contrast editorial cream feedback banner (2 lines max, auto-hide)
/// - Handler dispatching recognized voice commands to navigation or spoken telemetry
class VoiceOverlay {
  const VoiceOverlay._();

  /// Displays the "Listening..." bottom sheet, listens for speech, and executes the recognized command.
  static Future<void> startListeningFlow(
    BuildContext context, {
    String? currentListenText,
  }) async {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return;

    // Show listening bottom sheet
    final transcript = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => _VoiceListeningSheet(
        onResultRecorded: (text) {
          if (sheetContext.mounted) {
            Navigator.of(sheetContext).pop(text);
          }
        },
      ),
    );

    if (!context.mounted) return;

    if (transcript == null || transcript.trim().isEmpty) {
      // Empty or cancelled: speak gentle guidance
      final msg = l10n.voiceNotUnderstood;
      showFeedbackBanner(
        context,
        recognizedText: '',
        actionDescription: msg,
      );
      VoiceService.instance.speak(msg);
      return;
    }

    final parsed = VoiceCommandParser.parse(transcript);
    await handleVoiceCommand(
      context,
      result: parsed,
      currentListenText: currentListenText,
    );
  }

  /// Execute a parsed [VoiceCommandResult].
  static Future<void> handleVoiceCommand(
    BuildContext context, {
    required VoiceCommandResult result,
    String? currentListenText,
  }) async {
    final l10n = AppLocalizations.of(context);
    if (l10n == null || !context.mounted) return;

    switch (result.action) {
      case VoiceActionType.navigateHome:
        final actionText = l10n.voiceOpeningHome;
        showFeedbackBanner(
          context,
          recognizedText: result.rawTranscript,
          actionDescription: actionText,
        );
        VoiceService.instance.speak(actionText);
        context.go(AppRoutes.home);
        break;

      case VoiceActionType.navigateFields:
        final actionText = l10n.voiceOpeningFields;
        showFeedbackBanner(
          context,
          recognizedText: result.rawTranscript,
          actionDescription: actionText,
        );
        VoiceService.instance.speak(actionText);
        context.go(AppRoutes.fields);
        break;

      case VoiceActionType.navigateAlerts:
        final actionText = l10n.voiceOpeningAlerts;
        showFeedbackBanner(
          context,
          recognizedText: result.rawTranscript,
          actionDescription: actionText,
        );
        VoiceService.instance.speak(actionText);
        context.go(AppRoutes.alerts);
        break;

      case VoiceActionType.openSmsInfo:
        final actionText = l10n.voiceOpeningSmsInfo;
        showFeedbackBanner(
          context,
          recognizedText: result.rawTranscript,
          actionDescription: actionText,
        );
        VoiceService.instance.speak(actionText);
        context.push(AppRoutes.smsInfo);
        break;

      case VoiceActionType.triggerListen:
        if (currentListenText != null && currentListenText.trim().isNotEmpty) {
          showFeedbackBanner(
            context,
            recognizedText: result.rawTranscript,
            actionDescription: l10n.voiceReadingScreen,
          );
          VoiceService.instance.speak(currentListenText);
        } else {
          final msg = l10n.voiceHelpPrompt;
          showFeedbackBanner(
            context,
            recognizedText: result.rawTranscript,
            actionDescription: msg,
          );
          VoiceService.instance.speak(msg);
        }
        break;

      case VoiceActionType.whatToDo:
        final alerts = await AppAlertsRepository.instance.getAlerts();
        if (!context.mounted) return;

        if (alerts.isEmpty) {
          final msg = l10n.voiceNoAlerts;
          showFeedbackBanner(
            context,
            recognizedText: result.rawTranscript,
            actionDescription: msg,
          );
          VoiceService.instance.speak(msg);
        } else {
          final targetAlert =
              alerts.where((a) => !a.seen).firstOrNull ?? alerts.first;
          final fields = await AppFieldsRepository.instance.getFields();
          if (!context.mounted) return;

          final fieldName = fields
                  .where((f) => f.id == targetAlert.fieldId)
                  .firstOrNull
                  ?.name ??
              l10n.fieldNameHint;

          final actionText = l10n.voiceOpeningAlertDetail(fieldName);
          showFeedbackBanner(
            context,
            recognizedText: result.rawTranscript,
            actionDescription: actionText,
          );
          VoiceService.instance.speak(actionText);
          context.push('/alerts/${targetAlert.id}');
        }
        break;

      case VoiceActionType.statusWater:
      case VoiceActionType.statusPest:
      case VoiceActionType.statusHealth:
        final fields = await AppFieldsRepository.instance.getFields();
        if (!context.mounted) return;

        if (fields.isEmpty) {
          final msg = l10n.voiceNoFields;
          showFeedbackBanner(
            context,
            recognizedText: result.rawTranscript,
            actionDescription: msg,
          );
          VoiceService.instance.speak(msg);
        } else {
          final firstField = fields.first;
          final status = await AppFieldStatusRepository.instance
              .getFieldStatus(firstField.id);

          String report;
          if (result.action == VoiceActionType.statusWater) {
            final wLevel = status.water == WaterLevel.actNow
                ? l10n.danger
                : (status.water == WaterLevel.low
                    ? l10n.statusLow
                    : l10n.statusOkay);
            report = l10n.voiceStatusWaterReport(firstField.name, wLevel);
          } else if (result.action == VoiceActionType.statusPest) {
            final pLevel = status.pest == PestLevel.actNow
                ? l10n.danger
                : (status.pest == PestLevel.watch
                    ? l10n.statusRisk
                    : l10n.good);
            report = l10n.voiceStatusPestReport(firstField.name, pLevel);
          } else {
            final hLevel = status.health == HealthLevel.actNow
                ? l10n.danger
                : (status.health == HealthLevel.watch
                    ? l10n.warning
                    : l10n.good);
            report = l10n.voiceStatusHealthReport(firstField.name, hLevel);
          }

          if (context.mounted) {
            showFeedbackBanner(
              context,
              recognizedText: result.rawTranscript,
              actionDescription: report,
            );
            VoiceService.instance.speak(report);
          }
        }
        break;

      case VoiceActionType.help:
        final msg = l10n.voiceHelpPrompt;
        showFeedbackBanner(
          context,
          recognizedText: result.rawTranscript,
          actionDescription: msg,
        );
        VoiceService.instance.speak(msg);
        break;

      case VoiceActionType.unknown:
        final msg = l10n.voiceNotUnderstood;
        showFeedbackBanner(
          context,
          recognizedText: result.rawTranscript,
          actionDescription: msg,
        );
        VoiceService.instance.speak(msg);
        break;
    }
  }

  /// Display a small cream floating banner with recognized words and action taken.
  /// Auto-hides after ~3.5 seconds.
  static void showFeedbackBanner(
    BuildContext context, {
    required String recognizedText,
    required String actionDescription,
  }) {
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => _FeedbackBannerWidget(
        recognizedText: recognizedText,
        actionDescription: actionDescription,
        onDismiss: () {
          if (entry.mounted) {
            entry.remove();
          }
        },
      ),
    );

    overlay.insert(entry);
  }
}

/// Modal bottom sheet active while listening for farmer speech.
class _VoiceListeningSheet extends StatefulWidget {
  const _VoiceListeningSheet({
    required this.onResultRecorded,
  });

  final ValueChanged<String> onResultRecorded;

  @override
  State<_VoiceListeningSheet> createState() => _VoiceListeningSheetState();
}

class _VoiceListeningSheetState extends State<_VoiceListeningSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  String _recognizedText = '';
  Timer? _silenceTimer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.94, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _startListening();
  }

  @override
  void dispose() {
    _silenceTimer?.cancel();
    _pulseController.dispose();
    VoiceService.instance.stopListening();
    super.dispose();
  }

  Future<void> _startListening() async {
    final started = await VoiceService.instance.startListening(
      onResult: (words, isFinal) {
        if (mounted) {
          setState(() {
            _recognizedText = words;
          });
        }
        if (isFinal && words.trim().isNotEmpty) {
          widget.onResultRecorded(words);
        }
      },
      onError: (_) {
        // Safe fallback if speech engine fails
        _stopAndReturn();
      },
    );

    if (!started && mounted) {
      final l10n = AppLocalizations.of(context);
      if (l10n != null) {
        VoiceOverlay.showFeedbackBanner(
          context,
          recognizedText: '',
          actionDescription: l10n.voicePermissionDenied,
        );
      }
      Navigator.of(context).pop();
      return;
    }

    // Auto-timeout after ~4 seconds
    _silenceTimer = Timer(const Duration(milliseconds: 4200), () {
      _stopAndReturn();
    });
  }

  void _stopAndReturn() {
    _silenceTimer?.cancel();
    VoiceService.instance.stopListening();
    widget.onResultRecorded(_recognizedText);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bottomPad = MediaQuery.paddingOf(context).bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSizes.paddingXL,
        AppSizes.paddingL,
        AppSizes.paddingXL,
        bottomPad > 0 ? bottomPad + AppSizes.paddingL : AppSizes.paddingXXL,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppSizes.paddingXL),

          // Pulsing mic circle
          ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.12),
                border: Border.all(
                  color: AppColors.primary,
                  width: 2.5,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.mic_rounded,
                  size: 46,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.paddingL),

          // Listening text
          Text(
            l10n.voiceListening,
            style: const TextStyle(
              fontFamily: 'Fraunces',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 8),

          // Real-time recognized text preview
          Text(
            _recognizedText.isNotEmpty
                ? '“$_recognizedText”'
                : l10n.voiceHelpPrompt,
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: _recognizedText.isNotEmpty
                  ? AppColors.primary
                  : AppColors.muted,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSizes.paddingXL),

          // Stop button (large 64 tap target)
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton.icon(
              onPressed: _stopAndReturn,
              icon: const Icon(
                Icons.stop_circle_rounded,
                size: 24,
                color: AppColors.ink,
              ),
              label: Text(
                l10n.voiceStop,
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.surfaceVariant,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Floating feedback banner with recognized text and resulting action.
class _FeedbackBannerWidget extends StatefulWidget {
  const _FeedbackBannerWidget({
    required this.recognizedText,
    required this.actionDescription,
    required this.onDismiss,
  });

  final String recognizedText;
  final String actionDescription;
  final VoidCallback onDismiss;

  @override
  State<_FeedbackBannerWidget> createState() => _FeedbackBannerWidgetState();
}

class _FeedbackBannerWidgetState extends State<_FeedbackBannerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();

    // Auto hide after 3.5 seconds
    _hideTimer = Timer(const Duration(milliseconds: 3500), () {
      if (mounted) {
        _controller.reverse().then((_) => widget.onDismiss());
      }
    });
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.paddingOf(context).top;

    return Positioned(
      top: topPad + 12,
      left: AppSizes.paddingL,
      right: AppSizes.paddingL,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingL,
                vertical: AppSizes.paddingM,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                border: Border.all(
                  color: AppColors.primarySoft.withValues(alpha: 0.4),
                  width: 1.5,
                ),
                boxShadow: AppShadows.medium,
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      color: AppColors.healthyContainer,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.record_voice_over_rounded,
                      size: 20,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.recognizedText.isNotEmpty)
                          Text(
                            '“${widget.recognizedText}”',
                            style: const TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.muted,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        Text(
                          widget.actionDescription,
                          style: const TextStyle(
                            fontFamily: 'Fraunces',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                            height: 1.25,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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
    );
  }
}
