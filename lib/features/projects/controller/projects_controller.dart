import 'package:flutter/foundation.dart';
import 'package:led_management_software/domain/entities/project.dart';
import 'package:led_management_software/features/projects/model/project_item_model.dart';
import 'package:led_management_software/features/projects/service/projects_service.dart';
import 'package:led_management_software/shared/state/active_project_state.dart';

class ProjectsController extends ChangeNotifier {
  ProjectsController({ProjectsService? service}) : _service = service ?? ProjectsService();

  final ProjectsService _service;
  final ActiveProjectState _activeProjectState = ActiveProjectState.instance;

  List<ProjectItemModel> _projects = const [];
  bool _isLoading = true;
  String? _error;

  List<ProjectItemModel> get projects => _projects;

  bool get isLoading => _isLoading;

  String? get error => _error;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _projects = await _service.loadProjects();
      await _syncGlobalActiveProject();
    } catch (exception) {
      _error = exception.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
    await _service.setActiveProject(id);
    await load();
  }

  Future<void> _syncGlobalActiveProject() async {
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
      ),
    );
  }
}
