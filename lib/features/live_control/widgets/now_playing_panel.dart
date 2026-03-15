import 'package:flutter/material.dart';
import 'package:led_management_software/core/constants/app_spacing.dart';
import 'package:led_management_software/core/theme/app_colors.dart';
import 'package:led_management_software/domain/entities/playback_state.dart';
import 'package:led_management_software/domain/enums/playback_status.dart';

class NowPlayingPanel extends StatelessWidget {
  const NowPlayingPanel({required this.playbackState, required this.progress, super.key});

  final PlaybackState playbackState;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final cue = playbackState.currentCue;
    final statusText = playbackState.status.name;
    final statusColor = switch (playbackState.status) {
      PlaybackStatus.idle => AppColors.success,
      PlaybackStatus.playing => AppColors.primary,
      PlaybackStatus.locked => AppColors.error,
      PlaybackStatus.queued => AppColors.warning,
      PlaybackStatus.black => AppColors.disabled,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _line(context, 'Titel', cue?.title ?? '—'),
        _line(context, 'Kategorie', cue?.cueType.name ?? '—'),
        _line(context, 'Sponsor', cue?.notes ?? '—'),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            const Text('Status:'),
            const SizedBox(width: AppSpacing.xs),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.15),
                border: Border.all(color: statusColor),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                cue?.isLocked == true ? 'locked' : statusText,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: statusColor),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 240),
          tween: Tween(begin: 0, end: progress),
          builder: (context, value, _) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: 12,
                value: value,
                backgroundColor: AppColors.surfaceStrong,
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              ),
            );
          },
        ),
        const SizedBox(height: AppSpacing.sm),
        Text('Restlaufzeit: ${_formatMs(playbackState.remainingMs)}'),
      ],
    );
  }

  Widget _line(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 84,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  String _formatMs(int milliseconds) {
    final totalSeconds = (milliseconds / 1000).ceil();
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
