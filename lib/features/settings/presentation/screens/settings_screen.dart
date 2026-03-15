import 'package:flutter/material.dart';
import 'package:led_management_software/core/constants/app_spacing.dart';
import 'package:led_management_software/features/settings/controller/settings_controller.dart';
import 'package:led_management_software/features/settings/widgets/setting_switch_tile.dart';
import 'package:led_management_software/shared/widgets/layout/page_header.dart';
import 'package:led_management_software/shared/widgets/surfaces/app_panel.dart';
import 'package:led_management_software/shared/widgets/surfaces/empty_state_card.dart';
import 'package:led_management_software/shared/widgets/surfaces/status_badge.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = SettingsController();
    final settings = controller.playbackSettings;

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
                    itemBuilder: (_, index) => SettingSwitchTile(item: settings[index]),
                    separatorBuilder: (_, __) => const Divider(),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: AppPanel(
                        title: 'Output Profile',
                        child: Column(
                          children: [
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
                    SizedBox(height: AppSpacing.md),
                    Expanded(
                      child: AppPanel(
                        title: 'UI / Operator',
                        child: Column(
                          children: [
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text('Quick-Trigger Hotkeys'),
                              trailing: StatusBadge(label: 'ACTIVE', type: StatusBadgeType.active, compact: true),
                            ),
                            ListTile(contentPadding: EdgeInsets.zero, title: Text('Große Bedienflächen'), trailing: Text('Desktop')),
                            ListTile(contentPadding: EdgeInsets.zero, title: Text('Theme'), trailing: Text('Dark Pro')),
                            SizedBox(height: AppSpacing.sm),
                            EmptyStateCard(
                              title: 'Keine Konflikte erkannt',
                              message: 'Alle UI-Voreinstellungen sind konsistent und bereit für Live-Betrieb.',
                              icon: Icons.verified_rounded,
                            ),
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
  }
}
