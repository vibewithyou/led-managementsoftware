import 'package:led_management_software/data/repositories/media_repository_impl.dart';
import 'package:led_management_software/data/repositories/project_repository_impl.dart';
import 'package:led_management_software/domain/entities/media_asset.dart';
import 'package:led_management_software/domain/entities/project.dart';
import 'package:led_management_software/domain/enums/cue_type.dart';
import 'package:led_management_software/domain/enums/media_category.dart';
import 'package:led_management_software/domain/repositories/media_repository.dart';
import 'package:led_management_software/domain/repositories/project_repository.dart';
import 'package:led_management_software/features/projects/model/project_cue_option_model.dart';
import 'package:led_management_software/features/projects/model/project_item_model.dart';

class ProjectsService {
  ProjectsService({ProjectRepository? repository, MediaRepository? mediaRepository})
      : _repository = repository ?? ProjectRepositoryImpl(),
        _mediaRepository = mediaRepository ?? MediaRepositoryImpl();

  final ProjectRepository _repository;
  final MediaRepository _mediaRepository;

  Future<List<ProjectItemModel>> loadProjects() async {
    final projects = await _repository.getAllProjects();
    return projects
        .map(
          (project) => ProjectItemModel(
            id: project.id,
            name: project.name,
            opponent: project.opponent,
            venue: project.venue,
            date: project.date,
            clipCount: project.clipCount,
            isActive: project.isActive,
            fallbackCueId: project.fallbackCueId,
            sponsorLoopCueId: project.sponsorLoopCueId,
            isConfigurationComplete: project.isConfigurationComplete,
          ),
        )
        .toList(growable: false);
  }

  Future<ProjectCueCatalogModel> loadProjectCueCatalog() async {
    final allAssets = await _mediaRepository.getAllMediaAssets();
    final activeAssets = allAssets.where((asset) => asset.isActive).toList(growable: false);

    final allCueOptions = activeAssets.map(_toCueOption).toList(growable: false);
    final sponsorOptions = _sortByRelevance(
      activeAssets.where(_isSponsorLoopCandidate).map(_toCueOption).toList(growable: false),
      type: ProjectCueAssignmentType.sponsorLoop,
    );
    final fallbackOptions = _sortByRelevance(
      activeAssets.where(_isFallbackCandidate).map(_toCueOption).toList(growable: false),
      type: ProjectCueAssignmentType.fallback,
    );

    return ProjectCueCatalogModel(
      allCueOptions: allCueOptions,
      sponsorLoopOptions: sponsorOptions,
      fallbackOptions: fallbackOptions,
    );
  }

  Future<void> createProject({
    required String name,
    required String opponent,
    required String venue,
    required DateTime date,
    String? sponsorLoopCueId,
    String? fallbackCueId,
  }) async {
    final now = DateTime.now();
    final project = Project(
      id: 'project_${now.microsecondsSinceEpoch}',
      name: name,
      opponent: opponent,
      venue: venue,
      date: date,
      fallbackCueId: _normalizeOptional(sponsorOrFallbackId: fallbackCueId),
      sponsorLoopCueId: _normalizeOptional(sponsorOrFallbackId: sponsorLoopCueId),
      clipCount: 0,
      createdAt: now,
      updatedAt: now,
      isActive: false,
      isConfigurationComplete: _isProjectConfigurationComplete(
        sponsorLoopCueId: sponsorLoopCueId,
        fallbackCueId: fallbackCueId,
      ),
    );
    await _repository.saveProject(project);
  }

