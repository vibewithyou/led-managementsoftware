import 'package:flutter/material.dart';
import 'package:led_management_software/domain/entities/lineup_entry.dart';
import 'package:led_management_software/core/constants/app_spacing.dart';
import 'package:led_management_software/core/theme/app_colors.dart';
import 'package:led_management_software/domain/entities/project.dart';
import 'package:led_management_software/domain/enums/cue_type.dart';
import 'package:led_management_software/domain/enums/media_category.dart';
import 'package:led_management_software/domain/enums/team_type.dart';
import 'package:led_management_software/features/intro_players/controller/intro_players_controller.dart';
import 'package:led_management_software/features/intro_players/widgets/player_intro_card.dart';
import 'package:led_management_software/features/projects/controller/projects_controller.dart';
import 'package:led_management_software/features/projects/model/project_cue_option_model.dart';
import 'package:led_management_software/features/projects/model/project_item_model.dart';
import 'package:led_management_software/features/projects/widgets/project_card.dart';
import 'package:led_management_software/features/projects/widgets/project_clip_picker_sheet.dart';
import 'package:led_management_software/features/projects/widgets/project_clip_slot_section.dart';
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
  late final IntroPlayersController _lineupController;
  String? _selectedProjectId;

  @override
  void initState() {
    super.initState();
    _controller = ProjectsController();
    _lineupController = IntroPlayersController();
    _controller.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    _lineupController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final projects = _controller.projects;
        final selectedProject = _resolveSelectedProject(projects);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageHeader(
              title: 'Projekte',
              description: 'Zentrale Vorbereitung je Event mit Basisdaten, Clips, Spielerlisten und Live-Ready-Status.',
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                const Spacer(),
                FilledButton.icon(
                  onPressed: _openCreateDialog,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Neues Projekt'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (_controller.error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Text(
                  _controller.error!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.error),
                ),
              ),
            Expanded(
              child: _controller.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final compact = constraints.maxWidth < 1050;
                        return compact
                            ? Column(
                                children: [
                                  Expanded(
                                    flex: 5,
                                    child: _buildProjectListPanel(projects, constraints.maxWidth),
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  Expanded(
                                    flex: 6,
                                    child: _buildProjectDetailPanel(selectedProject),
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  Expanded(
                                    flex: constraints.maxWidth >= 1400 ? 4 : 5,
                                    child: _buildProjectListPanel(projects, constraints.maxWidth),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    flex: constraints.maxWidth >= 1400 ? 5 : 4,
                                    child: _buildProjectDetailPanel(selectedProject),
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

  ProjectItemModel? _resolveSelectedProject(List<ProjectItemModel> projects) {
    if (projects.isEmpty) {
      return null;
    }

    final selected = projects.where((item) => item.id == _selectedProjectId).cast<ProjectItemModel?>().firstWhere(
          (item) => item != null,
          orElse: () => null,
        );
    if (selected != null) {
      return selected;
    }

    return projects.where((item) => item.isActive).cast<ProjectItemModel?>().firstWhere(
          (item) => item != null,
          orElse: () => projects.first,
        );
  }

  Widget _buildProjectListPanel(List<ProjectItemModel> projects, double width) {
    final crossAxisCount = width >= 1550
        ? 3
        : width >= 1280
            ? 2
            : 1;

    return AppPanel(
      title: 'Projektliste',
      trailing: Text('${projects.length} Projekte'),
      child: projects.isEmpty
          ? const Center(child: Text('Noch keine Projekte vorhanden.'))
          : GridView.builder(
              itemCount: projects.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
                childAspectRatio: crossAxisCount == 1 ? 2.1 : 1.45,
              ),
              itemBuilder: (_, index) {
                final project = projects[index];
                final status = _controller.statusForProject(project.id);
                return ProjectCard(
                  project: project,
                  isSelected: _selectedProjectId == project.id,
                  isLiveReady: status?.isLiveReady ?? project.isConfigurationComplete,
                  homePlayersCount: status?.homePlayersCount ?? 0,
                  guestPlayersCount: status?.guestPlayersCount ?? 0,
                  onSelect: () {
                    setState(() => _selectedProjectId = project.id);
                    _lineupController.loadForProject(project.id);
                  },
                  onSetActive: () async {
                    await _controller.setActiveProject(project.id);
                    if (!mounted) {
                      return;
                    }
                    setState(() => _selectedProjectId = project.id);
                    _lineupController.loadForProject(project.id);
                  },
                  onEdit: () => _openEditDialog(project),
                  onDelete: () => _deleteProject(project.id),
                );
              },
            ),
    );
  }

  Widget _buildProjectDetailPanel(ProjectItemModel? project) {
    if (project == null) {
      return const AppPanel(
        title: 'Projektdetail',
        child: Center(child: Text('Kein Projekt ausgewählt.')),
      );
    }

    final status = _controller.statusForProject(project.id);

    return AppPanel(
      title: 'Projektdetail',
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          StatusBadge(
            label: (status?.isLiveReady ?? false) ? 'LIVE READY' : 'SETUP OFFEN',
            type: (status?.isLiveReady ?? false) ? StatusBadgeType.ready : StatusBadgeType.queued,
            compact: true,
          ),
          const SizedBox(width: AppSpacing.xs),
          IconButton(
            tooltip: 'Projekt bearbeiten',
            onPressed: () => _openEditDialog(project),
            icon: const Icon(Icons.edit_rounded, size: 18),
          ),
        ],
      ),
      child: DefaultTabController(
        length: 5,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'Überblick'),
                Tab(text: 'Basisclips'),
                Tab(text: 'Eventclips'),
                Tab(text: 'Spielerstatus'),
                Tab(text: 'Live-Ready'),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: TabBarView(
                children: [
                  _buildOverviewTab(project, status),
                  _buildBaseClipsTab(project),
                  _buildEventClipsTab(project),
                  _buildPlayerStatusTab(status),
                  _buildLiveReadyTab(status),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab(ProjectItemModel project, ProjectPreparationStatus? status) {
    final baseReady = status?.hasBaseSlotsReady ?? false;
    final eventReady = status?.hasEventSlotsReady ?? false;
    final playerReady = status?.hasPlayerClipsReady ?? false;

    return ListView(
      children: [
        Text(project.name, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.xs),
        Text('Gegner: ${project.opponent}'),
        Text('Datum: ${_formatDate(project.date)}'),
        Text('Halle: ${project.venue}'),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            StatusBadge(
              label: baseReady ? 'Basisclips bereit' : 'Basisclips offen',
              type: baseReady ? StatusBadgeType.ready : StatusBadgeType.error,
              compact: true,
            ),
            StatusBadge(
              label: eventReady ? 'Eventclips bereit' : 'Eventclips offen',
              type: eventReady ? StatusBadgeType.ready : StatusBadgeType.queued,
              compact: true,
            ),
            StatusBadge(
              label: playerReady ? 'Spielerclips bereit' : 'Spielerclips offen',
              type: playerReady ? StatusBadgeType.ready : StatusBadgeType.queued,
              compact: true,
            ),
            StatusBadge(
              label: status?.isLiveReady ?? false ? 'Live Ready' : 'Setup offen',
              type: status?.isLiveReady ?? false ? StatusBadgeType.ready : StatusBadgeType.active,
              compact: true,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Text('Spielerclipstatus', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: AppSpacing.sm),
        _buildLineupStatusCard(
          title: 'Heim',
          count: status?.homePlayersCount ?? 0,
          completeCount: status?.homeCompletePlayersCount ?? 0,
          incompleteCount: status?.homeIncompletePlayersCount ?? 0,
          missingRefs: status?.homeMissingCueReferences ?? 0,
          missingAssignments: status?.homeMissingClipAssignments ?? 0,
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildLineupStatusCard(
          title: 'Gast',
          count: status?.guestPlayersCount ?? 0,
          completeCount: status?.guestCompletePlayersCount ?? 0,
          incompleteCount: status?.guestIncompletePlayersCount ?? 0,
          missingRefs: status?.guestMissingCueReferences ?? 0,
          missingAssignments: status?.guestMissingClipAssignments ?? 0,
        ),
      ],
    );
  }

  Widget _buildBaseClipsTab(ProjectItemModel project) {
    return ListView(
      children: [
        ProjectClipSlotSection(
          title: 'Kernclips',
          description: 'Pflichtslots für sichere Ausspielung sowie optionales Intro.',
          slots: const [
            ProjectCueSlot.sponsorLoop,
            ProjectCueSlot.fallback,
            ProjectCueSlot.intro,
          ],
          project: project,
          cueLookup: _controller.cueById,
          onAssign: (slot) => _editSlot(project, slot),
          onChange: (slot) => _editSlot(project, slot),
          onRemove: (slot) => _clearSlot(project, slot),
        ),
        const SizedBox(height: AppSpacing.md),
        ProjectClipSlotSection(
          title: 'Ablauf und Flow',
          slots: const [
            ProjectCueSlot.wiper,
            ProjectCueSlot.halftime,
            ProjectCueSlot.gameEnd,
          ],
          project: project,
          cueLookup: _controller.cueById,
          onAssign: (slot) => _editSlot(project, slot),
          onChange: (slot) => _editSlot(project, slot),
          onRemove: (slot) => _clearSlot(project, slot),
        ),
      ],
    );
  }

  Widget _buildEventClipsTab(ProjectItemModel project) {
    return ListView(
      children: [
        ProjectClipSlotSection(
          title: 'Spielereignisse',
          description: 'Direkte Trigger für Spielsituationen.',
          slots: const [
            ProjectCueSlot.goal,
            ProjectCueSlot.yellowCard,
            ProjectCueSlot.redCard,
            ProjectCueSlot.penalty,
            ProjectCueSlot.sevenMeter,
          ],
          project: project,
          cueLookup: _controller.cueById,
          onAssign: (slot) => _editSlot(project, slot),
          onChange: (slot) => _editSlot(project, slot),
          onRemove: (slot) => _clearSlot(project, slot),
        ),
        const SizedBox(height: AppSpacing.md),
        ProjectClipSlotSection(
          title: 'Timeout und Flow',
          slots: const [
            ProjectCueSlot.timeoutHome,
            ProjectCueSlot.timeoutGuest,
          ],
          project: project,
          cueLookup: _controller.cueById,
          onAssign: (slot) => _editSlot(project, slot),
          onChange: (slot) => _editSlot(project, slot),
          onRemove: (slot) => _clearSlot(project, slot),
        ),
      ],
    );
  }

  List<ProjectCueOptionModel> _optionsForSlot(ProjectCueSlot slot) {
    return switch (slot) {
      ProjectCueSlot.sponsorLoop => _controller.sponsorLoopCueOptions,
      ProjectCueSlot.fallback => _controller.fallbackCueOptions,
      _ => _sortedBySlotRelevance(_controller.allCueOptions, slot),
    };
  }

  List<ProjectCueOptionModel> _sortedBySlotRelevance(
    List<ProjectCueOptionModel> options,
    ProjectCueSlot slot,
  ) {
    final result = options.toList(growable: false);
    result.sort((a, b) {
      final scoreA = _slotRelevanceScore(a, slot);
      final scoreB = _slotRelevanceScore(b, slot);
      if (scoreA != scoreB) {
        return scoreB.compareTo(scoreA);
      }
      return a.title.toLowerCase().compareTo(b.title.toLowerCase());
    });
    return result;
  }

  int _slotRelevanceScore(ProjectCueOptionModel option, ProjectCueSlot slot) {
    return switch (slot) {
      ProjectCueSlot.goal ||
      ProjectCueSlot.yellowCard ||
      ProjectCueSlot.redCard ||
      ProjectCueSlot.penalty ||
      ProjectCueSlot.sevenMeter ||
      ProjectCueSlot.timeoutHome ||
      ProjectCueSlot.timeoutGuest ||
      ProjectCueSlot.wiper =>
        (option.category == MediaCategory.event ? 4 : 0) +
            (option.cueType == CueType.event ? 3 : 0) +
            (option.cueType == CueType.oneShot ? 2 : 0) +
            (option.category == MediaCategory.general ? 1 : 0),
      ProjectCueSlot.halftime =>
        (option.category == MediaCategory.halftime ? 5 : 0) +
            (option.category == MediaCategory.postgame ? 1 : 0) +
            (option.cueType == CueType.loop ? 1 : 0),
      ProjectCueSlot.gameEnd =>
        (option.category == MediaCategory.postgame ? 5 : 0) +
            (option.category == MediaCategory.event ? 2 : 0) +
            (option.category == MediaCategory.emergency ? 1 : 0) +
            (option.cueType == CueType.oneShot ? 1 : 0),
      _ => 0,
    };
  }

  Widget _buildPlayerStatusTab(ProjectPreparationStatus? status) {
    return AnimatedBuilder(
      animation: _lineupController,
      builder: (context, _) {
        if (_lineupController.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        final allItems = _lineupController.allItems;
        final homeItems = allItems.where((e) => e.entry.teamType == TeamType.home).toList();
        final guestItems = allItems.where((e) => e.entry.teamType == TeamType.guest).toList();

        if (allItems.isEmpty) {
          return Center(
            child: Text(
              'Keine Spielerclips konfiguriert.\nSpieler über „Intro / Spieler" hinzufügen.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
            ),
          );
        }

        return ListView(
          children: [
            Text('Teamstatus', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            _buildLineupStatusCard(
              title: 'Heim',
              count: status?.homePlayersCount ?? homeItems.length,
              completeCount: status?.homeCompletePlayersCount ?? homeItems.length,
              incompleteCount: status?.homeIncompletePlayersCount ?? 0,
              missingRefs: status?.homeMissingCueReferences ?? 0,
              missingAssignments: status?.homeMissingClipAssignments ?? 0,
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildLineupStatusCard(
              title: 'Gast',
              count: status?.guestPlayersCount ?? guestItems.length,
              completeCount: status?.guestCompletePlayersCount ?? guestItems.length,
              incompleteCount: status?.guestIncompletePlayersCount ?? 0,
              missingRefs: status?.guestMissingCueReferences ?? 0,
              missingAssignments: status?.guestMissingClipAssignments ?? 0,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Spielerliste bearbeiten',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            if (homeItems.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: Text('Heim', style: Theme.of(context).textTheme.titleSmall),
              ),
              ...homeItems.asMap().entries.map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: PlayerIntroCard(
                    key: ValueKey(e.value.entry.id),
                    item: e.value,
                    orderIndex: e.key,
                    onDelete: () async {
                      await _lineupController.deletePlayer(e.value.entry.id);
                    },
                    onToggleActive: (val) async {
                      await _lineupController.updatePlayer(
                        e.value.entry.copyWith(isActive: val),
                      );
                    },
                    onAssignClip: () => _assignOrChangePlayerClip(e.value.entry),
                    onChangeClip: () => _assignOrChangePlayerClip(e.value.entry),
                    onRemoveClip: () => _clearPlayerClip(e.value.entry),
                  ),
                ),
              ),
            ],
            if (guestItems.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: Text('Gast', style: Theme.of(context).textTheme.titleSmall),
              ),
              ...guestItems.asMap().entries.map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: PlayerIntroCard(
                    key: ValueKey(e.value.entry.id),
                    item: e.value,
                    orderIndex: e.key,
                    onDelete: () async {
                      await _lineupController.deletePlayer(e.value.entry.id);
                    },
                    onToggleActive: (val) async {
                      await _lineupController.updatePlayer(
                        e.value.entry.copyWith(isActive: val),
                      );
                    },
                    onAssignClip: () => _assignOrChangePlayerClip(e.value.entry),
                    onChangeClip: () => _assignOrChangePlayerClip(e.value.entry),
                    onRemoveClip: () => _clearPlayerClip(e.value.entry),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildLiveReadyTab(ProjectPreparationStatus? status) {
    final missingBaseSlots = status?.missingBaseSlots ?? const <ProjectCueSlot>[];
    final missingEventSlots = status?.missingEventSlots ?? const <ProjectCueSlot>[];

    final checks = <({String label, bool ok, String detail, int? tabIndex})>[
      (
        label: 'Sponsor-Loop gesetzt',
        ok: status?.sponsorSet ?? false,
        detail: status?.sponsorSet ?? false ? 'Konfiguriert' : 'Bitte Sponsor-Loop zuweisen',
        tabIndex: 1,
      ),
      (
        label: 'Fallback gesetzt',
        ok: status?.fallbackSet ?? false,
        detail: status?.fallbackSet ?? false ? 'Konfiguriert' : 'Bitte Fallback zuweisen',
        tabIndex: 1,
      ),
      (
        label: 'Basisclips vollständig',
        ok: missingBaseSlots.isEmpty,
        detail: missingBaseSlots.isEmpty
            ? 'Alle Basisclips gesetzt'
            : 'Fehlend: ${missingBaseSlots.map((slot) => slot.label).join(', ')}',
        tabIndex: 1,
      ),
      (
        label: 'Eventclips vollständig',
        ok: missingEventSlots.isEmpty,
        detail: missingEventSlots.isEmpty
            ? 'Alle Eventclips gesetzt'
            : 'Fehlend: ${missingEventSlots.map((slot) => slot.label).join(', ')}',
        tabIndex: 2,
      ),
      (
        label: 'Spielerclips Heim vorhanden',
        ok: (status?.hasHomeLineup ?? false),
        detail: (status?.hasHomeLineup ?? false)
            ? '${status?.homePlayersCount ?? 0} Spieler'
            : 'Keine Heimspieler erfasst',
        tabIndex: 3,
      ),
      (
        label: 'Spielerclips Gast vorhanden',
        ok: (status?.hasGuestLineup ?? false),
        detail: (status?.hasGuestLineup ?? false)
            ? '${status?.guestPlayersCount ?? 0} Spieler'
            : 'Keine Gastspieler erfasst',
        tabIndex: 3,
      ),
      (
        label: 'Spielerclips referenzierbar',
        ok: status?.hasPlayerClipReferences ?? false,
        detail: status?.hasPlayerClipReferences ?? false
            ? 'Alle Spielerclips vorhanden'
            : 'Fehlende Referenzen Heim: ${status?.homeMissingCueReferences ?? 0}, Gast: ${status?.guestMissingCueReferences ?? 0}',
        tabIndex: 3,
      ),
      (
        label: 'Spielerclips zugewiesen',
        ok: status?.hasPlayerClipAssignments ?? false,
        detail: status?.hasPlayerClipAssignments ?? false
            ? 'Alle Spieler haben Intro-Clips'
            : 'Fehlende Zuweisungen Heim: ${status?.homeMissingClipAssignments ?? 0}, Gast: ${status?.guestMissingClipAssignments ?? 0}',
        tabIndex: 3,
      ),
      (
        label: 'Dateireferenzen gültig',
        ok: !(status?.hasMissingFiles ?? true),
        detail: !(status?.hasMissingFiles ?? true)
            ? 'Keine fehlenden Referenzen'
            : 'Fehlende Clips in Slots/Spielerlisten vorhanden',
        tabIndex: null,
      ),
      (
        label: 'Live-Ready',
        ok: status?.isLiveReady ?? false,
        detail: status?.isLiveReady ?? false ? 'Projekt kann live eingesetzt werden' : 'Live-Setup noch unvollständig',
        tabIndex: null,
      ),
    ];

    return ListView.separated(
      itemCount: checks.length,
      itemBuilder: (context, index) {
        final check = checks[index];
        final canNavigate = !check.ok && check.tabIndex != null;
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(
            check.ok ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
            color: check.ok ? AppColors.success : AppColors.warning,
          ),
          title: Text(check.label),
          subtitle: Text(check.detail),
          trailing: StatusBadge(
            label: check.ok ? 'OK' : 'OFFEN',
            type: check.ok ? StatusBadgeType.ready : StatusBadgeType.queued,
            compact: true,
          ),
          onTap: canNavigate
              ? () => DefaultTabController.of(context).animateTo(check.tabIndex!)
              : null,
        );
      },
      separatorBuilder: (context, index) => const Divider(),
    );
  }

  Widget _buildLineupStatusCard({
    required String title,
    required int count,
    required int completeCount,
    required int incompleteCount,
    required int missingRefs,
    required int missingAssignments,
  }) {
    final hasPlayers = count > 0;
    final healthy = hasPlayers && missingRefs == 0 && missingAssignments == 0;
    final detail = !hasPlayers
        ? 'Keine Spieler eingetragen'
        : 'Vollständig: $completeCount · Unvollständig: $incompleteCount';

    final issueDetail = <String>[
      if (missingAssignments > 0) '$missingAssignments ohne Clip',
      if (missingRefs > 0) '$missingRefs ungültige Referenz',
    ].join(' · ');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: AppSpacing.xxs),
                Text(detail),
                if (issueDetail.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    issueDetail,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.warning),
                  ),
                ],
              ],
            ),
          ),
          StatusBadge(
            label: healthy ? 'OK' : 'PRÜFEN',
            type: healthy ? StatusBadgeType.ready : StatusBadgeType.queued,
            compact: true,
          ),
        ],
      ),
    );
  }

  Future<void> _openCreateDialog() async {
    final result = await showDialog<ProjectFormResult>(
      context: context,
      builder: (_) => ProjectFormDialog(
        allCueOptions: _controller.allCueOptions,
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
      cueAssignments: result.cueAssignments,
    );
  }

  Future<void> _openEditDialog(ProjectItemModel project) async {
    final result = await showDialog<ProjectFormResult>(
      context: context,
      builder: (_) => ProjectFormDialog(
        allCueOptions: _controller.allCueOptions,
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
        fallbackCueId: result.cueIdForSlot(ProjectCueSlot.fallback),
        sponsorLoopCueId: result.cueIdForSlot(ProjectCueSlot.sponsorLoop),
        introCueId: result.cueIdForSlot(ProjectCueSlot.intro),
        goalCueId: result.cueIdForSlot(ProjectCueSlot.goal),
        yellowCardCueId: result.cueIdForSlot(ProjectCueSlot.yellowCard),
        redCardCueId: result.cueIdForSlot(ProjectCueSlot.redCard),
        penaltyCueId: result.cueIdForSlot(ProjectCueSlot.penalty),
        sevenMeterCueId: result.cueIdForSlot(ProjectCueSlot.sevenMeter),
        timeoutHomeCueId: result.cueIdForSlot(ProjectCueSlot.timeoutHome),
        timeoutGuestCueId: result.cueIdForSlot(ProjectCueSlot.timeoutGuest),
        wiperCueId: result.cueIdForSlot(ProjectCueSlot.wiper),
        halftimeCueId: result.cueIdForSlot(ProjectCueSlot.halftime),
        gameEndCueId: result.cueIdForSlot(ProjectCueSlot.gameEnd),
        isConfigurationComplete: Project.requiredSlots.every((slot) => result.cueIdForSlot(slot) != null),
      ),
    );
  }

  Future<void> _editSlot(ProjectItemModel project, ProjectCueSlot slot) async {
    final result = await showProjectClipPicker(
      context,
      slot: slot,
      currentCueId: project.cueIdForSlot(slot),
      options: _optionsForSlot(slot),
    );
    if (result == null) return;
    await _controller.updateSingleSlot(
      project.id,
      slot,
      result.isEmpty ? null : result,
    );
  }

  Future<void> _clearSlot(ProjectItemModel project, ProjectCueSlot slot) async {
    await _controller.updateSingleSlot(project.id, slot, null);
  }

  Future<void> _assignOrChangePlayerClip(LineupEntry entry) async {
    final result = await showProjectClipPicker(
      context,
      slot: ProjectCueSlot.intro,
      currentCueId: entry.introCueId,
      options: _playerIntroOptions(entry.teamType),
    );
    if (result == null) {
      return;
    }

    await _lineupController.updatePlayer(
      entry.copyWith(introCueId: result.isEmpty ? null : result),
    );
  }

  Future<void> _clearPlayerClip(LineupEntry entry) async {
    await _lineupController.updatePlayer(entry.copyWith(introCueId: null));
  }

  List<ProjectCueOptionModel> _playerIntroOptions(TeamType teamType) {
    final options = _controller.allCueOptions.toList(growable: false);
    options.sort((a, b) {
      final scoreA = _playerIntroScore(a, teamType);
      final scoreB = _playerIntroScore(b, teamType);
      if (scoreA != scoreB) {
        return scoreB.compareTo(scoreA);
      }
      return a.title.toLowerCase().compareTo(b.title.toLowerCase());
    });
    return options;
  }

  int _playerIntroScore(ProjectCueOptionModel option, TeamType teamType) {
    final teamCategory = teamType == TeamType.home ? MediaCategory.introHome : MediaCategory.introGuest;
    return (option.category == MediaCategory.player ? 5 : 0) +
        (option.category == teamCategory ? 4 : 0) +
        (option.category == MediaCategory.general ? 2 : 0) +
        (option.cueType == CueType.oneShot ? 1 : 0);
  }


  Future<void> _deleteProject(String id) async {
    await _controller.deleteProject(id);
    if (!mounted) {
      return;
    }
    if (_selectedProjectId == id) {
      setState(() => _selectedProjectId = null);
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day.$month.${date.year}';
  }
}
