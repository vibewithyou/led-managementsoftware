import 'package:flutter/material.dart';
import 'package:led_management_software/core/constants/app_spacing.dart';
import 'package:led_management_software/core/theme/app_colors.dart';
import 'package:led_management_software/domain/enums/transport_status.dart';
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
                opacity: _controller.reduceAnimations ? const AlwaysStoppedAnimation<double>(1) : _pulseAnimation,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.error.withValues(alpha: 0.2),
                        AppColors.error.withValues(alpha: 0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.error, width: 1.6),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.error.withValues(alpha: 0.25),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 28),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SPONSOR-LOCK AKTIV',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: AppColors.error,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                            ),
                            const SizedBox(height: AppSpacing.xxs),
                            Text(
                              _controller.lockedSponsorLabel,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                      const StatusBadge(label: 'LOCKED', type: StatusBadgeType.locked, compact: true),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            _systemStatusStrip(context),
            const SizedBox(height: AppSpacing.md),
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
                                        Container(
                                          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                                          padding: const EdgeInsets.all(AppSpacing.sm),
                                          decoration: BoxDecoration(
                                            color: AppColors.surfaceMuted.withValues(alpha: 0.42),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: AppColors.border),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
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
                                                    large: _controller.useLargeControls,
                                                    reducedMotion: _controller.reduceAnimations,
                                                    onPressed: () => _controller.triggerAction(action),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
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
                            child: Column(
                              children: [
                                Expanded(
                                  child: LiveQueuePanel(queue: _controller.queue, fallbackCueLabel: _controller.fallbackCueLabel),
                                ),
                                const SizedBox(height: AppSpacing.md),
                                const Divider(height: 1),
                                const SizedBox(height: AppSpacing.sm),
                                _recentActionsPanel(context),
                              ],
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

  Widget _systemStatusStrip(BuildContext context) {
    return AnimatedContainer(
      duration: _controller.reduceAnimations ? Duration.zero : const Duration(milliseconds: 220),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: _controller.hasTransportError ? AppColors.error.withValues(alpha: 0.12) : AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _controller.hasTransportError ? AppColors.error : AppColors.border),
      ),
      child: Row(
        children: [
          StatusBadge(
            label: _transportLabel(_controller.transportStatus),
            type: _transportBadge(_controller.transportStatus),
            compact: true,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              _controller.transportMessage,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: _controller.hasTransportError ? AppColors.error : AppColors.textPrimary,
                  ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          StatusBadge(
            label: _controller.queueLength == 0 ? 'QUEUE LEER' : 'QUEUE ${_controller.queueLength}',
            type: _controller.queueLength == 0 ? StatusBadgeType.ready : StatusBadgeType.queued,
            compact: true,
          ),
        ],
      ),
    );
  }

  Widget _recentActionsPanel(BuildContext context) {
    final logs = _controller.recentLogs;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Letzte Aktionen',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: AppSpacing.xs),
              StatusBadge(
                label: '${logs.length}',
                type: StatusBadgeType.hover,
                compact: true,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: logs.isEmpty
                  ? Center(
                      child: Text(
                        'Noch keine Aktionen',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                      ),
                    )
                  : ListView.separated(
                      itemCount: logs.length,
                      itemBuilder: (context, index) {
                        final item = logs[index];
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceMuted.withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.history_rounded, size: 14, color: AppColors.textMuted),
                              const SizedBox(width: AppSpacing.xs),
                              Expanded(
                                child: Text(
                                  '${item.actionType.name} • ${item.result}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.xs),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  String _transportLabel(TransportStatus status) {
    return switch (status) {
      TransportStatus.ready => 'VLC BEREIT',
      TransportStatus.starting => 'VLC STARTET',
      TransportStatus.playing => 'VLC SPIELT',
      TransportStatus.error => 'VLC FEHLER',
      TransportStatus.fileMissing => 'DATEI FEHLT',
      TransportStatus.stopped => 'VLC GESTOPPT',
    };
  }

  StatusBadgeType _transportBadge(TransportStatus status) {
    return switch (status) {
      TransportStatus.ready => StatusBadgeType.ready,
      TransportStatus.starting => StatusBadgeType.queued,
      TransportStatus.playing => StatusBadgeType.active,
      TransportStatus.error => StatusBadgeType.error,
      TransportStatus.fileMissing => StatusBadgeType.error,
      TransportStatus.stopped => StatusBadgeType.disabled,
    };
  }
}
