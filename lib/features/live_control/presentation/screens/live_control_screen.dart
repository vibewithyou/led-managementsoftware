import 'package:flutter/material.dart';
import 'package:led_management_software/core/constants/app_spacing.dart';
import 'package:led_management_software/core/theme/app_colors.dart';
import 'package:led_management_software/features/live_control/controller/live_control_controller.dart';
import 'package:led_management_software/features/live_control/widgets/live_event_button.dart';
import 'package:led_management_software/features/live_control/widgets/live_queue_panel.dart';
import 'package:led_management_software/features/live_control/widgets/now_playing_panel.dart';
import 'package:led_management_software/shared/widgets/layout/page_header.dart';
import 'package:led_management_software/shared/widgets/surfaces/app_panel.dart';
import 'package:led_management_software/shared/widgets/surfaces/status_badge.dart';

class LiveControlScreen extends StatefulWidget {
  const LiveControlScreen({super.key});

  @override
  State<LiveControlScreen> createState() => _LiveControlScreenState();
}

class _LiveControlScreenState extends State<LiveControlScreen> with SingleTickerProviderStateMixin {
  late final LiveControlController _controller;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = LiveControlController();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageHeader(
              title: 'Live-Steuerung',
              description: 'Live-Regieoberfläche für Trigger, Now Playing und Queue-Management während des Spiels.',
            ),
            const SizedBox(height: AppSpacing.md),
            if (_controller.sponsorLockedRunning) ...[
              FadeTransition(
                opacity: _pulseAnimation,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.error, width: 1.4),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.error.withValues(alpha: 0.18),
                        blurRadius: 18,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 26),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'LOCKED SPONSOR CLIP',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppColors.error,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.4,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _controller.lockedSponsorLabel,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: AppColors.error),
                        ),
                        child: Text(
                          'QUEUE ${_controller.queueLength}',
                          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: AppPanel(
                            title: 'Event Buttons',
                            trailing: StatusBadge(
                              label: _controller.globalHotkeysActive ? 'HOTKEYS ACTIVE' : 'HOTKEYS OFF',
                              type: _controller.globalHotkeysActive ? StatusBadgeType.active : StatusBadgeType.disabled,
                              compact: true,
                            ),
                            child: Column(
                              children: [
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: FilledButton.icon(
                                    onPressed: _controller.triggerEmergencyBlackScreen,
                                    style: FilledButton.styleFrom(
                                      backgroundColor: AppColors.error,
                                      foregroundColor: AppColors.textPrimary,
                                    ),
                                    icon: const Icon(Icons.emergency_rounded),
                                    label: const Text('Notfall'),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Expanded(
                                  child: GridView.builder(
                                    itemCount: _controller.eventButtons.length,
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 1,
                                      mainAxisSpacing: AppSpacing.sm,
                                      childAspectRatio: 4.3,
                                    ),
                                    itemBuilder: (context, index) {
                                      final label = _controller.eventButtons[index];
                                      return LiveEventButton(
                                        label: label,
                                        hotkeyLabel: _controller.hotkeyForEvent(label),
                                        semanticColor: _eventColor(label),
                                        onPressed: () => _controller.triggerEvent(label),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          flex: 3,
                          child: AppPanel(
                            title: 'Now Playing',
                            trailing: StatusBadge(
                              label: _controller.playbackState.status.name.toUpperCase(),
                              type: _statusToBadge(_controller.playbackState.status.name),
                              compact: true,
                            ),
                            child: NowPlayingPanel(
                              playbackState: _controller.playbackState,
                              progress: _controller.progress,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          flex: 2,
                          child: AppPanel(
                            title: 'Queue + Status',
                            trailing: StatusBadge(
                              label: _controller.sponsorLockedRunning ? 'LOCKED' : 'FREE',
                              type: _controller.sponsorLockedRunning ? StatusBadgeType.locked : StatusBadgeType.ready,
                              compact: true,
                            ),
                            child: LiveQueuePanel(
                              queue: _controller.queue,
                              fallbackCueLabel: _controller.fallbackCueLabel,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    height: 210,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: AppPanel(
                            title: 'Systemstatus',
                            child: Column(
                              children: [
                                _statusLine(
                                  context,
                                  label: 'VLC Status',
                                  value: _controller.vlcRunning ? 'Running' : 'Stopped',
                                  color: _controller.vlcRunning ? AppColors.success : AppColors.error,
                                ),
                                _statusLine(
                                  context,
                                  label: 'Aktives Projekt',
                                  value: _controller.activeProjectId,
                                  color: AppColors.primary,
                                ),
                                _statusLine(
                                  context,
                                  label: 'Fallback gesetzt',
                                  value: _controller.fallbackConfigured ? 'Ja' : 'Nein',
                                  color: _controller.fallbackConfigured ? AppColors.success : AppColors.warning,
                                ),
                                _statusLine(
                                  context,
                                  label: 'Queue Länge',
                                  value: '${_controller.queueLength}',
                                  color: _controller.queueLength > 0 ? AppColors.warning : AppColors.success,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          flex: 3,
                          child: AppPanel(
                            title: 'Letzte Aktionen',
                            trailing: StatusBadge(
                              label: '${_controller.recentLogs.length} LOGS',
                              type: StatusBadgeType.active,
                              compact: true,
                            ),
                            child: _controller.recentLogs.isEmpty
                                ? const Center(child: Text('Noch keine Aktionen protokolliert.'))
                                : ListView.separated(
                                    itemCount: _controller.recentLogs.length,
                                    separatorBuilder: (context, index) => const Divider(height: 12),
                                    itemBuilder: (context, index) {
                                      final log = _controller.recentLogs[index];
                                      final actionColor = _logColor(log.result);
                                      return Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 10,
                                            height: 10,
                                            margin: const EdgeInsets.only(top: 6),
                                            decoration: BoxDecoration(
                                              color: actionColor,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: AppSpacing.sm),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  log.cueId == null ? log.actionType.name : '${log.actionType.name} • ${log.cueId}',
                                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  '${log.result} • ${_formatTimestamp(log.timestamp)}',
                                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  StatusBadgeType _statusToBadge(String status) {
    switch (status) {
      case 'locked':
        return StatusBadgeType.locked;
      case 'queued':
        return StatusBadgeType.queued;
      case 'playing':
        return StatusBadgeType.active;
      case 'black':
        return StatusBadgeType.disabled;
      default:
        return StatusBadgeType.ready;
    }
  }

  Color _eventColor(String label) {
    switch (label) {
      case 'Sponsor Loop':
        return AppColors.error;
      case 'Stop':
        return AppColors.error;
      case 'Black Screen':
        return AppColors.disabled;
      case 'Tor':
      case 'Nächster Spieler':
        return AppColors.success;
      case 'Zeitstrafe':
      case 'Gelbe Karte':
      case 'Rote Karte':
        return AppColors.warning;
      default:
        return AppColors.primary;
    }
  }

  Widget _statusLine(
    BuildContext context, {
    required String label,
    required String value,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              border: Border.all(color: color),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Color _logColor(String result) {
    if (result.contains('error')) {
      return AppColors.error;
    }
    if (result.contains('queued') || result.contains('dequeued')) {
      return AppColors.warning;
    }
    if (result.contains('stopped') || result.contains('black')) {
      return AppColors.disabled;
    }
    return AppColors.success;
  }

  String _formatTimestamp(DateTime? timestamp) {
    if (timestamp == null) {
      return '—';
    }
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    final second = timestamp.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }
}
