import 'package:flutter/material.dart';
import 'package:led_management_software/core/constants/app_spacing.dart';
import 'package:led_management_software/core/theme/app_colors.dart';
import 'package:led_management_software/core/theme/app_durations.dart';
import 'package:led_management_software/core/theme/app_radius.dart';
import 'package:led_management_software/features/live_control/model/live_cue_model.dart';
import 'package:led_management_software/shared/widgets/surfaces/status_badge.dart';

class LiveQueuePanel extends StatelessWidget {
  const LiveQueuePanel({required this.queue, required this.fallbackCueLabel, super.key});

  final List<LiveCueModel> queue;
  final String fallbackCueLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Warteschlange',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: AppSpacing.xs),
            StatusBadge(
              label: queue.isEmpty ? 'LEER' : '${queue.length} AKTIV',
              type: queue.isEmpty ? StatusBadgeType.disabled : StatusBadgeType.queued,
              compact: true,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: AnimatedSwitcher(
            duration: AppDurations.medium,
            child: queue.isEmpty
                ? _emptyState(context)
                : ListView.separated(
                    key: ValueKey<int>(queue.length),
                    itemCount: queue.length,
                    itemBuilder: (context, index) {
                      final item = queue[index];
                      return TweenAnimationBuilder<double>(
                        duration: Duration(milliseconds: 170 + (index * 20)),
                        tween: Tween(begin: 0.97, end: 1),
                        builder: (context, value, child) => Transform.scale(scale: value, child: child),
                        child: _queueCard(context, index: index, item: item),
                      );
                    },
                    separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
                  ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              const Icon(Icons.shield_rounded, size: 16, color: AppColors.secondary),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Fallback Cue', style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      fallbackCueLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              const StatusBadge(label: 'READY', type: StatusBadgeType.ready, compact: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _queueCard(BuildContext context, {required int index, required LiveCueModel item}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: index == 0 ? AppColors.secondary.withValues(alpha: 0.75) : AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surfaceStrong,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(color: AppColors.borderStrong),
            ),
            child: Text('${index + 1}', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  '${item.category} • ${_formatMs(item.remainingMs)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          const StatusBadge(label: 'QUEUED', type: StatusBadgeType.queued, compact: true),
        ],
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Container(
      key: const ValueKey<String>('queue_empty'),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        'Queue ist leer',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
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
