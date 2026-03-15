import 'package:flutter/material.dart';
import 'package:led_management_software/core/constants/app_spacing.dart';
import 'package:led_management_software/features/dashboard/controller/dashboard_controller.dart';
import 'package:led_management_software/features/dashboard/widgets/dashboard_kpi_card.dart';
import 'package:led_management_software/shared/state/active_project_state.dart';
import 'package:led_management_software/shared/widgets/layout/page_header.dart';
import 'package:led_management_software/shared/widgets/surfaces/glass_panel.dart';
import 'package:led_management_software/shared/widgets/surfaces/app_panel.dart';
import 'package:led_management_software/shared/widgets/surfaces/status_badge.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = DashboardController();
    final activeProjectState = ActiveProjectState.instance;
    final kpis = controller.kpis;
    final alerts = controller.alerts;

    return AnimatedBuilder(
      animation: activeProjectState,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageHeader(
              title: 'Broadcast Dashboard',
              description: 'Zentrale Übersicht zu Outputs, Cue-Status und Systemqualität für den Livebetrieb.',
            ),
            if (!activeProjectState.hasActiveProject) ...[
              const SizedBox(height: AppSpacing.md),
              const GlassPanel(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.warning_amber_rounded, color: Colors.amberAccent),
                  title: Text('Kein aktives Projekt gesetzt'),
                  subtitle: Text('Bitte im Bereich „Projekte“ ein aktives Projekt auswählen.'),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            const GlassPanel(
              child: Row(
                children: [
                  Expanded(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('Matchday Profile: HBL Heimspiel', style: TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text('Arena Süd • Ausspielung 1920x240 • Scene Set A aktiv'),
                    ),
                  ),
                  StatusBadge(label: 'LIVE OK', type: StatusBadgeType.ready),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth > 1200
                      ? 4
                      : constraints.maxWidth > 800
                          ? 2
                          : 1;
                  final rows = (kpis.length / crossAxisCount).ceil();
                  final kpiHeight = rows * 142 + (rows - 1) * AppSpacing.md;

                  return Column(
                    children: [
                      SizedBox(
                        height: kpiHeight.toDouble(),
                        child: GridView.builder(
                          itemCount: kpis.length,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            mainAxisSpacing: AppSpacing.md,
                            crossAxisSpacing: AppSpacing.md,
                            childAspectRatio: 2.6,
                          ),
                          itemBuilder: (_, index) => DashboardKpiCard(item: kpis[index]),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: AppPanel(
                                title: 'Live-Warnungen',
                                child: ListView.separated(
                                  itemCount: alerts.length,
                                  itemBuilder: (_, index) => ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: const Icon(Icons.warning_amber_rounded),
                                    title: Text(alerts[index]),
                                    subtitle: const Row(
                                      children: [
                                        Text('Priorität: Mittel'),
                                        SizedBox(width: AppSpacing.xs),
                                        StatusBadge(label: 'QUEUED', type: StatusBadgeType.queued, compact: true),
                                      ],
                                    ),
                                  ),
                                  separatorBuilder: (context, index) => const Divider(),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: AppPanel(
                                title: 'Nächste Live-Aktionen',
                                child: ListView(
                                  children: const [
                                    ListTile(title: Text('Einlauf Clip - Heimteam'), subtitle: Text('T-00:08')),
                                    ListTile(title: Text('Sponsoren-Loop 16:9'), subtitle: Text('T-00:19')),
                                    ListTile(title: Text('Toranimation Standard'), subtitle: Text('T-00:44')),
                                    ListTile(title: Text('Halbzeit Teaser'), subtitle: Text('T-02:10')),
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
              ),
            ),
          ],
        );
      },
    );
  }
}
