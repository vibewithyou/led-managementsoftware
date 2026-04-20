import 'package:flutter/foundation.dart';
import 'package:led_management_software/data/repositories/lineup_repository_impl.dart';
import 'package:led_management_software/domain/entities/project.dart';
import 'package:led_management_software/domain/enums/team_type.dart';
import 'package:led_management_software/features/projects/model/project_cue_option_model.dart';
import 'package:led_management_software/features/projects/model/project_item_model.dart';
import 'package:led_management_software/features/projects/service/projects_service.dart';
import 'package:led_management_software/shared/state/active_project_state.dart';

class ProjectsController extends ChangeNotifier {
  ProjectsController({ProjectsService? service, LineupRepositoryImpl? lineupRepository})
      : _service = service ?? ProjectsService(),
        _lineupRepository = lineupRepository ?? LineupRepositoryImpl();

  final ProjectsService _service;
  final LineupRepositoryImpl _lineupRepository;
  final ActiveProjectState _activeProjectState = ActiveProjectState.instance;

  List<ProjectItemModel> _projects = const [];
  List<ProjectCueOptionModel> _allCueOptions = const [];
  List<ProjectCueOptionModel> _sponsorLoopCueOptions = const [];
  List<ProjectCueOptionModel> _fallbackCueOptions = const [];
  Map<String, ProjectCueOptionModel> _cueOptionById = const {};
  Map<String, ProjectPreparationStatus> _statusByProjectId = const {};
  bool _isLoading = true;
  bool _isCueLoading = true;
  String? _error;

  List<ProjectItemModel> get projects => _projects;

  List<ProjectCueOptionModel> get allCueOptions => _allCueOptions;

  List<ProjectCueOptionModel> get sponsorLoopCueOptions => _sponsorLoopCueOptions;

  List<ProjectCueOptionModel> get fallbackCueOptions => _fallbackCueOptions;

  bool get isLoading => _isLoading;

  bool get isCueLoading => _isCueLoading;

  String? get error => _error;

  ProjectPreparationStatus? statusForProject(String projectId) => _statusByProjectId[projectId];

  ProjectCueOptionModel? cueById(String? cueId) {
    if (cueId == null || cueId.isEmpty) {
      return null;
    }
    return _cueOptionById[cueId];
  }

  Future<void> load() async {
    _isLoading = true;
    _isCueLoading = true;
    _error = null;
    notifyListeners();

    final errors = <String>[];

    try {
      _projects = await _service.loadProjects();
    } catch (exception) {
      errors.add('Projekte konnten nicht geladen werden: $exception');
      _projects = const [];
    } finally {
      _isLoading = false;
    }

    try {
      final cueCatalog = await _service.loadProjectCueCatalog();
      _allCueOptions = cueCatalog.allCueOptions;
      _sponsorLoopCueOptions = cueCatalog.sponsorLoopOptions;
      _fallbackCueOptions = cueCatalog.fallbackOptions;
      _cueOptionById = {
        for (final cue in cueCatalog.allCueOptions) cue.id: cue,
      };
    } catch (exception) {
      errors.add('Clips konnten nicht geladen werden: $exception');
      _allCueOptions = const [];
      _sponsorLoopCueOptions = const [];
      _fallbackCueOptions = const [];
      _cueOptionById = const {};
    } finally {
      _isCueLoading = false;
    }

    if (errors.isNotEmpty) {
      _error = errors.join('\n');
    }

    _statusByProjectId = await _buildStatuses(_projects);

    await _syncGlobalActiveProject();
    notifyListeners();
  }

  Future<void> createProject({
    required String name,
    required String opponent,
    required String venue,
    required DateTime date,
    required Map<ProjectCueSlot, String?> cueAssignments,
  }) async {
    await _service.createProject(
      name: name,
      opponent: opponent,
      venue: venue,
      date: date,
      cueAssignments: cueAssignments,
    );
    await load();
  }

  Future<void> updateProject(ProjectItemModel model) async {
    await _service.updateProject(model);
    await load();
  }

  Future<void> deleteProject(String id) async {
    await _service.deleteProject(id);
    await load();
  }

