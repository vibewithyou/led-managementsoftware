import 'package:flutter/material.dart';
import 'package:led_management_software/core/constants/app_spacing.dart';
import 'package:led_management_software/core/theme/app_colors.dart';
import 'package:led_management_software/domain/enums/transport_status.dart';
import 'package:led_management_software/app/routing/app_route.dart';
import 'package:led_management_software/features/dashboard/controller/dashboard_controller.dart';
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
        return ExcludeSemantics(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PageHeader(
                title: 'Broadcast Dashboard',
                description: 'Aktives Projekt, Live-Readiness und Warnungen in einer fokussierten Übersicht.',
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: _controller.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          final compact = constraints.maxWidth < 1050;

                          return SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _projectHeader(context),
                                const SizedBox(height: AppSpacing.md),
                                if (_controller.error != null) _errorBanner(context),
                                _systemStatusPanel(context),
                                const SizedBox(height: AppSpacing.md),
                                if (compact)
                                  ..._stackedSections(context)
                                else
                                  _splitSections(context),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _projectHeader(BuildContext context) {
    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _controller.activeProjectLabel,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              StatusBadge(
                label: _controller.isLiveReady ? 'LIVE READY' : 'SETUP OFFEN',
                type: _controller.isLiveReady ? StatusBadgeType.ready : StatusBadgeType.queued,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Letzte wichtige Aktion: ${_controller.lastActionLabel}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _projectSwitcher(context),
              ),
              const SizedBox(width: AppSpacing.sm),
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).pushNamed(AppRoute.projects.path),
                icon: const Icon(Icons.settings_rounded),
                label: const Text('Projektverwaltung'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _projectSwitcher(BuildContext context) {
    final projects = _controller.projects;
    if (projects.isEmpty) {
      return const Text('Keine Projekte vorhanden');
    }

    return DropdownButtonFormField<String>(
      initialValue: _controller.activeProject?.id,
      decoration: const InputDecoration(
        labelText: 'Aktives Projekt',
        isDense: true,
      ),
      items: projects
          .map(
            (project) => DropdownMenuItem<String>(
              value: project.id,
              child: Text(project.name),
            ),
          )
          .toList(growable: false),
      onChanged: (value) {
        if (value == null) {
          return;
        }
        _controller.switchActiveProject(value);
      },
    );
  }

  Widget _errorBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.error),
        ),
        child: Text(
          _controller.error!,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.error),
        ),
      ),
    );
  }

  Widget _systemStatusPanel(BuildContext context) {
    final transportHealthy =
        _controller.transportStatus != TransportStatus.error && _controller.transportStatus != TransportStatus.fileMissing;
    return AppPanel(
      title: 'Systemstatus',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              StatusBadge(
                label: _controller.isLiveReady ? 'Projekt bereit' : 'Projekt nicht bereit',
                type: _controller.isLiveReady ? StatusBadgeType.ready : StatusBadgeType.queued,
                compact: true,
              ),
              StatusBadge(
                label: transportHealthy ? 'Transport stabil' : 'Transportfehler',
                type: transportHealthy ? StatusBadgeType.ready : StatusBadgeType.error,
                compact: true,
              ),
              StatusBadge(
                label: _controller.filesMissing ? 'Dateien fehlen' : 'Dateien ok',
                type: _controller.filesMissing ? StatusBadgeType.error : StatusBadgeType.ready,
                compact: true,
              ),
              StatusBadge(
                label: _controller.queuedCueLabels.isEmpty ? 'Queue leer' : '${_controller.queuedCueLabels.length} in Queue',
                type: _controller.queuedCueLabels.isEmpty ? StatusBadgeType.hover : StatusBadgeType.active,
                compact: true,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _controller.transportMessage,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  List<Widget> _stackedSections(BuildContext context) {
    return [
      _readinessPanel(context),
      const SizedBox(height: AppSpacing.md),
      _warningsPanel(context),
      const SizedBox(height: AppSpacing.md),
      _detailsPanel(context),
    ];
  }

  Widget _splitSections(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: _readinessPanel(context),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            children: [
              _warningsPanel(context),
              const SizedBox(height: AppSpacing.md),
              _detailsPanel(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _readinessPanel(BuildContext context) {
    final checks = _controller.readinessChecks;
    return AppPanel(
      title: 'Projekt-Readiness',
      child: Column(
        children: checks
            .map(
              (item) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  item.isHealthy ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
                  color: item.isHealthy ? AppColors.success : AppColors.warning,
                ),
                title: Text(item.label),
                subtitle: Text(item.detail),
                trailing: StatusBadge(
                  label: item.isHealthy ? 'OK' : 'PRÜFEN',
                  type: item.badgeType,
                  compact: true,
                ),
              ),
            )
            .toList(growable: false),
      ),
    );
  }

  Widget _warningsPanel(BuildContext context) {
    final alerts = _controller.alerts;
    if (alerts.isEmpty) {
      return AppPanel(
        title: 'Warnungen',
        child: Row(
          children: const [
            Icon(Icons.verified_rounded, color: AppColors.success),
            SizedBox(width: AppSpacing.sm),
            Expanded(child: Text('Keine offenen Warnungen.')),
          ],
        ),
      );
    }

    return AppPanel(
      title: 'Warnungen',
      child: Column(
        children: alerts
            .map(
              (alert) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  alert.toLowerCase().contains('transport') || alert.toLowerCase().contains('fehl')
                      ? Icons.error_outline_rounded
                      : Icons.warning_amber_rounded,
                  color: alert.toLowerCase().contains('transport') || alert.toLowerCase().contains('fehl')
                      ? AppColors.error
                      : AppColors.warning,
                ),
                title: Text(alert),
              ),
            )
            .toList(growable: false),
      ),
    );
  }

  Widget _detailsPanel(BuildContext context) {
    return AppPanel(
      title: 'Letzter Status',
      child: Material(
        type: MaterialType.transparency,
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          title: Text(_controller.currentCueLabel),
          subtitle: Text('Fallback: ${_controller.fallbackLabel}'),
          childrenPadding: const EdgeInsets.only(bottom: AppSpacing.sm),
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Letzte Aktion'),
              subtitle: Text(_controller.lastActionLabel),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Queue'),
              subtitle: Text(
                _controller.queuedCueLabels.isEmpty
                    ? 'Keine Queue-Einträge'
                    : _controller.queuedCueLabels.join(' • '),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
