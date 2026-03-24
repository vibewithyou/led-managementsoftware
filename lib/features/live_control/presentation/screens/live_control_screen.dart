import 'dart:async';

import 'package:flutter/material.dart';
import 'package:led_management_software/core/constants/app_spacing.dart';
import 'package:led_management_software/core/theme/app_colors.dart';
import 'package:led_management_software/core/theme/app_durations.dart';
import 'package:led_management_software/core/theme/app_radius.dart';
import 'package:led_management_software/core/theme/app_shadows.dart';
import 'package:led_management_software/domain/enums/cue_type.dart';
import 'package:led_management_software/domain/enums/playback_status.dart';
import 'package:led_management_software/domain/enums/transport_status.dart';
import 'package:led_management_software/features/live_control/controller/live_control_controller.dart';
import 'package:led_management_software/features/live_control/model/live_action_config.dart';
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
  late final Timer _clockTimer;
  DateTime _now = DateTime.now();
  bool _sponsorLockExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = LiveControlController();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _now = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final gameSlots = _buildGameSlots();
        final introSlots = _buildIntroSlots();
        final outputSlots = _buildOutputSlots();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageHeader(
              title: 'Live-Steuerung',
              description: 'Zentrale Regieoberfläche für laufende Ausspielung, Ablauf und Sofortaktionen.',
            ),
            const SizedBox(height: AppSpacing.md),
            _topStatusBar(context),
            if (_controller.sponsorLockedRunning) ...[
              const SizedBox(height: AppSpacing.sm),
              _sponsorLockRibbon(context),
            ],
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compactHeight = constraints.maxHeight < 760;
                  final mainFlex = compactHeight ? 6 : 7;
                  final actionFlex = compactHeight ? 4 : 3;

                  return Column(
                    children: [
                      Expanded(
                        flex: mainFlex,
                        child: _mainPanelsLayout(context, constraints.maxWidth),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Expanded(
                        flex: actionFlex,
                        child: _actionsDeck(
                          context,
                          width: constraints.maxWidth,
                          gameSlots: gameSlots,
                          introSlots: introSlots,
                          outputSlots: outputSlots,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _mainPanelsLayout(BuildContext context, double width) {
    final isWide = width >= 1500;
    final isMedium = width >= 1200;

    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(flex: 7, child: _leftMainColumn(context)),
          const SizedBox(width: AppSpacing.md),
          Expanded(flex: 5, child: _rightMainColumn(context)),
        ],
      );
    }

    if (isMedium) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(flex: 6, child: _leftMainColumn(context)),
          const SizedBox(width: AppSpacing.md),
          Expanded(flex: 5, child: _rightMainColumn(context)),
        ],
      );
    }

    return Column(
      children: [
        Expanded(flex: 5, child: _leftMainColumn(context)),
        const SizedBox(height: AppSpacing.md),
        Expanded(flex: 5, child: _rightMainColumn(context)),
      ],
    );
  }

  Widget _leftMainColumn(BuildContext context) {
    return AppPanel(
      title: 'Now Playing',
      trailing: Wrap(
        spacing: AppSpacing.xs,
        runSpacing: AppSpacing.xxs,
        children: [
          StatusBadge(
            label: _transportLabel(_controller.transportStatus),
            type: _transportBadge(_controller.transportStatus),
            compact: true,
          ),
          StatusBadge(
            label: _playbackStatusLabel(_controller.playbackState.status.name),
            type: _statusToBadge(_controller.playbackState.status.name),
            compact: true,
          ),
          if (_controller.sponsorLockedRunning)
            const StatusBadge(label: 'SPERRCLIP', type: StatusBadgeType.locked, compact: true),
        ],
      ),
      child: NowPlayingPanel(
        playbackState: _controller.playbackState,
        progress: _controller.progress,
        fallbackCueLabel: _controller.fallbackCueLabel,
      ),
    );
  }

  Widget _rightMainColumn(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final splitBottom = constraints.maxWidth >= 520;

        return Column(
          children: [
            Expanded(
              flex: 2,
              child: AppPanel(
                title: 'Als Nächstes',
                trailing: StatusBadge(
                  label: _controller.queueLength == 0 ? 'AUTOMATIK' : 'BEREIT',
                  type: _controller.queueLength == 0 ? StatusBadgeType.ready : StatusBadgeType.queued,
                  compact: true,
                ),
                child: _nextUpFallbackPanel(context),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              flex: 4,
              child: AppPanel(
                title: 'Warteschlange',
                trailing: StatusBadge(
                  label: _controller.queueLength == 0 ? 'LEER' : '${_controller.queueLength} BEREIT',
                  type: _controller.queueLength == 0 ? StatusBadgeType.disabled : StatusBadgeType.queued,
                  compact: true,
                ),
                child: LiveQueuePanel(
                  queue: _controller.queue,
                  fallbackCueLabel: _controller.fallbackCueLabel,
                  sponsorLockedRunning: _controller.sponsorLockedRunning,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              flex: 3,
              child: splitBottom
                  ? Row(
                      children: [
                        Expanded(
                          flex: 6,
                          child: AppPanel(
                            title: 'Letzte Aktionen',
                            trailing: StatusBadge(
                              label: '${_controller.recentLogs.length}',
                              type: StatusBadgeType.hover,
                              compact: true,
                            ),
                            child: _recentActionsPanel(context),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          flex: 5,
                          child: AppPanel(
                            title: 'Player-Status',
                            trailing: StatusBadge(
                              label: _outputReadyLabel(),
                              type: _outputReadyType(),
                              compact: true,
                            ),
                            child: _compactSystemStatus(context),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        Expanded(
                          flex: 2,
                          child: AppPanel(
                            title: 'Letzte Aktionen',
                            trailing: StatusBadge(
                              label: '${_controller.recentLogs.length}',
                              type: StatusBadgeType.hover,
                              compact: true,
                            ),
                            child: _recentActionsPanel(context),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Expanded(
                          child: AppPanel(
                            title: 'Player-Status',
                            trailing: StatusBadge(
                              label: _outputReadyLabel(),
                              type: _outputReadyType(),
                              compact: true,
                            ),
                            child: _compactSystemStatus(context),
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

  Widget _actionsDeck(
    BuildContext context, {
    required double width,
    required List<_ActionSlot> gameSlots,
    required List<_ActionSlot> introSlots,
    required List<_ActionSlot> outputSlots,
  }) {
    final sections = [
      _ActionSectionData('Spiel', 'Direkte Live-Ereignisse', gameSlots),
      _ActionSectionData('Team / Intro', 'Vorläufe und Spieleraktionen', introSlots),
      _ActionSectionData('Ausgabe / Sicherheit', 'Automatik, Stop und Sofortmaßnahmen', outputSlots),
    ];

    return AppPanel(
      title: 'Live-Regietasten',
      trailing: StatusBadge(
        label: _controller.globalHotkeysActive ? 'KURZBEFEHLE AKTIV' : 'KURZBEFEHLE AUS',
        type: _controller.globalHotkeysActive ? StatusBadgeType.active : StatusBadgeType.disabled,
        compact: true,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 1380) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _actionSection(context, data: sections[0])),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: _actionSection(context, data: sections[1])),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: _actionSection(context, data: sections[2])),
              ],
            );
          }

          if (constraints.maxWidth >= 1080) {
            return Column(
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: _actionSection(context, data: sections[0])),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(child: _actionSection(context, data: sections[1])),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Expanded(child: _actionSection(context, data: sections[2])),
              ],
            );
          }

          return Column(
            children: [
              Expanded(child: _actionSection(context, data: sections[0])),
              const SizedBox(height: AppSpacing.md),
              Expanded(child: _actionSection(context, data: sections[1])),
              const SizedBox(height: AppSpacing.md),
              Expanded(child: _actionSection(context, data: sections[2])),
            ],
          );
        },
      ),
    );
  }

  Widget _topStatusBar(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 1420;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: compact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.xs,
                      children: _statusChips(context),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.xs,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _triggerTestOutput,
                          icon: const Icon(Icons.play_circle_outline_rounded),
                          label: const Text('Ausgabe testen'),
                        ),
                        FilledButton.icon(
                          onPressed: _controller.triggerEmergencyBlackScreen,
                          style: FilledButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: AppColors.textPrimary),
                          icon: const Icon(Icons.warning_amber_rounded),
                          label: const Text('Sofort Schwarz'),
                        ),
                      ],
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.xs,
                        children: _statusChips(context),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    OutlinedButton.icon(
                      onPressed: _triggerTestOutput,
                      icon: const Icon(Icons.play_circle_outline_rounded),
                      label: const Text('Ausgabe testen'),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    FilledButton.icon(
                      onPressed: _controller.triggerEmergencyBlackScreen,
                      style: FilledButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: AppColors.textPrimary),
                      icon: const Icon(Icons.warning_amber_rounded),
                      label: const Text('Sofort Schwarz'),
                    ),
                  ],
                ),
        );
      },
    );
  }

  List<Widget> _statusChips(BuildContext context) {
    return [
      _statusChip(context, 'PROJEKT', _displayProjectLabel()),
      _statusChip(context, 'PLAYER', _transportLabel(_controller.transportStatus), badge: _transportBadge(_controller.transportStatus)),
      _statusChip(
        context,
        'AUSGABE',
        _playbackStatusLabel(_controller.playbackState.status.name),
        badge: _statusToBadge(_controller.playbackState.status.name),
      ),
      _statusChip(
        context,
        'ABLAUF',
        _controller.queueLength == 0 ? 'KEIN EINTRAG' : '${_controller.queueLength} BEREIT',
        badge: _controller.queueLength == 0 ? StatusBadgeType.disabled : StatusBadgeType.queued,
      ),
      _statusChip(context, 'UHR', _formatClock(_now)),
    ];
  }

  Widget _sponsorLockRibbon(BuildContext context) {
    final remaining = _formatDurationMs(_controller.playbackState.remainingMs);
    final queueCount = _controller.queueLength;

    return AnimatedContainer(
      duration: _controller.reduceAnimations ? Duration.zero : AppDurations.medium,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.72)),
        boxShadow: AppShadows.glow(AppColors.error.withValues(alpha: 0.65)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 1200;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.lock_outline_rounded, color: AppColors.error, size: 16),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      'Sperrclip aktiv • ${_lockedSponsorDisplayLabel()}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.error, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  IconButton(
                    onPressed: () => setState(() => _sponsorLockExpanded = !_sponsorLockExpanded),
                    icon: Icon(
                      _sponsorLockExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                      color: AppColors.error,
                    ),
                    iconSize: 18,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minHeight: 24, minWidth: 24),
                    tooltip: _sponsorLockExpanded ? 'Details ausblenden' : 'Details anzeigen',
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xxs,
                children: [
                  StatusBadge(label: 'REST $remaining', type: StatusBadgeType.locked, compact: true),
                  StatusBadge(
                    label: queueCount == 0 ? 'ABLAUF LEER' : '$queueCount EINTRAG${queueCount == 1 ? '' : 'E'} WARTEN',
                    type: queueCount == 0 ? StatusBadgeType.ready : StatusBadgeType.queued,
                    compact: true,
                  ),
                  if (!compact || _sponsorLockExpanded)
                    const StatusBadge(label: 'AKTIONEN WERDEN BIS CLIP-ENDE VORGEMERKT', type: StatusBadgeType.hover, compact: true),
                ],
              ),
              if (_sponsorLockExpanded) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Neue Aktionen werden gesammelt und direkt nach dem Sperrclip gestartet.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _statusChip(BuildContext context, String label, String value, {StatusBadgeType? badge}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label ',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted, fontWeight: FontWeight.w700),
          ),
          if (badge != null)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.xs),
              child: StatusBadge(label: value, type: badge, compact: true),
            )
          else
            Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _nextUpFallbackPanel(BuildContext context) {
    final nextCue = _controller.queue.isNotEmpty ? _controller.queue.first : null;
    final nextTitle = nextCue?.title ?? _controller.fallbackCueLabel;
    final nextType = nextCue?.category ?? 'fallback';
    final waitingReason = _controller.sponsorLockedRunning
      ? 'Startet nach Ende des Sperrclips'
        : nextCue == null
        ? 'Keine Einträge vorgemerkt, Automatik übernimmt'
        : 'Erster freier Eintrag im Ablauf';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Bereit als Nächstes', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: AppSpacing.nano),
                    Text(
                      nextCue == null ? 'Automatik übernimmt bei Leerlauf.' : 'Der nächste Start aus dem Ablauf.',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              StatusBadge(
                label: _controller.queueLength == 0 ? 'AUTOMATIK' : 'ABLAUF',
                type: _controller.queueLength == 0 ? StatusBadgeType.ready : StatusBadgeType.queued,
                compact: true,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nextTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.xxs,
                    children: [
                      StatusBadge(label: _cueCategoryLabel(nextType).toUpperCase(), type: StatusBadgeType.hover, compact: true),
                      StatusBadge(label: waitingReason.toUpperCase(), type: _controller.sponsorLockedRunning ? StatusBadgeType.locked : StatusBadgeType.queued, compact: true),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    'Automatik danach: ${_controller.fallbackCueLabel}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ),
          if (_controller.sponsorLockedRunning) ...[
            const SizedBox(height: AppSpacing.xs),
            const StatusBadge(label: 'STARTET NACH SPERRCLIP', type: StatusBadgeType.locked, compact: true),
          ],
        ],
      ),
    );
  }

  Widget _compactSystemStatus(BuildContext context) {
    final lastError = _lastSystemError();

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = ((constraints.maxWidth - AppSpacing.sm) / 2).clamp(150.0, 260.0);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                SizedBox(
                  width: cardWidth,
                  child: _systemStatusCard(
                    context,
                    label: 'VLC',
                    value: _transportLabel(_controller.transportStatus),
                    type: _transportBadge(_controller.transportStatus),
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: _systemStatusCard(
                    context,
                    label: 'Projekt',
                    value: _displayProjectLabel(),
                    type: _displayProjectLabel() == 'Kein Projekt' ? StatusBadgeType.disabled : StatusBadgeType.hover,
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: _systemStatusCard(
                    context,
                    label: 'Automatik',
                    value: _controller.fallbackConfigured ? 'Gesetzt' : 'Fehlt',
                    type: _controller.fallbackConfigured ? StatusBadgeType.ready : StatusBadgeType.error,
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: _systemStatusCard(
                    context,
                    label: 'Ablauf',
                    value: _controller.queueLength == 0 ? 'Leer' : '${_controller.queueLength} bereit',
                    type: _controller.queueLength == 0 ? StatusBadgeType.disabled : StatusBadgeType.queued,
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: _systemStatusCard(
                    context,
                    label: 'Ausgabe',
                    value: _outputReadyLabel(),
                    type: _outputReadyType(),
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: _systemStatusCard(
                    context,
                    label: 'Player',
                    value: _controller.vlcRunning ? 'Aktiv' : 'Aus',
                    type: _controller.vlcRunning ? StatusBadgeType.active : StatusBadgeType.disabled,
                  ),
                ),
              ],
            ),
            if (lastError != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.55)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 14, color: AppColors.error),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        'Letzter Fehler: $lastError',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _systemStatusCard(
    BuildContext context, {
    required String label,
    required String value,
    required StatusBadgeType type,
  }) {
    final accent = _statusTypeColor(type);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: accent,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.45),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textMuted,
                        letterSpacing: 0.5,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: AppSpacing.nano),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionSection(BuildContext context, {required _ActionSectionData data}) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderStrong.withValues(alpha: 0.55)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(data.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.xxs),
          Text(data.subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted)),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth >= 260 ? 2 : 1;
                final tileWidth = (constraints.maxWidth - (crossAxisCount - 1) * AppSpacing.sm) / crossAxisCount;
                final tileHeight = constraints.maxHeight < 190 ? 58.0 : 66.0;
                final rows = (data.slots.length / crossAxisCount).ceil();
                final needed = rows * tileHeight + (rows - 1) * AppSpacing.sm;
                final aspectRatio = tileWidth / tileHeight;

                if (needed <= constraints.maxHeight) {
                  return GridView.builder(
                    itemCount: data.slots.length,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: AppSpacing.sm,
                      crossAxisSpacing: AppSpacing.sm,
                      childAspectRatio: aspectRatio,
                    ),
                    itemBuilder: (context, index) => _actionKey(context, data.slots[index]),
                  );
                }

                return ListView.separated(
                  itemCount: data.slots.length,
                  itemBuilder: (context, index) => SizedBox(height: tileHeight, child: _actionKey(context, data.slots[index])),
                  separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionKey(BuildContext context, _ActionSlot slot) {
    final action = slot.action;
    final state = _slotState(slot);
    final blocked = state == _ActionKeyState.blocked;
    final queued = state == _ActionKeyState.queued;
    final active = state == _ActionKeyState.active;
    final accent = slot.semanticColor;

    return _AnimatedDeskKey(
      enabled: !blocked,
      reducedMotion: _controller.reduceAnimations,
      onTap: blocked ? null : slot.onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
        decoration: BoxDecoration(
          color: blocked ? AppColors.surfaceMuted.withValues(alpha: 0.5) : AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(
            color: active
                ? accent
                : queued
                    ? AppColors.warning
                    : blocked
                        ? AppColors.border
                        : AppColors.borderStrong,
            width: active ? 1.4 : 1.0,
          ),
          boxShadow: active
              ? AppShadows.glow(accent)
              : slot.emergency
                  ? AppShadows.glow(AppColors.error.withValues(alpha: 0.8))
                  : AppShadows.panel,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 230;
            return Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: blocked ? AppColors.surfaceStrong : accent.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(color: blocked ? AppColors.border : accent.withValues(alpha: 0.75)),
                  ),
                  child: Icon(slot.icon, size: 18, color: blocked ? AppColors.textMuted : accent),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        slot.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: blocked ? AppColors.textMuted : AppColors.textPrimary,
                            ),
                      ),
                      if (!compact) ...[
                        const SizedBox(height: 1),
                        Text(
                          slot.subLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if ((action?.hotkey ?? '').isNotEmpty)
                      StatusBadge(label: action!.hotkey!, type: StatusBadgeType.hover, compact: true),
                    const SizedBox(height: 2),
                    StatusBadge(label: _stateLabel(state), type: _stateBadgeType(state), compact: true),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<_ActionSlot> _buildGameSlots() {
    return [
      _slotFromAction('goal', 'Tor', semanticColor: AppColors.success, icon: Icons.sports_soccer_rounded),
      _slotFromAction('penalty', 'Zeitstrafe', semanticColor: AppColors.warning, icon: Icons.timer_rounded),
      _slotFromAction('yellow_card', 'Gelbe Karte', semanticColor: AppColors.warning, icon: Icons.style_rounded),
      _slotFromAction('red_card', 'Rote Karte', semanticColor: AppColors.error, icon: Icons.report_rounded),
      _slotFromAction('timeout', 'Timeout', semanticColor: AppColors.primary, icon: Icons.pause_circle_filled_rounded),
      _slotFromAction('wiper', 'Wischer', semanticColor: AppColors.secondary, icon: Icons.cleaning_services_rounded),
    ];
  }

  List<_ActionSlot> _buildIntroSlots() {
    return [
      _slotFromAction('next_player', 'Nächster Spieler', semanticColor: AppColors.success, icon: Icons.skip_next_rounded),
      _unavailableSlot('Vorheriger Spieler', 'Nicht konfiguriert', icon: Icons.skip_previous_rounded),
      _unavailableSlot('Endclip', 'Nicht konfiguriert', icon: Icons.flag_rounded),
      _unavailableSlot('Heimintro', 'Nicht konfiguriert', icon: Icons.home_rounded),
      _unavailableSlot('Gastintro', 'Nicht konfiguriert', icon: Icons.directions_run_rounded),
    ];
  }

  List<_ActionSlot> _buildOutputSlots() {
    return [
      _slotFromAction('sponsor_loop', 'Sponsor Loop', semanticColor: AppColors.error, icon: Icons.autorenew_rounded, sponsorRelevant: true),
      _slotFromAction('stop', 'Stop', semanticColor: AppColors.error, icon: Icons.stop_circle_rounded, emergency: true),
      _fallbackSlot(),
      _testOutputSlot(),
      _notfallSlot(),
    ];
  }

  _ActionSlot _slotFromAction(
    String id,
    String label, {
    required Color semanticColor,
    required IconData icon,
    bool emergency = false,
    bool sponsorRelevant = false,
  }) {
    final action = _controller.actions.where((item) => item.id == id).cast<LiveActionConfig?>().firstWhere((item) => item != null, orElse: () => null);

    if (action == null) {
      return _unavailableSlot(label, 'Nicht konfiguriert', icon: icon, emergency: emergency, sponsorRelevant: sponsorRelevant);
    }

    return _ActionSlot(
      label: label,
      subLabel: sponsorRelevant ? 'Sperrt andere Aktionen' : 'Sofort auslösen',
      icon: icon,
      semanticColor: semanticColor,
      emergency: emergency,
      sponsorRelevant: sponsorRelevant,
      action: action,
      onPressed: () => _controller.triggerAction(action),
    );
  }

  _ActionSlot _fallbackSlot() {
    final sponsorLoop = _controller.actions.where((item) => item.id == 'sponsor_loop').cast<LiveActionConfig?>().firstWhere((item) => item != null, orElse: () => null);
    if (sponsorLoop == null) {
      return _unavailableSlot('Automatik', 'Nicht eingerichtet', icon: Icons.restore_rounded, sponsorRelevant: true);
    }

    return _ActionSlot(
      label: 'Automatik',
      subLabel: 'Zur Standardausspielung',
      icon: Icons.restore_rounded,
      semanticColor: AppColors.warning,
      sponsorRelevant: true,
      action: sponsorLoop,
      onPressed: () => _controller.triggerAction(sponsorLoop),
    );
  }

  _ActionSlot _testOutputSlot() {
    return _ActionSlot(
      label: 'Ausgabe testen',
      subLabel: 'Kurzer Sichttest',
      icon: Icons.play_circle_outline_rounded,
      semanticColor: AppColors.secondary,
      onPressed: _triggerTestOutput,
      action: null,
    );
  }

  _ActionSlot _notfallSlot() {
    return _ActionSlot(
      label: 'Sofort Schwarz',
      subLabel: 'Bild sofort ausblenden',
      icon: Icons.warning_amber_rounded,
      semanticColor: AppColors.error,
      emergency: true,
      onPressed: _controller.triggerEmergencyBlackScreen,
      action: _controller.actions.where((item) => item.id == 'black_screen').cast<LiveActionConfig?>().firstWhere((item) => item != null, orElse: () => null),
    );
  }

  _ActionSlot _unavailableSlot(
    String label,
    String subLabel, {
    required IconData icon,
    bool emergency = false,
    bool sponsorRelevant = false,
  }) {
    return _ActionSlot(
      label: label,
      subLabel: subLabel,
      icon: icon,
      semanticColor: AppColors.disabled,
      emergency: emergency,
      sponsorRelevant: sponsorRelevant,
      action: null,
      onPressed: null,
    );
  }

  _ActionKeyState _slotState(_ActionSlot slot) {
    if (slot.onPressed == null) {
      return _ActionKeyState.blocked;
    }

    final action = slot.action;
    if (action != null) {
      final cue = _controller.playbackState.currentCue;
      final isActive = cue != null && (cue.mediaAssetId == action.id || cue.title == action.label);
      if (isActive) {
        return _ActionKeyState.active;
      }

      if (_controller.sponsorLockedRunning && action.cueType != CueType.lockedSponsor) {
        return _ActionKeyState.queued;
      }
    }

    return _ActionKeyState.ready;
  }

  String _stateLabel(_ActionKeyState state) {
    switch (state) {
      case _ActionKeyState.active:
        return 'LIVE';
      case _ActionKeyState.queued:
        return 'MERKT VOR';
      case _ActionKeyState.blocked:
        return 'NICHT BEREIT';
      case _ActionKeyState.ready:
        return 'BEREIT';
    }
  }

  StatusBadgeType _stateBadgeType(_ActionKeyState state) {
    switch (state) {
      case _ActionKeyState.active:
        return StatusBadgeType.active;
      case _ActionKeyState.queued:
        return StatusBadgeType.queued;
      case _ActionKeyState.blocked:
        return StatusBadgeType.disabled;
      case _ActionKeyState.ready:
        return StatusBadgeType.ready;
    }
  }

  Widget _recentActionsPanel(BuildContext context) {
    final logs = _controller.recentLogs;
    return AnimatedSwitcher(
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
                final stateType = item.result.trim().toLowerCase() == 'error'
                    ? StatusBadgeType.error
                    : item.result.trim().toLowerCase() == 'queued'
                        ? StatusBadgeType.queued
                        : StatusBadgeType.ready;
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _actionLabel(item.actionType.name),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Text(
                                  _formatEventTime(item.timestamp),
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                Expanded(
                                  child: Text(
                                    _resultLabel(item.result, item.errorMessage),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                StatusBadge(label: _actionResultBadgeLabel(item.result), type: stateType, compact: true),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
              separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.xs),
            ),
    );
  }

  String _cueCategoryLabel(String category) {
    switch (category.trim().toLowerCase()) {
      case 'game':
        return 'Spiel';
      case 'intro':
        return 'Intro';
      case 'advertising':
        return 'Werbung';
      case 'safety':
        return 'Sicherheit';
      case 'fallback':
        return 'Automatik';
      default:
        return category;
    }
  }

  String _actionLabel(String actionType) {
    switch (actionType) {
      case 'triggerCue':
        return 'Beitrag gestartet';
      case 'stopCue':
        return 'Ausgabe gestoppt';
      case 'queueAdd':
        return 'Im Ablauf vorgemerkt';
      case 'queueRemove':
        return 'Aus Ablauf gestartet';
      case 'queueClear':
        return 'Ablauf geleert';
      case 'blackScreenOn':
        return 'Schwarzbild aktiviert';
      default:
        return actionType;
    }
  }

  String _resultLabel(String result, String? errorMessage) {
    switch (result.trim().toLowerCase()) {
      case 'success':
        return 'Erfolgreich ausgeführt';
      case 'queued':
        return 'Für den Ablauf vorgemerkt';
      case 'error':
        return errorMessage?.trim().isNotEmpty == true ? errorMessage!.trim() : 'Aktion konnte nicht gestartet werden';
      default:
        return result;
    }
  }

  String _actionResultBadgeLabel(String result) {
    switch (result.trim().toLowerCase()) {
      case 'success':
        return 'OK';
      case 'queued':
        return 'ABLAUF';
      case 'error':
        return 'FEHLER';
      default:
        return result.toUpperCase();
    }
  }

  String _formatClock(DateTime dateTime) {
    final hh = dateTime.hour.toString().padLeft(2, '0');
    final mm = dateTime.minute.toString().padLeft(2, '0');
    final ss = dateTime.second.toString().padLeft(2, '0');
    return '$hh:$mm:$ss';
  }

  String _formatDurationMs(int milliseconds) {
    final totalSeconds = (milliseconds / 1000).ceil();
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _triggerTestOutput() {
    final action = _controller.actions.where((item) {
      return item.id == 'wiper' || item.id == 'goal' || item.id == 'timeout';
    }).cast<LiveActionConfig?>().firstWhere((item) => item != null, orElse: () => null);

    if (action != null) {
      _controller.triggerAction(action);
      return;
    }

    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Keine geeignete Aktion für einen kurzen Ausgabetest konfiguriert.')),
    );
  }

  String _transportLabel(TransportStatus status) {
    return switch (status) {
      TransportStatus.ready => 'BEREIT',
      TransportStatus.starting => 'STARTET',
      TransportStatus.playing => 'LÄUFT',
      TransportStatus.error => 'STÖRUNG',
      TransportStatus.fileMissing => 'DATEI FEHLT',
      TransportStatus.stopped => 'ANGEHALTEN',
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

  String _playbackStatusLabel(String status) {
    switch (status.trim().toLowerCase()) {
      case 'locked':
        return 'SPERRCLIP';
      case 'queued':
        return 'VORGEMERKT';
      case 'playing':
        return 'LIVE';
      case 'black':
        return 'SCHWARZBILD';
      default:
        return 'BEREIT';
    }
  }

  String _displayProjectLabel() {
    final value = _controller.activeProjectId.trim();
    if (value.isEmpty) {
      return 'Kein Projekt';
    }
    return value;
  }

  String _lockedSponsorDisplayLabel() {
    final value = _controller.lockedSponsorLabel.trim();
    if (value.isEmpty || value == 'LOCKED SPONSOR CLIP') {
      return 'Sponsor-Spot';
    }
    return value;
  }

  String _operatorTransportMessage() {
    final message = _controller.transportMessage.trim();
    if (message.isEmpty) {
      return 'Player bereit für die nächste Ausspielung.';
    }

    final normalized = message.toLowerCase();
    if (normalized.contains('vlc gestoppt')) {
      return 'Player ist angehalten. Neue Beiträge können gestartet werden.';
    }
    if (normalized.contains('missing plugin')) {
      return 'Player-Funktion ist auf dieser Plattform nicht verfügbar.';
    }
    if (normalized.contains('file') && normalized.contains('missing')) {
      return 'Die zugehörige Mediendatei wurde nicht gefunden.';
    }
    if (normalized.contains('error') || normalized.contains('fehler')) {
      return 'Player meldet eine Störung. Bitte Quelle und VLC-Verbindung prüfen.';
    }
    if (normalized.contains('playing') || normalized.contains('spielt')) {
      return 'Player gibt aktuell ein Medium aus.';
    }
    if (normalized.contains('starting') || normalized.contains('start')) {
      return 'Player wird vorbereitet.';
    }
    return message;
  }

  String _formatEventTime(DateTime? timestamp) {
    if (timestamp == null) {
      return '--:--:--';
    }
    return _formatClock(timestamp);
  }

  String _outputReadyLabel() {
    return _isOutputReady() ? 'Bereit' : 'Nicht bereit';
  }

  StatusBadgeType _outputReadyType() {
    return _isOutputReady() ? StatusBadgeType.ready : StatusBadgeType.error;
  }

  bool _isOutputReady() {
    if (_controller.hasTransportError) {
      return false;
    }
    if (_controller.playbackState.status == PlaybackStatus.black) {
      return false;
    }

    return switch (_controller.transportStatus) {
      TransportStatus.ready => true,
      TransportStatus.starting => true,
      TransportStatus.playing => true,
      TransportStatus.error => false,
      TransportStatus.fileMissing => false,
      TransportStatus.stopped => false,
    };
  }

  String? _lastSystemError() {
    final lastError = _controller.playbackState.lastError?.trim();
    if (lastError != null && lastError.isNotEmpty) {
      return lastError;
    }

    if (_controller.hasTransportError) {
      return _operatorTransportMessage();
    }

    return null;
  }

  Color _statusTypeColor(StatusBadgeType type) {
    return switch (type) {
      StatusBadgeType.normal => AppColors.textMuted,
      StatusBadgeType.active => AppColors.secondary,
      StatusBadgeType.ready => AppColors.success,
      StatusBadgeType.queued => AppColors.warning,
      StatusBadgeType.locked => AppColors.error,
      StatusBadgeType.error => AppColors.error,
      StatusBadgeType.disabled => AppColors.textMuted,
      StatusBadgeType.hover => AppColors.primary,
      StatusBadgeType.pressed => AppColors.primary,
      StatusBadgeType.selected => AppColors.primary,
    };
  }
}

class _ActionSlot {
  const _ActionSlot({
    required this.label,
    required this.subLabel,
    required this.icon,
    required this.semanticColor,
    required this.onPressed,
    required this.action,
    this.emergency = false,
    this.sponsorRelevant = false,
  });

  final String label;
  final String subLabel;
  final IconData icon;
  final Color semanticColor;
  final VoidCallback? onPressed;
  final LiveActionConfig? action;
  final bool emergency;
  final bool sponsorRelevant;
}

class _ActionSectionData {
  const _ActionSectionData(this.title, this.subtitle, this.slots);

  final String title;
  final String subtitle;
  final List<_ActionSlot> slots;
}

enum _ActionKeyState { ready, active, queued, blocked }

class _AnimatedDeskKey extends StatefulWidget {
  const _AnimatedDeskKey({
    required this.child,
    required this.enabled,
    required this.reducedMotion,
    required this.onTap,
  });

  final Widget child;
  final bool enabled;
  final bool reducedMotion;
  final VoidCallback? onTap;

  @override
  State<_AnimatedDeskKey> createState() => _AnimatedDeskKeyState();
}

class _AnimatedDeskKeyState extends State<_AnimatedDeskKey> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final scale = widget.reducedMotion
        ? 1.0
        : _pressed
            ? 0.985
            : _hovered
                ? 1.01
                : 1.0;

    return MouseRegion(
      cursor: widget.enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() {
        _hovered = false;
        _pressed = false;
      }),
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: widget.enabled ? (_) => setState(() => _pressed = true) : null,
        onTapUp: widget.enabled ? (_) => setState(() => _pressed = false) : null,
        onTapCancel: widget.enabled ? () => setState(() => _pressed = false) : null,
        child: TweenAnimationBuilder<double>(
          duration: widget.reducedMotion ? Duration.zero : AppDurations.fast,
          tween: Tween<double>(begin: 1, end: scale),
          builder: (context, value, child) {
            return Transform.scale(scale: value, child: child);
          },
          child: widget.child,
        ),
      ),
    );
  }
}
