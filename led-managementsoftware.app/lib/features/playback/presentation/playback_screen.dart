import 'dart:async';

import 'package:flutter/material.dart';
import 'package:led_managementsoftware_app/core/services/local_playback_service.dart';
import 'package:led_managementsoftware_app/core/theme/app_colors.dart';
import 'package:led_managementsoftware_app/features/playback/application/playback_controller.dart';
import 'package:led_managementsoftware_app/features/playback/domain/playback_status_model.dart';
import 'package:led_managementsoftware_app/shared/widgets/surfaces/app_panel.dart';
import 'package:led_managementsoftware_app/shared/widgets/surfaces/status_badge.dart';

class PlaybackScreen extends StatefulWidget {
  const PlaybackScreen({super.key});

  @override
  State<PlaybackScreen> createState() => _PlaybackScreenState();
}

class _PlaybackScreenState extends State<PlaybackScreen> {
  late final PlaybackController _controller;
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _controller = PlaybackController(LocalPlaybackService());
    _subscription = _controller.stateStream.listen((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  StatusBadgeTone get _statusTone {
    return switch (_controller.currentState.status) {
      PlaybackStatusModel.playing => StatusBadgeTone.success,
      PlaybackStatusModel.paused => StatusBadgeTone.warning,
      PlaybackStatusModel.error => StatusBadgeTone.danger,
      PlaybackStatusModel.idle => StatusBadgeTone.neutral,
    };
  }

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      title: 'Playback',
      subtitle: 'Playback-Steuerung für Live-Control mit belastbaren Befehlswegen.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              StatusBadge(label: 'Status: ${_controller.currentState.status.name}', tone: _statusTone),
              StatusBadge(label: 'Transport: bereit', tone: StatusBadgeTone.info),
              StatusBadge(
                label: _controller.lastError == null ? 'Fehlerfrei' : 'Fehler aktiv',
                tone: _controller.lastError == null ? StatusBadgeTone.neutral : StatusBadgeTone.danger,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final action in _actions)
                FilledButton.tonal(
                  onPressed: action.onPressed,
                  child: Text(action.label),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.backgroundRaised,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              _controller.lastError == null
                  ? 'Alle Transportbefehle sind aktiv und liefern sofortiges Status-Feedback.'
                  : 'Letzter Fehler: ${_controller.lastError}',
              style: TextStyle(color: AppColors.textSoft, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }

  List<_PlaybackAction> get _actions {
    return [
      _PlaybackAction('Start Clip', () => _controller.startClip('demo-clip')),
      _PlaybackAction('Pause', _controller.pause),
      _PlaybackAction('Resume', _controller.resume),
      _PlaybackAction('Stop', _controller.stop),
      _PlaybackAction('Next Clip', _controller.nextClip),
      _PlaybackAction('Load Scene', () => _controller.loadScene('scene-live')),
    ];
  }
}

class _PlaybackAction {
  const _PlaybackAction(this.label, this.onPressed);

  final String label;
  final Future<void> Function() onPressed;
}
