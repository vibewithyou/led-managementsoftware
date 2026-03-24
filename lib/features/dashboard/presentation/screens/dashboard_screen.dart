import 'package:flutter/material.dart';
import 'package:led_management_software/core/constants/app_spacing.dart';
import 'package:led_management_software/core/theme/app_colors.dart';
import 'package:led_management_software/app/routing/app_route.dart';
import 'package:led_management_software/features/dashboard/controller/dashboard_controller.dart';
import 'package:led_management_software/features/dashboard/widgets/dashboard_kpi_card.dart';
import 'package:led_management_software/shared/widgets/layout/page_header.dart';
import 'package:led_management_software/shared/widgets/surfaces/app_panel.dart';
import 'package:led_management_software/shared/widgets/surfaces/glass_panel.dart';
import 'package:led_management_software/shared/widgets/surfaces/status_badge.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final DashboardController _controller;

  @override
  void initState() {
    super.initState();
    _controller = DashboardController();
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
        final kpis = _controller.kpis;
        final alerts = _controller.alerts;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageHeader(
              title: 'Broadcast Dashboard',
              description: 'Live-Zentrale mit echten Systemdaten aus Projekten, Playback, Queue und Logs.',
            ),
            const SizedBox(height: AppSpacing.md),
            GlassPanel(
              child: Row(
                children: [
                  Expanded(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        _controller.activeProjectLabel,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text('Aktuelles Projekt • Letzte Aktion: ${_controller.lastActionLabel}'),
                    ),
                  ),
                  StatusBadge(
                    label: _controller.error == null ? 'LIVE MONITOR' : 'ERROR',
                    type: _controller.error == null ? StatusBadgeType.ready : StatusBadgeType.error,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (_controller.error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Text(
                  _controller.error!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.error),
                ),
              ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (_controller.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
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
                                title: 'Systemwarnungen',
                                child: alerts.isEmpty
                                    ? const Center(child: Text('Keine Warnungen. System bereit für den Livebetrieb.'))
                                    : ListView.separated(
                                        itemCount: alerts.length,
                                        itemBuilder: (_, index) {
                                          final isTransportError = alerts[index].toLowerCase().contains('transportfehler');
                                          return ListTile(
                                            contentPadding: EdgeInsets.zero,
                                            leading: Icon(
                                              isTransportError ? Icons.error_outline_rounded : Icons.warning_amber_rounded,
                                              color: isTransportError ? AppColors.error : AppColors.warning,
                                            ),
                                            title: Text(
                                              alerts[index],
                                              style: isTransportError
                                                  ? Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.error)
                                                  : null,
                                            ),
                                            subtitle: Row(
                                              children: [
                                                Text(isTransportError ? 'Priorität: Kritisch' : 'Priorität: Hoch'),
                                                const SizedBox(width: AppSpacing.xs),
                                                StatusBadge(
                                                  label: isTransportError ? 'ERROR' : 'CHECK',
                                                  type: isTransportError ? StatusBadgeType.error : StatusBadgeType.queued,
                                                  compact: true,
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                        separatorBuilder: (context, index) => const Divider(),
                                      ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: AppPanel(
                                title: 'Nächste Live-Relevanz',
                                child: ListView(
                                  children: [
                                    if (!_controller.hasActiveProject)
                                      Container(
                                        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                                        padding: const EdgeInsets.all(AppSpacing.sm),
                                        decoration: BoxDecoration(
                                          color: AppColors.surfaceMuted,
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: AppColors.border),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Setup-Empfehlung',
                                              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                                            ),
                                            const SizedBox(height: AppSpacing.xs),
                                            const Text('1) Projekt aktiv setzen\n2) Fallback + Sponsor-Loop zuweisen\n3) Live-Steuerung prüfen'),
                                            const SizedBox(height: AppSpacing.sm),
                                            OutlinedButton.icon(
                                              onPressed: () => Navigator.of(context).pushNamed(AppRoute.projects.path),
                                              icon: const Icon(Icons.folder_open_rounded),
                                              label: const Text('Zu Projekte wechseln'),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      title: const Text('Aktueller Cue'),
                                      subtitle: Text(_controller.currentCueLabel),
                                    ),
                                    const Divider(),
                                    ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      title: const Text('Queued Cues'),
                                      subtitle: Text(
                                        _controller.queuedCueLabels.isEmpty
                                            ? 'Keine Queue-Einträge'
                                            : _controller.queuedCueLabels.join(' • '),
                                      ),
                                    ),
                                    const Divider(),
                                    ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      title: const Text('Nächstes potenzielles Fallback'),
                                      subtitle: Text(_controller.fallbackLabel),
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
              ),
            ),
          ],
        );
      },
    );
  }
}
