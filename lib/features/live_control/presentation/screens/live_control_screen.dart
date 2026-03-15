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

class _LiveControlScreenState extends State<LiveControlScreen> {
  late final LiveControlController _controller;

  @override
  void initState() {
    super.initState();
    _controller = LiveControlController();
  }

  @override
  void dispose() {
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
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: AppPanel(
                      title: 'Event Buttons',
                      trailing: const StatusBadge(
                        label: 'STANDARD',
                        type: StatusBadgeType.active,
                        compact: true,
                      ),
                      child: GridView.builder(
                        itemCount: _controller.eventButtons.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 1,
                          mainAxisSpacing: AppSpacing.sm,
                          childAspectRatio: 4.3,
                        ),
                        itemBuilder: (_, index) {
                          final label = _controller.eventButtons[index];
                          return LiveEventButton(
                            label: label,
                            semanticColor: _eventColor(label),
                            onPressed: () => _controller.triggerEvent(label),
                          );
                        },
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
}
