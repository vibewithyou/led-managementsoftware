import 'package:flutter/material.dart';
import 'package:led_management_software/core/constants/app_spacing.dart';
import 'package:led_management_software/core/theme/app_colors.dart';
import 'package:led_management_software/features/live_control/model/live_cue_model.dart';
import 'package:led_management_software/shared/widgets/surfaces/queue_item_card.dart';
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
            const Text('Warteschlange'),
            const SizedBox(width: AppSpacing.xs),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceStrong,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.borderStrong),
              ),
              child: Text('${queue.length}'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: queue.isEmpty
              ? const Center(child: Text('Queue ist leer'))
              : ListView.separated(
                  itemCount: queue.length,
                  itemBuilder: (context, index) {
                    final item = queue[index];
                    return AnimatedSlide(
                      duration: const Duration(milliseconds: 220),
                      offset: Offset.zero,
                      child: QueueItemCard(
                        title: item.title,
                        subtitle: '${item.category} • ${_formatMs(item.remainingMs)}',
                        status: StatusBadgeType.queued,
                      ),
                    );
                  },
                  separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
                ),
        ),
        const SizedBox(height: AppSpacing.md),
        const Divider(height: 1),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: const [
            Icon(Icons.shield_rounded, size: 18),
            SizedBox(width: AppSpacing.xs),
            Text('Fallback Cue'),
            Spacer(),
            StatusBadge(label: 'READY', type: StatusBadgeType.ready, compact: true),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(fallbackCueLabel),
      ],
    );
  }

  String _formatMs(int milliseconds) {
    final totalSeconds = (milliseconds / 1000).ceil();
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
