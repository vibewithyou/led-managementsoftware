import 'package:flutter/material.dart';
import 'package:led_managementsoftware_app/core/config/app_demo_data.dart';
import 'package:led_managementsoftware_app/core/theme/app_colors.dart';
import 'package:led_managementsoftware_app/shared/widgets/buttons/action_tile_button.dart';
import 'package:led_managementsoftware_app/shared/widgets/cards/metric_card.dart';
import 'package:led_managementsoftware_app/shared/widgets/surfaces/app_panel.dart';
import 'package:led_managementsoftware_app/shared/widgets/surfaces/status_badge.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 1160;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _heroBlock(context),
              const SizedBox(height: 18),
              _metricGrid(),
              const SizedBox(height: 18),
              if (compact) ...[
                _quickActionsPanel(context),
                const SizedBox(height: 18),
                _alertsPanel(),
                const SizedBox(height: 18),
                _modulePanel(),
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          _quickActionsPanel(context),
                          const SizedBox(height: 18),
                          _alertsPanel(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(flex: 2, child: _modulePanel()),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _heroBlock(BuildContext context) {
    return AppPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              StatusBadge(label: 'Aktives Projekt live', tone: StatusBadgeTone.success),
              StatusBadge(label: 'Nächstes Projekt priorisiert', tone: StatusBadgeTone.info),
            ],
          ),
          const SizedBox(height: 18),
          Text('Regieoberfläche für die komplette Spielsteuerung', style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 10),
          Text(
            'Das Dashboard bündelt aktives Projekt, nächstes Event, Warnungen und die Systemmodule für Live, Playback, Offline und Logging in einer belastbaren Startansicht.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _projectCard('Aktives Projekt', AppDemoData.activeProject, StatusBadgeTone.success),
              _projectCard('Nächstes Projekt', AppDemoData.nextProject, StatusBadgeTone.info),
            ],
          ),
        ],
      ),
    );
  }

  Widget _projectCard(String label, ProjectSnapshot project, StatusBadgeTone tone) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 300, maxWidth: 420),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.backgroundRaised,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StatusBadge(label: label, tone: tone),
            const SizedBox(height: 14),
            Text(project.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(project.matchup, style: const TextStyle(color: AppColors.textSoft)),
            const SizedBox(height: 8),
            Text('${project.location} · ${project.dateLabel}', style: const TextStyle(color: AppColors.textMuted)),
            const SizedBox(height: 10),
            Text(project.note, style: const TextStyle(color: AppColors.textMuted, height: 1.45)),
          ],
        ),
      ),
    );
  }

  Widget _metricGrid() {
    return Wrap(
      spacing: 18,
      runSpacing: 18,
      children: [
        for (final metric in AppDemoData.dashboardMetrics)
          SizedBox(
            width: 240,
            child: AppPanel(
              child: MetricCard(
                title: metric.label,
                value: metric.value,
                subtitle: metric.detail,
              ),
            ),
          ),
      ],
    );
  }

  Widget _quickActionsPanel(BuildContext context) {
    return AppPanel(
      title: 'Schnellaktionen',
      subtitle: 'Direktzugriff auf die wichtigsten Live-Befehle aus dem Dashboard.',
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          for (final action in AppDemoData.quickActions)
            SizedBox(
              width: 170,
              child: ActionTileButton(
                label: action.player == null ? action.label : '${action.label}\n${action.player}',
                color: action.side == 'Heim' ? AppColors.primary : AppColors.warning,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Schnellaktion "${action.label}" an Live-Control gesendet.')),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _alertsPanel() {
    return AppPanel(
      title: 'Warnungen',
      subtitle: 'Hinweise, die vor oder während eines Spiels sichtbar bleiben müssen.',
      child: Column(
        children: [
          for (final alert in AppDemoData.alerts)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.backgroundRaised,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: StatusBadge(label: alert.title, tone: alert.tone, compact: true),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(alert.message, style: const TextStyle(color: AppColors.textSoft, height: 1.45)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _modulePanel() {
    return AppPanel(
      title: 'Systemmodule',
      subtitle: 'Teil 1 bündelt die Hauptbereiche und macht alle Kernmodule sichtbar, auch wenn sie später fachlich vertieft werden.',
      child: Wrap(
        spacing: 14,
        runSpacing: 14,
        children: [
          for (final module in AppDemoData.systemModules)
            SizedBox(
              width: 280,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.backgroundRaised,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: module.color.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(module.icon, color: module.color),
                    ),
                    const SizedBox(height: 12),
                    Text(module.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Text(module.description, style: const TextStyle(color: AppColors.textMuted, height: 1.45)),
                    const SizedBox(height: 12),
                    for (final item in module.items)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(color: module.color, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: Text(item, style: const TextStyle(color: AppColors.textSoft))),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}