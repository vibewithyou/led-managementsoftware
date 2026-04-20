import 'package:flutter/material.dart';
import 'package:led_managementsoftware_app/core/theme/app_colors.dart';
import 'package:led_managementsoftware_app/shared/widgets/surfaces/app_panel.dart';
import 'package:led_managementsoftware_app/shared/widgets/surfaces/status_badge.dart';

class LoggingScreen extends StatelessWidget {
  const LoggingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      title: 'Logging',
      subtitle: 'Live-Aktionen, Fehler und Sync-Konflikte mit Filterstruktur.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              StatusBadge(label: 'Live-Aktionen', tone: StatusBadgeTone.info),
              StatusBadge(label: 'Queue-Wechsel', tone: StatusBadgeTone.success),
              StatusBadge(label: 'Sync-Konflikte', tone: StatusBadgeTone.warning),
              StatusBadge(label: 'VLC-Fehler', tone: StatusBadgeTone.danger),
            ],
          ),
          const SizedBox(height: 16),
          for (final line in const [
            '18:59:12 · Queue-Wechsel · Szene TV on aktiv',
            '19:00:01 · Unterbrechung · Timeout Heim sofort',
            '19:00:14 · Rückkehr · Zurück auf Clipindex 4',
            '19:01:20 · Sync-Konflikt · Haupt-PC-Version übernommen',
          ])
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.backgroundRaised,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(line, style: const TextStyle(color: AppColors.textSoft)),
            ),
        ],
      ),
    );
  }
}
