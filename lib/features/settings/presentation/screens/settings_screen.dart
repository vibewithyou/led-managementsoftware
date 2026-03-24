import 'package:flutter/material.dart';
import 'package:led_management_software/core/constants/app_spacing.dart';
import 'package:led_management_software/core/theme/app_colors.dart';
import 'package:led_management_software/features/live_control/model/live_action_config.dart';
import 'package:led_management_software/features/settings/controller/settings_controller.dart';
import 'package:led_management_software/features/settings/widgets/setting_switch_tile.dart';
import 'package:led_management_software/shared/widgets/layout/page_header.dart';
import 'package:led_management_software/shared/widgets/surfaces/app_panel.dart';
import 'package:led_management_software/shared/widgets/surfaces/empty_state_card.dart';
import 'package:led_management_software/shared/widgets/surfaces/status_badge.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final SettingsController _controller;
  late final TextEditingController _vlcPathController;

  @override
  void initState() {
    super.initState();
    _controller = SettingsController();
    _vlcPathController = TextEditingController(text: _controller.vlcExecutablePath);
  }

  @override
  void dispose() {
    _vlcPathController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final settings = _controller.playbackSettings;
        final actions = _controller.liveActions;
        if (_vlcPathController.text != _controller.vlcExecutablePath) {
          _vlcPathController.text = _controller.vlcExecutablePath;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageHeader(
              title: 'Einstellungen',
              description: 'System-, Ausgabe- und Bedienoptionen für den stabilen Livebetrieb konfigurieren.',
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: AppPanel(
                      title: 'Playback Engine',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _vlcPathController,
                            decoration: const InputDecoration(
                              labelText: 'VLC Pfad (optional)',
                              hintText: 'z.B. /usr/bin/vlc oder C:\\Program Files\\VideoLAN\\VLC\\vlc.exe',
                            ),
                            onSubmitted: _controller.updateVlcExecutablePath,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: OutlinedButton.icon(
                              onPressed: () => _controller.updateVlcExecutablePath(_vlcPathController.text),
                              icon: const Icon(Icons.save_rounded),
                              label: const Text('VLC-Pfad speichern'),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          if ((_controller.lastVlcError ?? '').isNotEmpty)
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
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.error),
                              ),
                            ),
                          const SizedBox(height: AppSpacing.sm),
                          Expanded(
                            child: ListView.separated(
                              itemCount: settings.length,
                              itemBuilder: (context, index) => SettingSwitchTile(item: settings[index]),
                              separatorBuilder: (context, index) => const Divider(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    flex: 4,
                    child: AppPanel(
                      title: 'Live-Aktionen verwalten',
                      trailing: const StatusBadge(label: 'CONFIG', type: StatusBadgeType.active, compact: true),
                      child: ReorderableListView.builder(
                        itemCount: actions.length,
                        onReorder: _controller.reorderActions,
                        itemBuilder: (context, index) {
                          final action = actions[index];
                          return ListTile(
                            key: ValueKey(action.id),
                            contentPadding: EdgeInsets.zero,
                            title: Text(action.label),
                            subtitle: Text('Gruppe: ${action.group.name} • Queue: ${action.queueBehavior.name}'),
                            leading: CircleAvatar(
                              backgroundColor: _colorFor(action.color).withValues(alpha: 0.2),
                              child: Text('${index + 1}'),
                            ),
                            trailing: SizedBox(
                              width: 320,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      initialValue: action.hotkey,
                                      isDense: true,
                                      decoration: const InputDecoration(border: OutlineInputBorder()),
                                      items: _controller.availableHotkeys
                                          .map((hotkey) => DropdownMenuItem<String>(value: hotkey, child: Text(hotkey)))
                                          .toList(growable: false),
                                      onChanged: (value) {
                                        if (value == null) return;
                                        _controller.updateHotkey(action.label, value);
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  DropdownButton<LiveActionColorSemantic>(
                                    value: action.color,
                                    items: LiveActionColorSemantic.values
                                        .map(
                                          (value) => DropdownMenuItem(
                                            value: value,
                                            child: Text(value.name),
                                          ),
                                        )
                                        .toList(growable: false),
                                    onChanged: (value) {
                                      if (value == null) return;
                                      _controller.updateActionColor(action.id, value);
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                  Switch(
                                    value: action.enabled,
                                    onChanged: (value) => _controller.updateActionEnabled(action.id, value),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppPanel(
                      title: 'UI / Operator',
                      child: Column(
                        children: [
                          const EmptyStateCard(
                            title: 'Live-Aktionen konfigurierbar',
                            message: 'Reihenfolge, Aktivierung, Hotkeys und Farbsemantik werden lokal gespeichert.',
                            icon: Icons.tune_rounded,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Migration: Standard-Events werden beim ersten Laden automatisch erzeugt.',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                            ),
                          ),
                        ],
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