  Future<void> updateSingleSlot(
    String projectId,
    ProjectCueSlot slot,
    String? cueId,
  ) async {
    final project = _projects
        .where((p) => p.id == projectId)
        .cast<ProjectItemModel?>()
        .firstWhere((p) => p != null, orElse: () => null);
    if (project == null) return;
    await _service.updateProject(project.withSlot(slot, cueId));
    await load();
  }

  Future<void> setActiveProject(String id) async {
    _error = null;
    notifyListeners();

    try {
      await _service.setActiveProject(id);
      await _syncGlobalActiveProject();
      await load();
    } catch (exception) {
      _error = 'Aktives Projekt konnte nicht gesetzt werden: $exception';
      notifyListeners();
    }
  }

  Future<void> _syncGlobalActiveProject() async {
    try {
      final active = await _service.getActiveProject();
      if (active == null) {
        _activeProjectState.clear();
        return;
      }

      _activeProjectState.setActiveProject(
        Project(
          id: active.id,
          name: active.name,
          opponent: active.opponent,
          venue: active.venue,
          date: active.date,
          fallbackCueId: active.fallbackCueId,
          sponsorLoopCueId: active.sponsorLoopCueId,
          introCueId: active.introCueId,
          goalCueId: active.goalCueId,
          yellowCardCueId: active.yellowCardCueId,
          redCardCueId: active.redCardCueId,
          penaltyCueId: active.penaltyCueId,
          sevenMeterCueId: active.sevenMeterCueId,
          timeoutHomeCueId: active.timeoutHomeCueId,
          timeoutGuestCueId: active.timeoutGuestCueId,
          wiperCueId: active.wiperCueId,
          halftimeCueId: active.halftimeCueId,
          gameEndCueId: active.gameEndCueId,
          clipCount: active.clipCount,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isActive: active.isActive,
          isConfigurationComplete: active.isConfigurationComplete,
        ),
      );
    } catch (exception) {
      _activeProjectState.clear();
      _error = 'Aktiver Projektstatus konnte nicht synchronisiert werden: $exception';
    }
  }

  Future<Map<String, ProjectPreparationStatus>> _buildStatuses(List<ProjectItemModel> projects) async {
    final result = <String, ProjectPreparationStatus>{};
    const baseSlots = [
      ProjectCueSlot.sponsorLoop,
      ProjectCueSlot.fallback,
      ProjectCueSlot.wiper,
      ProjectCueSlot.halftime,
      ProjectCueSlot.gameEnd,
    ];
    const eventSlots = [
      ProjectCueSlot.goal,
      ProjectCueSlot.yellowCard,
      ProjectCueSlot.redCard,
      ProjectCueSlot.penalty,
      ProjectCueSlot.sevenMeter,
      ProjectCueSlot.timeoutHome,
      ProjectCueSlot.timeoutGuest,
    ];

    for (final project in projects) {
      final missingSlotAssignments = <ProjectCueSlot>[];
      final missingSlotReferences = <ProjectCueSlot>[];
      final missingBaseSlots = <ProjectCueSlot>[];
      final missingEventSlots = <ProjectCueSlot>[];

      for (final slot in Project.requiredSlots) {
        final cueId = project.cueIdForSlot(slot);
        if (cueId == null || cueId.trim().isEmpty) {
          missingSlotAssignments.add(slot);
          if (baseSlots.contains(slot)) {
            missingBaseSlots.add(slot);
          }
          if (eventSlots.contains(slot)) {
            missingEventSlots.add(slot);
          }
          continue;
        }

        if (!_cueOptionById.containsKey(cueId)) {
          missingSlotReferences.add(slot);
        }
      }

      final homeEntries = await _lineupRepository.getLineupForTeam(projectId: project.id, teamType: TeamType.home);
      final guestEntries = await _lineupRepository.getLineupForTeam(projectId: project.id, teamType: TeamType.guest);

      final homeMissingReferences = homeEntries.where((entry) {
        final cueId = entry.introCueId;
        return cueId != null && cueId.trim().isNotEmpty && !_cueOptionById.containsKey(cueId);
      }).length;
      final homeMissingAssignments = homeEntries.where((entry) {
        final cueId = entry.introCueId;
        return cueId == null || cueId.trim().isEmpty;
      }).length;

      final guestMissingReferences = guestEntries.where((entry) {
        final cueId = entry.introCueId;
        return cueId != null && cueId.trim().isNotEmpty && !_cueOptionById.containsKey(cueId);
      }).length;
      final guestMissingAssignments = guestEntries.where((entry) {
        final cueId = entry.introCueId;
        return cueId == null || cueId.trim().isEmpty;
      }).length;

      final hasHomeLineup = homeEntries.isNotEmpty;
      final hasGuestLineup = guestEntries.isNotEmpty;
      final sponsorSet = project.sponsorLoopCueId != null && project.sponsorLoopCueId!.trim().isNotEmpty;
      final fallbackSet = project.fallbackCueId != null && project.fallbackCueId!.trim().isNotEmpty;
      final hasMissingFiles =
          missingSlotReferences.isNotEmpty || homeMissingReferences > 0 || guestMissingReferences > 0;

      final isLiveReady =
          sponsorSet && fallbackSet && missingSlotAssignments.isEmpty && !hasMissingFiles && hasHomeLineup && hasGuestLineup;

      result[project.id] = ProjectPreparationStatus(
        projectId: project.id,
        sponsorSet: sponsorSet,
        fallbackSet: fallbackSet,
        missingSlotAssignments: missingSlotAssignments,
        missingSlotReferences: missingSlotReferences,
        missingBaseSlots: missingBaseSlots,
        missingEventSlots: missingEventSlots,
        homePlayersCount: homeEntries.length,
        guestPlayersCount: guestEntries.length,
        homeMissingClipAssignments: homeMissingAssignments,
        guestMissingClipAssignments: guestMissingAssignments,
        homeMissingCueReferences: homeMissingReferences,
        guestMissingCueReferences: guestMissingReferences,
        isLiveReady: isLiveReady,
      );
    }

    return result;
  }
}

