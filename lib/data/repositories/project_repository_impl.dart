import 'package:led_management_software/data/models/project_model.dart';
import 'package:led_management_software/domain/entities/project.dart';
import 'package:led_management_software/domain/repositories/project_repository.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  final List<ProjectModel> _storage = [];

  @override
  Future<List<Project>> getAllProjects() async {
    _seedIfEmpty();
    return _storage.map((item) => item.toEntity()).toList(growable: false);
  }

  @override
  Future<Project?> getProjectById(String id) async {
    _seedIfEmpty();
    final model = _storage.where((item) => item.id == id).cast<ProjectModel?>().firstWhere(
          (item) => item != null,
          orElse: () => null,
        );
    return model?.toEntity();
  }

  @override
  Future<Project?> getActiveProject() async {
    _seedIfEmpty();
    final model = _storage.where((item) => item.isActive).cast<ProjectModel?>().firstWhere(
          (item) => item != null,
          orElse: () => null,
        );
    return model?.toEntity();
  }

  @override
  Future<void> setActiveProject(String id) async {
    _seedIfEmpty();
    for (var index = 0; index < _storage.length; index++) {
      final current = _storage[index];
      _storage[index] = ProjectModel.fromEntity(
        current.toEntity().copyWith(
              isActive: current.id == id,
              updatedAt: DateTime.now(),
            ),
      );
    }
  }

  @override
  Future<void> saveProject(Project project) async {
    _seedIfEmpty();
    final index = _storage.indexWhere((item) => item.id == project.id);
    final model = ProjectModel.fromEntity(project);
    if (index == -1) {
      _storage.add(model);
      return;
    }
    _storage[index] = model;
  }

  @override
  Future<void> deleteProject(String id) async {
    _seedIfEmpty();
    _storage.removeWhere((item) => item.id == id);

    if (_storage.isNotEmpty && !_storage.any((item) => item.isActive)) {
      final first = _storage.first;
      _storage[0] = ProjectModel.fromEntity(
        first.toEntity().copyWith(isActive: true, updatedAt: DateTime.now()),
      );
    }
  }

  void _seedIfEmpty() {
    if (_storage.isNotEmpty) {
      return;
    }

    final now = DateTime.now();
    _storage.addAll([
      ProjectModel(
        id: 'project_1',
        name: 'HBL Heimspiel 23',
        opponent: 'SG Blau-Weiß',
        venue: 'Arena Süd',
        date: DateTime(now.year, now.month, now.day + 1),
        fallbackCueId: 'cue_fallback_01',
        sponsorLoopCueId: 'cue_sponsor_01',
        clipCount: 18,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      ProjectModel(
        id: 'project_2',
        name: 'EHF Viertelfinale',
        opponent: 'HC Rhein',
        venue: 'Arena West',
        date: DateTime(now.year, now.month, now.day + 7),
        fallbackCueId: 'cue_fallback_02',
        sponsorLoopCueId: 'cue_sponsor_02',
        clipCount: 24,
        isActive: false,
        createdAt: now,
        updatedAt: now,
      ),
    ]);
  }
}