  Future<void> updateProject(ProjectItemModel model) async {
    final current = await _repository.getProjectById(model.id);
    if (current == null) {
      return;
    }

    await _repository.saveProject(
      current.copyWith(
        name: model.name,
        opponent: model.opponent,
        venue: model.venue,
        date: model.date,
        fallbackCueId: _normalizeOptional(sponsorOrFallbackId: model.fallbackCueId),
        sponsorLoopCueId: _normalizeOptional(sponsorOrFallbackId: model.sponsorLoopCueId),
        isConfigurationComplete: _isProjectConfigurationComplete(
          sponsorLoopCueId: model.sponsorLoopCueId,
          fallbackCueId: model.fallbackCueId,
        ),
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> deleteProject(String id) {
    return _repository.deleteProject(id);
  }

  Future<void> setActiveProject(String id) {
    return _repository.setActiveProject(id);
  }

  Future<ProjectItemModel?> getActiveProject() async {
    final active = await _repository.getActiveProject();
    if (active == null) {
      return null;
    }

    return ProjectItemModel(
      id: active.id,
      name: active.name,
      opponent: active.opponent,
      venue: active.venue,
      date: active.date,
      clipCount: active.clipCount,
      isActive: active.isActive,
      fallbackCueId: active.fallbackCueId,
      sponsorLoopCueId: active.sponsorLoopCueId,
      isConfigurationComplete: active.isConfigurationComplete,
    );
  }

  bool _isSponsorLoopCandidate(MediaAsset asset) {
    return asset.category == MediaCategory.sponsor ||
        asset.cueType == CueType.lockedSponsor ||
        asset.cueType == CueType.loop;
  }

  bool _isFallbackCandidate(MediaAsset asset) {
    return asset.cueType == CueType.fallback || asset.cueType == CueType.loop;
  }

  ProjectCueOptionModel _toCueOption(MediaAsset asset) {
    return ProjectCueOptionModel(
      id: asset.id,
      title: asset.title,
      category: asset.category,
      cueType: asset.cueType,
      isLocked: asset.isCueLocked,
    );
  }

  List<ProjectCueOptionModel> _sortByRelevance(
    List<ProjectCueOptionModel> options, {
    required ProjectCueAssignmentType type,
  }) {
    final entries = options.toList(growable: false);
    entries.sort((a, b) {
      final scoreA = _relevanceScore(a, type);
      final scoreB = _relevanceScore(b, type);
      if (scoreA != scoreB) {
        return scoreB.compareTo(scoreA);
      }
      return a.title.toLowerCase().compareTo(b.title.toLowerCase());
    });
    return entries;
  }

  int _relevanceScore(ProjectCueOptionModel option, ProjectCueAssignmentType type) {
    return switch (type) {
      ProjectCueAssignmentType.sponsorLoop =>
        (option.category == MediaCategory.sponsor ? 3 : 0) +
            (option.cueType == CueType.lockedSponsor ? 3 : 0) +
            (option.cueType == CueType.loop ? 1 : 0) +
            (option.isLocked ? 1 : 0),
      ProjectCueAssignmentType.fallback =>
        (option.cueType == CueType.fallback ? 4 : 0) +
            (option.cueType == CueType.loop ? 2 : 0) +
            (option.category == MediaCategory.general ? 1 : 0),
    };
  }

  String? _normalizeOptional({required String? sponsorOrFallbackId}) {
    final normalized = sponsorOrFallbackId?.trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    return normalized;
  }

  bool _isProjectConfigurationComplete({
    required String? sponsorLoopCueId,
    required String? fallbackCueId,
  }) {
    return _normalizeOptional(sponsorOrFallbackId: sponsorLoopCueId) != null &&
        _normalizeOptional(sponsorOrFallbackId: fallbackCueId) != null;
  }
}

enum ProjectCueAssignmentType { sponsorLoop, fallback }

class ProjectCueCatalogModel {
  const ProjectCueCatalogModel({
    required this.allCueOptions,
    required this.sponsorLoopOptions,
    required this.fallbackOptions,
  });

  final List<ProjectCueOptionModel> allCueOptions;
  final List<ProjectCueOptionModel> sponsorLoopOptions;
  final List<ProjectCueOptionModel> fallbackOptions;
}
