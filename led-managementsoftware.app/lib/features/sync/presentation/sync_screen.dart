import 'package:flutter/material.dart';
import 'package:led_managementsoftware_app/core/theme/app_colors.dart';
import 'package:led_managementsoftware_app/shared/widgets/cards/metric_card.dart';
import 'package:led_managementsoftware_app/shared/widgets/surfaces/app_panel.dart';
import 'package:led_managementsoftware_app/shared/widgets/surfaces/status_badge.dart';

class SyncScreen extends StatelessWidget {
  const SyncScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      title: 'Sync',
      subtitle: 'Offline-First mit Konflikterkennung und Haupt-PC-Priorität.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              StatusBadge(label: 'Projekt: synchron', tone: StatusBadgeTone.success),
              StatusBadge(label: 'Medien: ausstehend', tone: StatusBadgeTone.warning),
              StatusBadge(label: 'Gerät: Haupt-PC gewinnt', tone: StatusBadgeTone.info),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: const [
              SizedBox(width: 220, child: MetricCard(title: 'Letzter Sync', value: 'vor 2 min')),
              SizedBox(width: 220, child: MetricCard(title: 'Konflikte', value: '1', subtitle: 'automatisch gelöst')),
              SizedBox(width: 220, child: MetricCard(title: 'Nebengeräte', value: '2', subtitle: 'werden angepasst')),
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
            child: const Text(
              'Konfliktablauf: Unterschiedliche Version erkannt -> Haupt-PC-Version übernehmen -> Nebengeräte auf neuen Stand bringen.',
              style: TextStyle(color: AppColors.textSoft, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}
