import 'package:flutter/material.dart';
import 'package:led_management_software/core/constants/app_spacing.dart';
import 'package:led_management_software/core/theme/app_colors.dart';
import 'package:led_management_software/core/theme/app_durations.dart';
import 'package:led_management_software/core/theme/app_radius.dart';
import 'package:led_management_software/core/theme/app_shadows.dart';
import 'package:led_management_software/domain/entities/playback_state.dart';
import 'package:led_management_software/domain/enums/playback_status.dart';
import 'package:led_management_software/shared/widgets/surfaces/status_badge.dart';

class NowPlayingPanel extends StatelessWidget {
  const NowPlayingPanel({
    required this.playbackState,
    required this.progress,
    required this.fallbackCueLabel,
    super.key,
  });

  final PlaybackState playbackState;
  final double progress;
  final String fallbackCueLabel;

  @override
  Widget build(BuildContext context) {
    final cue = playbackState.currentCue;
    final cueTypeLabel = _cueTypeLabel(cue?.cueType.name);
    final isLocked = cue?.isLocked == true || playbackState.isLocked;
    final isBlack = playbackState.isBlackScreen || playbackState.status == PlaybackStatus.black;
    final isVlcStopped = playbackState.transportMessage.toLowerCase().contains('gestoppt');
    final sponsorLabel = _extractSponsorLabel(cue?.notes);
    final triggerSource = playbackState.lastAction?.name;
    final sourceLabel = cue?.mediaAssetId.isNotEmpty == true ? cue!.mediaAssetId : 'Keine Zuordnung';
    final statusColor = _statusColor(playbackState.status);
    final title = cue?.title ?? (isBlack ? 'Schwarzbild aktiv' : 'Keine laufende Ausspielung');
    final remainingLabel = _formatMs(playbackState.remainingMs);

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 320;
        final titleStyle = compact
            ? Theme.of(context).textTheme.headlineSmall
            : Theme.of(context).textTheme.displaySmall;

        return Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: isBlack
                  ? AppColors.disabled
                  : isLocked
                      ? AppColors.error.withValues(alpha: 0.8)
                      : AppColors.borderStrong,
            ),
            boxShadow: isBlack
                ? AppShadows.panel
                : AppShadows.glow(
                    isLocked ? AppColors.error : statusColor,
                  ),
          ),
          child: Padding(
            padding: EdgeInsets.all(compact ? AppSpacing.md : AppSpacing.mdLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    isBlack ? 'SCHWARZBILD AKTIV' : 'AKTUELLE AUSSPIELUNG',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.textMuted,
                          letterSpacing: 0.7,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: titleStyle?.copyWith(fontWeight: FontWeight.w800, height: 1.08),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            _statusHeadline(playbackState.status, isLocked: isLocked, isBlack: isBlack),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: statusColor,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    _remainingBlock(context, remainingLabel, statusColor),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: [
                    _chip(context, cueTypeLabel, _statusBadge(playbackState.status)),
                    _chip(context, _playbackStatusLabel(playbackState.status), _statusBadge(playbackState.status)),
                    if (isLocked) _chip(context, 'SPERRCLIP AKTIV', StatusBadgeType.locked),
                    if (sponsorLabel != null) _chip(context, 'SPOT: $sponsorLabel', StatusBadgeType.hover),
                    if (isBlack) _chip(context, 'SCHWARZBILD', StatusBadgeType.disabled),
                    if (isVlcStopped) _chip(context, 'PLAYER ANGEHALTEN', StatusBadgeType.disabled),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Clip-Fortschritt',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Expanded(
                      child: TweenAnimationBuilder<double>(
                        duration: AppDurations.medium,
                        tween: Tween(begin: 0, end: progress.clamp(0, 1)),
                        builder: (context, value, _) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                            child: LinearProgressIndicator(
                              minHeight: compact ? 14 : 18,
                              value: value,
                              backgroundColor: AppColors.surfaceStrong,
                              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      '${(progress.clamp(0, 1) * 100).toStringAsFixed(0)}%',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: statusColor, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.xs,
                  children: <Widget>[
                    _metaCard(context, 'Quelle', sourceLabel),
                    _metaCard(context, 'Danach', fallbackCueLabel),
                    if (triggerSource != null) _metaCard(context, 'Auslöser', _triggerLabel(triggerSource)),
                  ],
                ),
                if ((playbackState.lastError ?? '').isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(color: AppColors.error.withValues(alpha: 0.65)),
                    ),
                    child: Text(
                      'Hinweis: ${playbackState.lastError!}',
                      maxLines: compact ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.error),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _remainingBlock(BuildContext context, String remainingLabel, Color statusColor) {
    return Container(
      constraints: const BoxConstraints(minWidth: 118),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: statusColor.withValues(alpha: 0.65)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'REST',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textMuted, letterSpacing: 0.5),
          ),
          Text(
            remainingLabel,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: statusColor, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  Widget _chip(BuildContext context, String label, StatusBadgeType type) {
    return StatusBadge(label: label, type: type, compact: true);
  }

  Widget _metaLine(BuildContext context, String label, String value) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 160, maxWidth: 360),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: AppSpacing.nano),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _metaCard(BuildContext context, String label, String value) {
    return Container(
      constraints: const BoxConstraints(minWidth: 160, maxWidth: 280),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.border),
      ),
      child: _metaLine(context, label, value),
    );
  }

  String? _extractSponsorLabel(String? notes) {
    final value = notes?.trim();
    if (value == null || value.isEmpty) {
      return null;
    }
    if (value.toLowerCase() == 'sponsor loop') {
      return 'Sponsor Loop';
    }
    return value;
  }

  String _cueTypeLabel(String? value) {
    switch ((value ?? '').trim().toLowerCase()) {
      case 'lockedsponsor':
        return 'SPONSOR';
      case 'fallback':
        return 'AUTOMATIK';
      case 'game':
        return 'SPIEL';
      case 'intro':
        return 'INTRO';
      case 'black':
        return 'SCHWARZ';
      case 'idle':
      case '':
        return 'BEREIT';
      default:
        return value!.toUpperCase();
    }
  }

  String _playbackStatusLabel(PlaybackStatus status) {
    return switch (status) {
      PlaybackStatus.idle => 'BEREIT',
      PlaybackStatus.playing => 'LIVE',
      PlaybackStatus.locked => 'GESPERRT',
      PlaybackStatus.queued => 'VORGEMERKT',
      PlaybackStatus.black => 'SCHWARZBILD',
    };
  }

  String _triggerLabel(String triggerSource) {
    switch (triggerSource.trim()) {
      case 'triggerCue':
        return 'Regietaste';
      case 'stopCue':
        return 'Stopp';
      case 'blackScreenOn':
        return 'Sofort Schwarz';
      default:
        return triggerSource;
    }
  }

  String _statusHeadline(PlaybackStatus status, {required bool isLocked, required bool isBlack}) {
    if (isBlack) {
      return 'Ausgabe ist auf Schwarz geschaltet';
    }
    if (isLocked) {
      return 'Sperrclip blockiert neue Starts bis Clip-Ende';
    }

    return switch (status) {
      PlaybackStatus.idle => 'System wartet auf den nächsten Start',
      PlaybackStatus.playing => 'Beitrag läuft aktuell auf der Bande',
      PlaybackStatus.locked => 'Sperrclip aktiv',
      PlaybackStatus.queued => 'Nächster Beitrag ist vorgemerkt',
      PlaybackStatus.black => 'Schwarzbild aktiv',
    };
  }

  Widget _infoChip(BuildContext context, {required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: AppSpacing.xxs),
      decoration: BoxDecoration(
        color: AppColors.surfaceStrong.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textMuted),
          const SizedBox(width: AppSpacing.xxs),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Color _statusColor(PlaybackStatus status) {
    return switch (status) {
      PlaybackStatus.idle => AppColors.success,
      PlaybackStatus.playing => AppColors.secondary,
      PlaybackStatus.locked => AppColors.error,
      PlaybackStatus.queued => AppColors.warning,
      PlaybackStatus.black => AppColors.disabled,
    };
  }

  StatusBadgeType _statusBadge(PlaybackStatus status) {
    return switch (status) {
      PlaybackStatus.idle => StatusBadgeType.ready,
      PlaybackStatus.playing => StatusBadgeType.active,
      PlaybackStatus.locked => StatusBadgeType.locked,
      PlaybackStatus.queued => StatusBadgeType.queued,
      PlaybackStatus.black => StatusBadgeType.disabled,
    };
  }

  String _formatMs(int milliseconds) {
    final totalSeconds = (milliseconds / 1000).ceil();
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
