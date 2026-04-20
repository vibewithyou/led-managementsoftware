import 'package:flutter/material.dart';
import 'package:led_managementsoftware_app/core/config/backend_runtime.dart';
import 'package:led_managementsoftware_app/core/config/app_demo_data.dart';
import 'package:led_managementsoftware_app/core/theme/app_colors.dart';
import 'package:led_managementsoftware_app/domain/enums/sync_status.dart';
import 'package:led_managementsoftware_app/features/live_control/application/live_control_controller.dart';
import 'package:led_managementsoftware_app/features/playback/domain/playback_status_model.dart';
import 'package:led_managementsoftware_app/shared/widgets/buttons/action_tile_button.dart';
import 'package:led_managementsoftware_app/shared/widgets/surfaces/app_panel.dart';
import 'package:led_managementsoftware_app/shared/widgets/surfaces/status_badge.dart';

class LiveControlScreen extends StatefulWidget {
  const LiveControlScreen({
    required this.backendRuntime,
    super.key,
  });

  final BackendRuntime backendRuntime;

  @override
  State<LiveControlScreen> createState() => _LiveControlScreenState();
}

class _LiveControlScreenState extends State<LiveControlScreen> {
  late final LiveControlController _controller;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _controller = LiveControlController(backendRuntime: widget.backendRuntime)..addListener(_refresh);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_refresh)
      ..dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 1200;

        if (narrow) {
          return SingleChildScrollView(
            child: Column(
              children: [
                _statusStrip(),
                const SizedBox(height: 18),
                _actionPanel('Heim-Aktionen', _controller.homeActions, AppColors.primary),
                const SizedBox(height: 18),
                _centerPanel(),
                const SizedBox(height: 18),
                _actionPanel('Gegner-Aktionen', _controller.awayActions, AppColors.warning),
                const SizedBox(height: 18),
                _queuePanel(),
                const SizedBox(height: 18),
                _playerPanel(),
              ],
            ),
          );
        }

        return Column(
          children: [
            _statusStrip(),
            const SizedBox(height: 18),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _actionPanel('Heim-Aktionen', _controller.homeActions, AppColors.primary)),
                  const SizedBox(width: 18),
                  Expanded(flex: 2, child: _centerPanel()),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      children: [
                        _actionPanel('Gegner-Aktionen', _controller.awayActions, AppColors.warning),
                        const SizedBox(height: 18),
                        _queuePanel(),
                        const SizedBox(height: 18),
                        _playerPanel(),
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

  Widget _statusStrip() {
    final playbackTone = switch (_controller.playbackState.status) {
      PlaybackStatusModel.playing => StatusBadgeTone.success,
      PlaybackStatusModel.paused => StatusBadgeTone.warning,
      PlaybackStatusModel.error => StatusBadgeTone.danger,
      PlaybackStatusModel.idle => StatusBadgeTone.neutral,
    };

    final syncTone = switch (_controller.projectSync) {
      SyncStatus.synced => StatusBadgeTone.success,
      SyncStatus.pending => StatusBadgeTone.warning,
      SyncStatus.conflict => StatusBadgeTone.danger,
      SyncStatus.localOnly => StatusBadgeTone.info,
    };

    return AppPanel(
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          StatusBadge(label: 'Aktive Szene: ${_controller.activeSceneName}', tone: StatusBadgeTone.info),
          StatusBadge(label: 'Playback: ${_controller.playbackState.status.name}', tone: playbackTone),
          StatusBadge(label: 'Sync: ${_controller.projectSync.label}', tone: syncTone),
          StatusBadge(
            label: _controller.hasProtectedClip ? 'Schutzclip aktiv' : 'Schutzclip aus',
            tone: _controller.hasProtectedClip ? StatusBadgeTone.warning : StatusBadgeTone.neutral,
          ),
        ],
      ),
    );
  }

  Widget _actionPanel(String title, List<String> actions, Color color) {
    return AppPanel(
      title: title,
      subtitle: 'Quick Actions mit Unterbrechungsregeln und Queue-Integration.',
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          for (final action in actions)
            SizedBox(
              width: 170,
              child: ActionTileButton(
                label: action,
                color: color,
                onPressed: () {
                  _controller.triggerQuickAction(action);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _centerPanel() {
    return AppPanel(
      title: 'Hauptsteuerung',
      subtitle: 'Controller-basierte Queue, Rückkehrlogik und Playbackstatus.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.backgroundRaised,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Aktiver Clip', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text(_controller.currentClipLabel, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(
                  'Szene: ${_controller.activeSceneName} · Queueindex ${_controller.queueState.currentClipIndex}',
                  style: const TextStyle(color: AppColors.textSoft),
                ),
                const SizedBox(height: 18),
                const Text('Nächster Clip', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(_controller.nextClipLabel, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _ControlButton(label: 'Start', tone: StatusBadgeTone.success, onPressed: _controller.startPlayback),
              _ControlButton(label: 'Pause', tone: StatusBadgeTone.warning, onPressed: _controller.pauseQueue),
              _ControlButton(label: 'Weiter', tone: StatusBadgeTone.info, onPressed: _controller.resumeQueue),
              _ControlButton(label: 'Stop', tone: StatusBadgeTone.danger, onPressed: _controller.stopPlayback),
              _ControlButton(label: 'Rückkehr', tone: StatusBadgeTone.neutral, onPressed: _controller.returnToPreviousScene),
              _ControlButton(label: 'Clip skip', tone: StatusBadgeTone.neutral, onPressed: _controller.skipClip),
              _ControlButton(label: 'Sync jetzt', tone: StatusBadgeTone.info, onPressed: _controller.syncNow),
              _ControlButton(
                label: 'Sync-Konflikt',
                tone: StatusBadgeTone.warning,
                onPressed: _controller.simulateSyncConflict,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _queuePanel() {
    final queue = _controller.queueState;

    return AppPanel(
      title: 'Queue & Zustand',
      subtitle: 'Live-bearbeitbar mit Unterbrechung, Rückkehrpunkt und Szenenwechsel.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Szene ${_controller.activeSceneName}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('Aktueller Index: ${queue.currentClipIndex}', style: const TextStyle(color: AppColors.textSoft)),
          const SizedBox(height: 4),
          Text('Nächster Index: ${queue.nextClipIndex}', style: const TextStyle(color: AppColors.textMuted)),
          const SizedBox(height: 12),
          Text(
            queue.interruptedBySceneId == null
                ? 'Keine Unterbrechung aktiv'
                : 'Unterbrochen von ${queue.interruptedBySceneId} · Rückkehrindex ${queue.returnClipIndex ?? 0}',
            style: TextStyle(
              color: queue.interruptedBySceneId == null ? AppColors.textSoft : AppColors.warning,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              StatusBadge(
                label: queue.isPaused ? 'Queue pausiert' : 'Queue aktiv',
                tone: queue.isPaused ? StatusBadgeTone.warning : StatusBadgeTone.success,
              ),
              StatusBadge(label: 'Nächster: ${_controller.nextClipLabel}', tone: StatusBadgeTone.info),
            ],
          ),
        ],
      ),
    );
  }

  Widget _playerPanel() {
    final visiblePlayers = AppDemoData.players
        .where((entry) => _query.isEmpty || entry.name.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return AppPanel(
      title: 'Spieler-Schnellauswahl',
      subtitle: 'Suchbar, scrollbar und getrennt nach Heim/Gegner.',
      child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              hintText: 'Spieler suchen',
              prefixIcon: Icon(Icons.search_rounded),
            ),
            onChanged: (value) {
              setState(() {
                _query = value;
              });
            },
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: ListView.builder(
              itemCount: visiblePlayers.length,
              itemBuilder: (context, index) {
                final player = visiblePlayers[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundRaised,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Text('#${player.number}', style: const TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(width: 10),
                      Expanded(child: Text(player.name)),
                      StatusBadge(
                        label: player.side,
                        compact: true,
                        tone: player.side == 'Heim' ? StatusBadgeTone.info : StatusBadgeTone.warning,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.label,
    required this.tone,
    required this.onPressed,
  });

  final String label;
  final StatusBadgeTone tone;
  final Future<void> Function() onPressed;

  @override
  Widget build(BuildContext context) {
    final color = switch (tone) {
      StatusBadgeTone.success => AppColors.success,
      StatusBadgeTone.warning => AppColors.warning,
      StatusBadgeTone.info => AppColors.info,
      StatusBadgeTone.danger => AppColors.danger,
      StatusBadgeTone.neutral => AppColors.surfaceStrong,
    };

    return SizedBox(
      width: 160,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: color,
          foregroundColor: tone == StatusBadgeTone.neutral ? AppColors.textPrimary : AppColors.background,
        ),
        onPressed: () async {
          await onPressed();
        },
        child: Text(label),
      ),
    );
  }
}
