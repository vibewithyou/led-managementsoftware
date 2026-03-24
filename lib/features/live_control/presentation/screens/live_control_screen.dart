import 'package:flutter/material.dart';
import 'package:led_management_software/core/constants/app_spacing.dart';
import 'package:led_management_software/core/theme/app_colors.dart';
import 'package:led_management_software/features/live_control/controller/live_control_controller.dart';
import 'package:led_management_software/features/live_control/model/live_action_config.dart';
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
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
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
        final groupedActions = _groupActions(_controller.actions);

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
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 26),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          _controller.lockedSponsorLabel,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.error),
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
                            title: 'Live-Aktionen',
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
                                    style: FilledButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: AppColors.textPrimary),
                                    icon: const Icon(Icons.emergency_rounded),
                                    label: const Text('Notfall'),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Expanded(
                                  child: ListView(
                                    children: [
                                      for (final groupEntry in groupedActions.entries) ...[
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                                          child: Text(
                                            _groupLabel(groupEntry.key),
                                            style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.textMuted),
                                          ),
                                        ),
                                        ...groupEntry.value.map(
                                          (action) => Padding(
                                            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                                            child: LiveEventButton(
                                              action: action,
                                              onPressed: () => _controller.triggerAction(action),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: AppSpacing.sm),
                                      ],
                                    ],
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
                            child: LiveQueuePanel(queue: _controller.queue, fallbackCueLabel: _controller.fallbackCueLabel),
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

  Map<LiveActionGroup, List<LiveActionConfig>> _groupActions(List<LiveActionConfig> actions) {
    final map = <LiveActionGroup, List<LiveActionConfig>>{};
    for (final action in actions) {
      map.putIfAbsent(action.group, () => []).add(action);
    }
    return map;
  }

  String _groupLabel(LiveActionGroup group) {
    return switch (group) {
      LiveActionGroup.game => 'Spiel',
      LiveActionGroup.advertising => 'Werbung',
      LiveActionGroup.safety => 'Sicherheit',
      LiveActionGroup.intro => 'Intro',
    };
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
}
