import 'package:flutter/material.dart';
import 'package:led_management_software/core/constants/app_spacing.dart';
import 'package:led_management_software/core/theme/app_colors.dart';
import 'package:led_management_software/core/theme/app_durations.dart';
import 'package:led_management_software/features/projects/controller/projects_controller.dart';
import 'package:led_management_software/features/projects/model/project_item_model.dart';
import 'package:led_management_software/features/projects/widgets/project_card.dart';
import 'package:led_management_software/features/projects/widgets/project_form_dialog.dart';
import 'package:led_management_software/shared/widgets/layout/page_header.dart';
import 'package:led_management_software/shared/widgets/surfaces/app_panel.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  late final ProjectsController _controller;
  bool _showList = false;

  static const List<String> _mockCueIds = [
    'cue_sponsor_01',
    'cue_sponsor_02',
    'cue_fallback_01',
    'cue_fallback_02',
  ];

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(active.name, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        Text('Gegner: ${active.opponent}'),
        Text('Datum: ${_formatDate(active.date)}'),
        Text('Halle: ${active.venue}'),
        Text('Clips: ${active.clipCount}'),
        const SizedBox(height: AppSpacing.sm),
        Text('Sponsorloop: ${active.sponsorLoopCueId ?? '-'}'),
        Text('Fallback Cue: ${active.fallbackCueId ?? '-'}'),
      ],
    );
  }

  Future<void> _openCreateDialog() async {
    final result = await showDialog<ProjectFormResult>(
      context: context,
      builder: (_) => const ProjectFormDialog(availableCueIds: _mockCueIds),
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
      builder: (_) => ProjectFormDialog(availableCueIds: _mockCueIds, initialProject: project),
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
