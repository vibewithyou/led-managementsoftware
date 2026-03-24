import 'package:flutter/material.dart';
import 'package:led_management_software/core/constants/app_spacing.dart';
import 'package:led_management_software/core/theme/app_colors.dart';
import 'package:led_management_software/core/theme/app_durations.dart';
import 'package:led_management_software/core/theme/app_radius.dart';
import 'package:led_management_software/domain/entities/playback_state.dart';
import 'package:led_management_software/domain/enums/playback_status.dart';
import 'package:led_management_software/shared/widgets/surfaces/status_badge.dart';

class NowPlayingPanel extends StatelessWidget {
  const NowPlayingPanel({required this.playbackState, required this.progress, super.key});

  final PlaybackState playbackState;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final cue = playbackState.currentCue;
    final statusText = cue?.isLocked == true ? 'locked' : playbackState.status.name;
    final statusColor = _statusColor(playbackState.status);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                cue?.title ?? 'Kein aktiver Clip',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            StatusBadge(label: statusText.toUpperCase(), type: _statusBadge(playbackState.status), compact: true),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          playbackState.transportMessage,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            _infoChip(context, icon: Icons.category_rounded, label: cue?.cueType.name ?? '—'),
            _infoChip(context, icon: Icons.bookmark_added_rounded, label: cue?.notes ?? '—'),
            _infoChip(context, icon: Icons.timer_rounded, label: 'Rest ${_formatMs(playbackState.remainingMs)}'),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _progressHeader(context, statusColor),
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
                      minHeight: 13,
                      value: value,
                      backgroundColor: AppColors.surfaceStrong,
                      valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            AnimatedSwitcher(
              duration: AppDurations.medium,
              child: Text(
                '${(progress.clamp(0, 1) * 100).toStringAsFixed(0)}%',
                key: ValueKey<int>((progress * 100).round()),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(color: statusColor, fontWeight: FontWeight.w700),
              ),
            ),
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
              border: Border.all(color: AppColors.error.withValues(alpha: 0.75)),
            ),
            child: Text(
              playbackState.lastError!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ],
    );
  }

  Widget _progressHeader(BuildContext context, Color statusColor) {
    return Row(
      children: [
        Text(
          'Playback-Fortschritt',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
        ),
        const Spacer(),
        Icon(Icons.circle, size: 8, color: statusColor),
      ],
    );
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
