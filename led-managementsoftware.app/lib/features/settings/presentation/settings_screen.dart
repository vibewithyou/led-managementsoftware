import 'package:flutter/material.dart';
import 'package:led_managementsoftware_app/core/config/app_demo_data.dart';
import 'package:led_managementsoftware_app/core/theme/app_colors.dart';
import 'package:led_managementsoftware_app/shared/widgets/surfaces/app_panel.dart';
import 'package:led_managementsoftware_app/shared/widgets/surfaces/status_badge.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final List<bool> _values;

  @override
  void initState() {
    super.initState();
    _values = AppDemoData.settings.map((setting) => setting.value).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppPanel(
            title: 'Systemeinstellungen',
            subtitle: 'Teil 1 setzt die sichtbaren Bereiche für Gerät, Playback, Regeln, Sync, Speicher und Diagnose.',
            child: const Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                StatusBadge(label: 'Haupt-PC-Modus', tone: StatusBadgeTone.success),
                StatusBadge(label: 'Sponsorregel aktiv', tone: StatusBadgeTone.warning),
                StatusBadge(label: 'Backend-Diagnose vorbereitet', tone: StatusBadgeTone.info),
              ],
            ),
          ),
          const SizedBox(height: 18),
          AppPanel(
            title: 'Schalter & Regeln',
            subtitle: 'Die wichtigsten Live-relevanten Flags bleiben direkt sichtbar und schnell erreichbar.',
            child: Column(
              children: [
                for (var index = 0; index < AppDemoData.settings.length; index++)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundRaised,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(AppDemoData.settings[index].title, style: const TextStyle(fontWeight: FontWeight.w700)),
                              const SizedBox(height: 4),
                              Text(
                                AppDemoData.settings[index].description,
                                style: const TextStyle(color: AppColors.textMuted, height: 1.45),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _values[index],
                          onChanged: (value) {
                            setState(() {
                              _values[index] = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          AppPanel(
            title: 'Bereiche',
            subtitle: 'Einstellungen bleiben nach Produktvorgabe in klare Bedienblöcke gegliedert.',
            child: const Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _SettingArea(title: 'Allgemein', detail: 'Gerätename, Haupt-PC-Modus, Warnverhalten'),
                _SettingArea(title: 'Wiedergabe / VLC', detail: 'Playback-Quelle, Status und späterer Verbindungscheck'),
                _SettingArea(title: 'Live-Regeln', detail: 'Sponsorlogik, Prioritäten und spätere Unterbrechungsregeln'),
                _SettingArea(title: 'Sync', detail: 'Online-Status, letzter Abgleich und Gerätekonflikte'),
                _SettingArea(title: 'Speicher', detail: 'Offline-Cache, Medienpfade und lokale Vollständigkeit'),
                _SettingArea(title: 'Logging', detail: 'Live-Protokolle, Fehlerpfade und Backend-Diagnose'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingArea extends StatelessWidget {
  const _SettingArea({required this.title, required this.detail});

  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.backgroundRaised,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(detail, style: const TextStyle(color: AppColors.textMuted, height: 1.45)),
            ],
          ),
        ),
      ),
    );
  }
}