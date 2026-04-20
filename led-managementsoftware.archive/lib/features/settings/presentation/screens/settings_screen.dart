import 'package:flutter/material.dart';
import 'package:led_management_software/core/constants/app_spacing.dart';
import 'package:led_management_software/core/theme/app_colors.dart';
import 'package:led_management_software/features/live_control/model/live_action_config.dart';
import 'package:led_management_software/features/settings/controller/settings_controller.dart';
import 'package:led_management_software/features/settings/model/setting_item_model.dart';
import 'package:led_management_software/features/settings/service/settings_service.dart';
import 'package:led_management_software/features/settings/widgets/setting_switch_tile.dart';
import 'package:led_management_software/shared/widgets/layout/page_header.dart';
import 'package:led_management_software/shared/widgets/surfaces/app_panel.dart';
import 'package:led_management_software/shared/widgets/surfaces/status_badge.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final SettingsController _controller;
  late final TextEditingController _vlcPathController;
  bool _advancedExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = SettingsController();
    _vlcPathController = TextEditingController(
      text: _controller.vlcExecutablePath,
    );
    _controller.addListener(_syncVlcPathField);
  }

  @override
  void dispose() {
    _controller.removeListener(_syncVlcPathField);
    _vlcPathController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _syncVlcPathField() {
    final path = _controller.vlcExecutablePath;
    if (_vlcPathController.text == path) {
      return;
    }
    _vlcPathController.value = _vlcPathController.value.copyWith(
      text: path,
      selection: TextSelection.collapsed(offset: path.length),
      composing: TextRange.empty,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final actions = _controller.liveActions;
        final playbackSettings = _controller.playbackSettings;
        final operatorSettings = _controller.operatorSettings;
        final conflicts = _controller.hotkeyConflicts;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageHeader(
              title: 'Einstellungen',
              description:
                  'Nur kritische Live-Parameter prominent, Details bei Bedarf.',
            ),
            const SizedBox(height: AppSpacing.md),
            _impactHeader(conflicts),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth >= 1400) {
                    return _wideLayout(
                      actions,
                      playbackSettings,
                      operatorSettings,
                      conflicts,
                    );
                  }
                  if (constraints.maxWidth >= 1050) {
                    return _mediumLayout(
                      actions,
                      playbackSettings,
                      operatorSettings,
                      conflicts,
                    );
                  }
                  return _compactLayout(
                    actions,
                    playbackSettings,
                    operatorSettings,
                    conflicts,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _impactHeader(Map<String, List<String>> conflicts) {
    final hasVlcPath = _controller.vlcExecutablePath.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.xs,
        children: [
          StatusBadge(
            label: conflicts.isEmpty
                ? 'HOTKEYS KONFLIKTFREI'
                : '${conflicts.length} HOTKEY-KONFLIKTE',
            type: conflicts.isEmpty
                ? StatusBadgeType.ready
                : StatusBadgeType.error,
            compact: true,
          ),
          StatusBadge(
            label: _controller.strictSponsorLock
                ? 'SPONSOR-LOCK STRIKT'
                : 'SPONSOR-LOCK OFFEN',
            type: _controller.strictSponsorLock
                ? StatusBadgeType.active
                : StatusBadgeType.queued,
            compact: true,
          ),
          StatusBadge(
            label: _controller.clearQueueOnStop
                ? 'STOP LOESCHT QUEUE'
                : 'STOP BEHAELT QUEUE',
            type: _controller.clearQueueOnStop
                ? StatusBadgeType.queued
                : StatusBadgeType.ready,
            compact: true,
          ),
          StatusBadge(
            label: hasVlcPath ? 'VLC PFAD FIXIERT' : 'VLC AUTO',
            type: hasVlcPath ? StatusBadgeType.hover : StatusBadgeType.ready,
            compact: true,
          ),
        ],
      ),
    );
  }

  Widget _wideLayout(
    List<LiveActionConfig> actions,
    List<SettingItemModel> playbackSettings,
    List<SettingItemModel> operatorSettings,
    Map<String, List<String>> conflicts,
  ) {
    return Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: Column(
                  children: [
                    Expanded(
                      child: AppPanel(
                        title: 'VLC / Playback (kritisch)',
                        child: _playbackPanel(playbackSettings),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Expanded(
                      child: AppPanel(
                        title: 'Operator / UI',
                        child: _operatorPanel(operatorSettings),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                flex: 6,
                child: AppPanel(
                  title: 'Hotkeys',
                  trailing: StatusBadge(
                    label: conflicts.isEmpty
                        ? 'KONFLIKTFREI'
                        : '${conflicts.length} KONFLIKTE',
                    type: conflicts.isEmpty
                        ? StatusBadgeType.ready
                        : StatusBadgeType.error,
                    compact: true,
                  ),
                  child: _hotkeysPanel(actions, conflicts),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _secondaryPanel(actions, conflicts),
      ],
    );
  }

  Widget _mediumLayout(
    List<LiveActionConfig> actions,
    List<SettingItemModel> playbackSettings,
    List<SettingItemModel> operatorSettings,
    Map<String, List<String>> conflicts,
  ) {
    return Column(
      children: [
        SizedBox(
          height: 260,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppPanel(
                  title: 'VLC / Playback (kritisch)',
                  child: _playbackPanel(playbackSettings),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppPanel(
                  title: 'Operator / UI',
                  child: _operatorPanel(operatorSettings),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Expanded(
          child: AppPanel(
            title: 'Hotkeys',
            trailing: StatusBadge(
              label: conflicts.isEmpty
                  ? 'KONFLIKTFREI'
                  : '${conflicts.length} KONFLIKTE',
              type: conflicts.isEmpty
                  ? StatusBadgeType.ready
                  : StatusBadgeType.error,
              compact: true,
            ),
            child: _hotkeysPanel(actions, conflicts),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _secondaryPanel(actions, conflicts),
      ],
    );
  }

  Widget _compactLayout(
    List<LiveActionConfig> actions,
    List<SettingItemModel> playbackSettings,
    List<SettingItemModel> operatorSettings,
    Map<String, List<String>> conflicts,
  ) {
    return ListView(
      children: [
        AppPanel(
          title: 'VLC / Playback (kritisch)',
          child: _playbackPanel(playbackSettings),
        ),
        const SizedBox(height: AppSpacing.md),
        AppPanel(
          title: 'Operator / UI',
          child: _operatorPanel(operatorSettings),
        ),
        const SizedBox(height: AppSpacing.md),
        AppPanel(
          title: 'Hotkeys',
          trailing: StatusBadge(
            label: conflicts.isEmpty
                ? 'KONFLIKTFREI'
                : '${conflicts.length} KONFLIKTE',
            type: conflicts.isEmpty
                ? StatusBadgeType.ready
                : StatusBadgeType.error,
            compact: true,
          ),
          child: _hotkeysPanel(actions, conflicts),
        ),
        const SizedBox(height: AppSpacing.md),
        _secondaryPanel(actions, conflicts),
      ],
    );
  }

  Widget _secondaryPanel(
    List<LiveActionConfig> actions,
    Map<String, List<String>> conflicts,
  ) {
    return AppPanel(
      title: 'Erweitert',
      trailing: IconButton(
        onPressed: () => setState(() => _advancedExpanded = !_advancedExpanded),
        icon: Icon(
          _advancedExpanded
              ? Icons.expand_less_rounded
              : Icons.expand_more_rounded,
        ),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        child: !_advancedExpanded
            ? Text(
                'Output-Profil, Wirkungsstatus und technische Details',
                key: const ValueKey('advanced_closed'),
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
              )
            : Column(
                key: const ValueKey('advanced_open'),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _outputPanel(actions, conflicts),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.08),
                      border: Border.all(
                        color: AppColors.warning.withValues(alpha: 0.6),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Hinweis: Grosse Bedienflaechen haben aktuell keine klar sichtbare Wirkung in der UI. Aktionsfarben/Sortierung sind im Service vorhanden, aber in diesem Screen derzeit nicht editierbar.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _hotkeysPanel(
    List<LiveActionConfig> actions,
    Map<String, List<String>> conflicts,
  ) {
    return SingleChildScrollView(
      child: Column(
        children: [
          for (var index = 0; index < actions.length; index++) ...[
            if (index > 0) const Divider(height: 1),
            _hotkeyTile(actions[index], index, conflicts),
          ],
        ],
      ),
    );
  }

  Widget _hotkeyTile(
    LiveActionConfig action,
    int index,
    Map<String, List<String>> conflicts,
  ) {
    final hotkey = action.hotkey ?? '-';
    final conflictForKey =
        conflicts[(action.hotkey ?? '').trim().toUpperCase()];
    final hasConflict = conflictForKey != null && conflictForKey.length > 1;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: _colorFor(action.color).withValues(alpha: 0.2),
        child: Text('${index + 1}'),
      ),
      title: Text(action.label),
      subtitle: Text(
        hasConflict
            ? 'Konflikt mit: ${conflictForKey.where((label) => label != action.label).join(', ')}'
            : 'Keine Konflikte',
      ),
      trailing: SizedBox(
        width: 220,
        child: Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: SettingsService.availableHotkeys.contains(hotkey)
                    ? hotkey
                    : SettingsService.availableHotkeys.first,
                isDense: true,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: SettingsService.availableHotkeys
                    .map(
                      (value) =>
                          DropdownMenuItem(value: value, child: Text(value)),
                    )
                    .toList(growable: false),
                onChanged: (value) {
                  if (value == null) return;
                  _controller.updateHotkey(action.label, value);
                },
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            StatusBadge(
              label: hasConflict
                  ? 'KONFLIKT'
                  : (hotkey == '-' ? 'INAKTIV' : 'AKTIV'),
              type: hasConflict
                  ? StatusBadgeType.error
                  : (hotkey == '-'
                        ? StatusBadgeType.disabled
                        : StatusBadgeType.active),
              compact: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _playbackPanel(List<SettingItemModel> playbackSettings) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _vlcPathController,
            decoration: const InputDecoration(
              labelText: 'VLC-Pfad (optional)',
              hintText:
                  'z.B. /usr/bin/vlc oder C:\\Program Files\\VideoLAN\\VLC\\vlc.exe',
            ),
            onSubmitted: _controller.updateVlcExecutablePath,
          ),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: () =>
                  _controller.updateVlcExecutablePath(_vlcPathController.text),
              icon: const Icon(Icons.save_rounded),
              label: const Text('VLC-Pfad speichern'),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          DropdownButtonFormField<FallbackBehavior>(
            initialValue: _controller.fallbackBehavior,
            decoration: const InputDecoration(
              labelText: 'Standard-Fallback-Verhalten',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(
                value: FallbackBehavior.sponsorLoop,
                child: Text('Nach Ende zu Sponsor-Loop zurueckkehren'),
              ),
              DropdownMenuItem(
                value: FallbackBehavior.stayIdle,
                child: Text('Nach Ende im Idle bleiben'),
              ),
            ],
            onChanged: (value) {
              if (value == null) return;
              _controller.updateFallbackBehavior(value);
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final item in playbackSettings) ...[
            SettingSwitchTile(
              item: item,
              onChanged: (value) =>
                  _controller.updatePlaybackToggle(item.id, value),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Text(
                item.id == 'strict_sponsor_lock'
                    ? 'Wirkt sofort im Ablaufverhalten bei Sperrclips.'
                    : 'Wirkt bei Stop-Aktionen direkt auf die Queue.',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
              ),
            ),
          ],
          if ((_controller.lastVlcError ?? '').isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.12),
                border: Border.all(color: AppColors.error),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Letzter VLC-Fehler:\n${_controller.lastVlcError!}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.error),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _operatorPanel(List<SettingItemModel> operatorSettings) {
    return SingleChildScrollView(
      child: Column(
        children: [
          for (final item in operatorSettings) ...[
            SettingSwitchTile(
              item: item,
              onChanged: (value) =>
                  _controller.updateOperatorToggle(item.id, value),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  item.id == 'reduced_animations'
                      ? 'Sichtbar in der Live-Steuerung durch reduzierte Bewegungen.'
                      : 'Derzeit ohne klar erkennbare UI-Wirkung im Projekt.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _outputPanel(
    List<LiveActionConfig> actions,
    Map<String, List<String>> conflicts,
  ) {
    final assigned = actions
        .where(
          (action) =>
              (action.hotkey ?? '').trim().isNotEmpty && action.hotkey != '-',
        )
        .length;
    final disabled = actions.where((action) => !action.enabled).length;

    return Column(
      children: [
        _metricRow(
          'Aktionsprofil',
          'Standard Liveprofil (${actions.length} Aktionen)',
        ),
        _metricRow('Hotkeys aktiv', '$assigned / ${actions.length}'),
        _metricRow('Hotkey-Konflikte', '${conflicts.length}'),
        _metricRow('Deaktivierte Aktionen', '$disabled'),
        _metricRow(
          'Fallback-Modus',
          _controller.fallbackBehavior == FallbackBehavior.sponsorLoop
              ? 'Sponsor-Loop'
              : 'Idle',
        ),
        _metricRow(
          'Queue nach Stop',
          _controller.clearQueueOnStop ? 'Ja' : 'Nein',
        ),
        _metricRow(
          'Sponsor-Lock strikt',
          _controller.strictSponsorLock ? 'Ja' : 'Nein',
        ),
        _metricRow(
          'VLC-Pfad',
          _controller.vlcExecutablePath.trim().isEmpty
              ? 'Auto-Erkennung'
              : _controller.vlcExecutablePath,
        ),
      ],
    );
  }

  Widget _metricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Color _colorFor(LiveActionColorSemantic semantic) {
    return switch (semantic) {
      LiveActionColorSemantic.success => AppColors.success,
      LiveActionColorSemantic.warning => AppColors.warning,
      LiveActionColorSemantic.danger => AppColors.error,
      LiveActionColorSemantic.neutral => AppColors.disabled,
      _ => AppColors.primary,
    };
  }
}