class ProjectPreparationStatus {
  const ProjectPreparationStatus({
    required this.projectId,
    required this.sponsorSet,
    required this.fallbackSet,
    required this.missingSlotAssignments,
    required this.missingSlotReferences,
    required this.missingBaseSlots,
    required this.missingEventSlots,
    required this.homePlayersCount,
    required this.guestPlayersCount,
    required this.homeMissingClipAssignments,
    required this.guestMissingClipAssignments,
    required this.homeMissingCueReferences,
    required this.guestMissingCueReferences,
    required this.isLiveReady,
  });

  final String projectId;
  final bool sponsorSet;
  final bool fallbackSet;
  final List<ProjectCueSlot> missingSlotAssignments;
  final List<ProjectCueSlot> missingSlotReferences;
  final List<ProjectCueSlot> missingBaseSlots;
  final List<ProjectCueSlot> missingEventSlots;
  final int homePlayersCount;
  final int guestPlayersCount;
  final int homeMissingClipAssignments;
  final int guestMissingClipAssignments;
  final int homeMissingCueReferences;
  final int guestMissingCueReferences;
  final bool isLiveReady;

  bool get hasHomeLineup => homePlayersCount > 0;
  bool get hasGuestLineup => guestPlayersCount > 0;
  bool get hasBaseSlotsReady => missingBaseSlots.isEmpty;
  bool get hasEventSlotsReady => missingEventSlots.isEmpty;
  bool get hasPlayerClipAssignments => homeMissingClipAssignments == 0 && guestMissingClipAssignments == 0;
  bool get hasPlayerClipReferences => homeMissingCueReferences == 0 && guestMissingCueReferences == 0;
  bool get hasPlayerClipsReady => hasHomeLineup && hasGuestLineup && hasPlayerClipAssignments && hasPlayerClipReferences;

  int get homeIncompletePlayersCount => homeMissingClipAssignments + homeMissingCueReferences;
  int get guestIncompletePlayersCount => guestMissingClipAssignments + guestMissingCueReferences;
  int get homeCompletePlayersCount => (homePlayersCount - homeIncompletePlayersCount).clamp(0, homePlayersCount);
  int get guestCompletePlayersCount => (guestPlayersCount - guestIncompletePlayersCount).clamp(0, guestPlayersCount);

  bool get hasMissingFiles => missingSlotReferences.isNotEmpty || homeMissingCueReferences > 0 || guestMissingCueReferences > 0;
  bool get hasMissingAssignments => missingSlotAssignments.isNotEmpty;
}
