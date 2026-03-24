import 'package:flutter/foundation.dart';
import 'package:led_management_software/domain/entities/project.dart';
import 'package:led_management_software/features/projects/model/project_cue_option_model.dart';
import 'package:led_management_software/features/projects/model/project_item_model.dart';
import 'package:led_management_software/features/projects/service/projects_service.dart';
import 'package:led_management_software/shared/state/active_project_state.dart';

class ProjectsController extends ChangeNotifier {
  ProjectsController({ProjectsService? service}) : _service = service ?? ProjectsService();

  final ProjectsService _service;
  final ActiveProjectState _activeProjectState = ActiveProjectState.instance;

  List<ProjectItemModel> _projects = const [];
  List<ProjectCueOptionModel> _sponsorLoopCueOptions = const [];
  List<ProjectCueOptionModel> _fallbackCueOptions = const [];
  Map<String, ProjectCueOptionModel> _cueOptionById = const {};
  bool _isLoading = true;
  bool _isCueLoading = true;
  String? _error;

  List<ProjectItemModel> get projects => _projects;

  List<ProjectCueOptionModel> get sponsorLoopCueOptions => _sponsorLoopCueOptions;

  List<ProjectCueOptionModel> get fallbackCueOptions => _fallbackCueOptions;

  bool get isLoading => _isLoading;

  bool get isCueLoading => _isCueLoading;

  String? get error => _error;

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
      _sponsorLoopCueOptions = cueCatalog.sponsorLoopOptions;
      _fallbackCueOptions = cueCatalog.fallbackOptions;
      _cueOptionById = {
        for (final cue in cueCatalog.allCueOptions) cue.id: cue,
      };
    } catch (exception) {
      errors.add('Clips konnten nicht geladen werden: $exception');
      _sponsorLoopCueOptions = const [];
      _fallbackCueOptions = const [];
      _cueOptionById = const {};
    } finally {
      _isCueLoading = false;
    }

    if (errors.isNotEmpty) {
      _error = errors.join('\n');
    }

    await _syncGlobalActiveProject();
    notifyListeners();
  }

  Future<void> createProject({
    required String name,
    required String opponent,
    required String venue,
    required DateTime date,
    String? sponsorLoopCueId,
    String? fallbackCueId,
  }) async {
    await _service.createProject(
      name: name,
      opponent: opponent,
      venue: venue,
      date: date,
      sponsorLoopCueId: sponsorLoopCueId,
      fallbackCueId: fallbackCueId,
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
}
