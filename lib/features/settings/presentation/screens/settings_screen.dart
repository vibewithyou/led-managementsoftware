import 'package:flutter/material.dart';
import 'package:led_management_software/core/constants/app_spacing.dart';
import 'package:led_management_software/core/theme/app_colors.dart';
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

  @override
  void initState() {
    super.initState();
    _controller = SettingsController();
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
        final settings = _controller.playbackSettings;
        final hotkeys = _controller.hotkeyBindings;

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
                      child: ListView.separated(
                        itemCount: settings.length,
                        itemBuilder: (context, index) => SettingSwitchTile(item: settings[index]),
                        separatorBuilder: (context, index) => const Divider(),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        Expanded(
                          child: AppPanel(
                            title: 'Globale Hotkeys',
                            trailing: const StatusBadge(
                              label: 'DESKTOP',
                              type: StatusBadgeType.active,
                              compact: true,
                            ),
                            child: ListView.separated(
                              itemCount: hotkeys.length,
                              separatorBuilder: (context, index) => const Divider(),
                              itemBuilder: (context, index) {
                                final binding = hotkeys[index];
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(binding.eventLabel),
                                  subtitle: Text(binding.description),
                                  trailing: SizedBox(
                                    width: 120,
                                    child: DropdownButtonFormField<String>(
                                      initialValue: binding.shortcutLabel,
                                      decoration: const InputDecoration(
                                        isDense: true,
                                        border: OutlineInputBorder(),
                                      ),
                                      items: _controller.availableHotkeys
                                          .map(
                                            (hotkey) => DropdownMenuItem<String>(
                                              value: hotkey,
                                              child: Text(hotkey),
                                            ),
                                          )
                                          .toList(growable: false),
                                      onChanged: (value) {
                                        if (value == null) {
                                          return;
                                        }
                                        _controller.updateHotkey(binding.eventLabel, value);
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Expanded(
                          child: AppPanel(
                            title: 'UI / Operator',
                            child: Column(
                              children: [
                                const ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text('Quick-Trigger Hotkeys'),
                                  trailing: StatusBadge(label: 'ACTIVE', type: StatusBadgeType.active, compact: true),
                                ),
                                const ListTile(contentPadding: EdgeInsets.zero, title: Text('Große Bedienflächen'), trailing: Text('Desktop')),
                                const ListTile(contentPadding: EdgeInsets.zero, title: Text('Theme'), trailing: Text('Dark Pro')),
                                const SizedBox(height: AppSpacing.sm),
                                const EmptyStateCard(
                                  title: 'Konfiguration aktiv',
                                  message: 'Globale Funktionstasten sind für den Windows-Desktop registrierbar und entprellt.',
                                  icon: Icons.keyboard_command_key_rounded,
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Hinweis: Bei Doppelbelegung werden Hotkeys automatisch getauscht.',
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
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppPanel(
                      title: 'Output Profile',
                      child: Column(
                        children: const [
                          ListTile(contentPadding: EdgeInsets.zero, title: Text('Standard FPS'), trailing: Text('59.94')),
                          ListTile(contentPadding: EdgeInsets.zero, title: Text('Canvas'), trailing: Text('1920x240')),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text('Audio'),
                            trailing: StatusBadge(label: 'DISABLED', type: StatusBadgeType.disabled, compact: true),
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
}
