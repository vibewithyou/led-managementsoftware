import 'package:flutter/material.dart';
import 'package:led_management_software/core/constants/app_spacing.dart';
import 'package:led_management_software/core/theme/app_colors.dart';
import 'package:led_management_software/core/theme/app_durations.dart';
import 'package:led_management_software/features/projects/controller/projects_controller.dart';
import 'package:led_management_software/features/projects/model/project_cue_option_model.dart';
import 'package:led_management_software/features/projects/model/project_item_model.dart';
import 'package:led_management_software/features/projects/widgets/project_card.dart';
import 'package:led_management_software/features/projects/widgets/project_form_dialog.dart';
import 'package:led_management_software/shared/widgets/layout/page_header.dart';
import 'package:led_management_software/shared/widgets/surfaces/app_panel.dart';
import 'package:led_management_software/shared/widgets/surfaces/status_badge.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  late final ProjectsController _controller;
  bool _showList = false;

  @override
  void initState() {
    super.initState();
    _controller = ProjectsController();
    _controller.load();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _showList = true;
      });
    });
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
        final projects = _controller.projects;

        return Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PageHeader(
                  title: 'Projekte',
                  description: 'Ein Projekt entspricht einem Spiel oder Event mit eigenen Clips und Cue-Einstellungen.',
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
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: AppPanel(
                          title: 'Projektliste',
                          trailing: Text('${projects.length} Projekte'),
                          child: _controller.isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : AnimatedOpacity(
                                  opacity: _showList ? 1 : 0,
                                  duration: AppDurations.slow,
                                  child: projects.isEmpty
                                      ? const Center(child: Text('Noch keine Projekte vorhanden.'))
                                      : GridView.builder(
                                          itemCount: projects.length,
                                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                            crossAxisSpacing: AppSpacing.md,
                                            mainAxisSpacing: AppSpacing.md,
                                            childAspectRatio: 1.35,
                                          ),
                                          itemBuilder: (_, index) {
                                            final project = projects[index];
                                            return ProjectCard(
                                              project: project,
                                              onSetActive: () => _controller.setActiveProject(project.id),
                                              onEdit: () => _openEditDialog(project),
                                              onDelete: () => _deleteProject(project.id),
                                            );
                                          },
                                        ),
                                ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: AppPanel(
                          title: 'Aktives Projekt',
                          child: _buildActiveProjectPanel(projects),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: FilledButton.icon(
                onPressed: _openCreateDialog,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Neues Projekt'),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildActiveProjectPanel(List<ProjectItemModel> projects) {
    final active = projects.where((item) => item.isActive).cast<ProjectItemModel?>().firstWhere(
          (item) => item != null,
          orElse: () => null,
        );

    if (active == null) {
      return const Center(child: Text('Kein aktives Projekt gesetzt.'));
    }

    final sponsorCue = _controller.cueById(active.sponsorLoopCueId);
    final fallbackCue = _controller.cueById(active.fallbackCueId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(active.name, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        Text('Gegner: ${active.opponent}'),
        Text('Datum: ${_formatDate(active.date)}'),
        Text('Halle: ${active.venue}'),
        Text('Clips: ${active.clipCount}'),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            StatusBadge(
              label: active.sponsorLoopCueId == null ? 'Sponsor Loop fehlt' : 'Sponsor Loop gesetzt',
              type: active.sponsorLoopCueId == null ? StatusBadgeType.error : StatusBadgeType.ready,
            ),
            StatusBadge(
              label: active.fallbackCueId == null ? 'Fallback fehlt' : 'Fallback gesetzt',
              type: active.fallbackCueId == null ? StatusBadgeType.error : StatusBadgeType.ready,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _buildCueDetailCard(
          title: 'Sponsor Loop Cue',
          cueId: active.sponsorLoopCueId,
          cue: sponsorCue,
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildCueDetailCard(
          title: 'Fallback Cue',
          cueId: active.fallbackCueId,
          cue: fallbackCue,
        ),
      ],
    );
  }

  Widget _buildCueDetailCard({
    required String title,
    required String? cueId,
    required ProjectCueOptionModel? cue,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: cue == null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: AppSpacing.xs),
                Text(cueId == null ? 'Nicht zugewiesen' : 'Clip nicht gefunden ($cueId)'),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: AppSpacing.xs),
                Text(cue.title, style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: AppSpacing.xs),
                Text('Kategorie: ${cue.categoryLabel}'),
                Text('Lock-Status: ${cue.lockStatusLabel}'),
              ],
            ),
    );
  }

  Future<void> _openCreateDialog() async {
    final result = await showDialog<ProjectFormResult>(
      context: context,
      builder: (_) => ProjectFormDialog(
        sponsorLoopOptions: _controller.sponsorLoopCueOptions,
        fallbackOptions: _controller.fallbackCueOptions,
      ),
    );

    if (result == null) {
      return;
    }

    await _controller.createProject(
      name: result.name,
      opponent: result.opponent,
      venue: result.venue,
      date: result.date,
      sponsorLoopCueId: result.sponsorLoopCueId,
      fallbackCueId: result.fallbackCueId,
    );
  }

  Future<void> _openEditDialog(ProjectItemModel project) async {
    final result = await showDialog<ProjectFormResult>(
      context: context,
      builder: (_) => ProjectFormDialog(
        sponsorLoopOptions: _controller.sponsorLoopCueOptions,
        fallbackOptions: _controller.fallbackCueOptions,
        initialProject: project,
      ),
    );

    if (result == null) {
      return;
    }

    await _controller.updateProject(
      ProjectItemModel(
        id: project.id,
        name: result.name,
        opponent: result.opponent,
        venue: result.venue,
        date: result.date,
        clipCount: project.clipCount,
        isActive: project.isActive,
        fallbackCueId: result.fallbackCueId,
        sponsorLoopCueId: result.sponsorLoopCueId,
        isConfigurationComplete: result.sponsorLoopCueId != null && result.fallbackCueId != null,
      ),
    );
  }

  Future<void> _deleteProject(String id) async {
    await _controller.deleteProject(id);
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day.$month.${date.year}';
  }
}
