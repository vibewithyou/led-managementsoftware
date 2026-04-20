import 'package:flutter/material.dart';
import 'package:led_management_software/core/constants/app_spacing.dart';
import 'package:led_management_software/core/theme/app_colors.dart';
import 'package:led_management_software/core/theme/app_durations.dart';
import 'package:led_management_software/core/theme/app_radius.dart';
import 'package:led_management_software/features/live_control/model/live_cue_model.dart';
import 'package:led_management_software/shared/widgets/surfaces/status_badge.dart';

class LiveQueuePanel extends StatelessWidget {
  const LiveQueuePanel({
    required this.queue,
    required this.fallbackCueLabel,
    required this.sponsorLockedRunning,
    super.key,
  });

  final List<LiveCueModel> queue;
  final String fallbackCueLabel;
  final bool sponsorLockedRunning;

  @override
  Widget build(BuildContext context) {
    final nextReadyLabel = queue.isEmpty ? 'Automatik übernimmt' : 'Nächster Start aus dem Ablauf';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          children: [
            _summaryPill(context, Icons.playlist_play_rounded, queue.isEmpty ? 'Keine Einträge' : '${queue.length} bereit'),
            _summaryPill(context, Icons.flag_circle_rounded, nextReadyLabel),
            if (sponsorLockedRunning) _summaryPill(context, Icons.lock_clock_rounded, 'Start nach Sperrclip'),
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
                      return _queueCard(context, index: index, item: item);
                    },
                    separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
                  ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _fallbackSection(context),
      ],
    );
  }

  Widget _queueCard(BuildContext context, {required int index, required LiveCueModel item}) {
    final reason = _waitReason(index: index);
    final statusType = _statusType(item.status);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: index == 0 ? AppColors.secondary : AppColors.border),
        boxShadow: index == 0
            ? [
                BoxShadow(
                  color: AppColors.secondary.withValues(alpha: 0.12),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.surfaceStrong,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text('${index + 1}', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              if (index == 0)
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.xs),
                  child: StatusBadge(label: 'NÄCHSTER', type: StatusBadgeType.active, compact: true),
                ),
              StatusBadge(label: _statusLabel(item.status), type: statusType, compact: true),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.xxs,
            children: [
              Text(
                'Bereich: ${_categoryLabel(item.category)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
              ),
              Text(
                'Wartet auf: $reason',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
              ),
              Text(
                'Seit: ${_formatQueuedSince(item.queuedAt)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
              ),
              Text(
                'Rest: ${_formatMs(item.remainingMs)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _fallbackSection(BuildContext context) {
    final hasFallback = fallbackCueLabel.trim().isNotEmpty && fallbackCueLabel.trim().toLowerCase() != 'nicht konfiguriert';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: hasFallback ? AppColors.border : AppColors.warning),
      ),
      child: Row(
        children: [
          Icon(
            Icons.shield_rounded,
            size: 16,
            color: hasFallback ? AppColors.secondary : AppColors.warning,
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Automatik bei Leerlauf',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: AppSpacing.nano),
                Text(
                  hasFallback ? fallbackCueLabel : 'Keine Standardausspielung hinterlegt',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          StatusBadge(
            label: hasFallback ? 'BEREIT' : 'FEHLT',
            type: hasFallback ? StatusBadgeType.ready : StatusBadgeType.error,
            compact: true,
          ),
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
        'Keine Einträge vorgemerkt',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
      ),
    );
  }

  Widget _summaryPill(BuildContext context, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textMuted),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  String _waitReason({required int index}) {
    if (sponsorLockedRunning) {
      return 'Ende des Sperrclips';
    }
    if (index == 0) {
      return 'Freigabe für den nächsten Start';
    }
    return 'Vorherige Einträge';
  }

  String _statusLabel(String status) {
    final normalized = status.trim().toLowerCase();
    if (normalized == 'queued') return 'VORGEMERKT';
    if (normalized == 'playing') return 'LIVE';
    if (normalized == 'locked') return 'GESPERRT';
    return 'BEREIT';
  }

  StatusBadgeType _statusType(String status) {
    final normalized = status.trim().toLowerCase();
    if (normalized == 'playing') return StatusBadgeType.active;
    if (normalized == 'locked') return StatusBadgeType.locked;
    return StatusBadgeType.queued;
  }

  String _categoryLabel(String category) {
    final normalized = category.trim().toLowerCase();
    switch (normalized) {
      case 'advertising':
        return 'Werbung';
      case 'intro':
        return 'Intro';
      case 'safety':
        return 'Sicherheit';
      case 'game':
        return 'Spiel';
      default:
        return category;
    }
  }

  String _formatQueuedSince(DateTime queuedAt) {
    final hh = queuedAt.hour.toString().padLeft(2, '0');
    final mm = queuedAt.minute.toString().padLeft(2, '0');
    final ss = queuedAt.second.toString().padLeft(2, '0');
    return '$hh:$mm:$ss';
  }

  String _formatMs(int milliseconds) {
    final totalSeconds = (milliseconds / 1000).ceil();
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
