import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:led_management_software/data/repositories/media_repository_impl.dart';
import 'package:led_management_software/data/repositories/project_repository_impl.dart';
import 'package:led_management_software/domain/entities/media_asset.dart';
import 'package:led_management_software/domain/entities/project.dart';
import 'package:led_management_software/domain/enums/cue_type.dart';
import 'package:led_management_software/domain/enums/media_category.dart';
import 'package:led_management_software/domain/repositories/media_repository.dart';
import 'package:led_management_software/domain/repositories/project_repository.dart';
import 'package:led_management_software/features/projects/model/project_cue_file_status.dart';
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
            introCueId: project.introCueId,
            goalCueId: project.goalCueId,
            yellowCardCueId: project.yellowCardCueId,
            redCardCueId: project.redCardCueId,
            penaltyCueId: project.penaltyCueId,
            sevenMeterCueId: project.sevenMeterCueId,
            timeoutHomeCueId: project.timeoutHomeCueId,
            timeoutGuestCueId: project.timeoutGuestCueId,
            wiperCueId: project.wiperCueId,
            halftimeCueId: project.halftimeCueId,
            gameEndCueId: project.gameEndCueId,
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
    required Map<ProjectCueSlot, String?> cueAssignments,
  }) async {
    final now = DateTime.now();
    final project = Project(
      id: 'project_${now.microsecondsSinceEpoch}',
      name: name,
      opponent: opponent,
      venue: venue,
      date: date,
      fallbackCueId: _normalizeCueAssignment(cueAssignments, ProjectCueSlot.fallback),
      sponsorLoopCueId: _normalizeCueAssignment(cueAssignments, ProjectCueSlot.sponsorLoop),
      introCueId: _normalizeCueAssignment(cueAssignments, ProjectCueSlot.intro),
      goalCueId: _normalizeCueAssignment(cueAssignments, ProjectCueSlot.goal),
      yellowCardCueId: _normalizeCueAssignment(cueAssignments, ProjectCueSlot.yellowCard),
      redCardCueId: _normalizeCueAssignment(cueAssignments, ProjectCueSlot.redCard),
      penaltyCueId: _normalizeCueAssignment(cueAssignments, ProjectCueSlot.penalty),
      sevenMeterCueId: _normalizeCueAssignment(cueAssignments, ProjectCueSlot.sevenMeter),
      timeoutHomeCueId: _normalizeCueAssignment(cueAssignments, ProjectCueSlot.timeoutHome),
      timeoutGuestCueId: _normalizeCueAssignment(cueAssignments, ProjectCueSlot.timeoutGuest),
      wiperCueId: _normalizeCueAssignment(cueAssignments, ProjectCueSlot.wiper),
      halftimeCueId: _normalizeCueAssignment(cueAssignments, ProjectCueSlot.halftime),
      gameEndCueId: _normalizeCueAssignment(cueAssignments, ProjectCueSlot.gameEnd),
      clipCount: 0,
      createdAt: now,
      updatedAt: now,
      isActive: false,
      isConfigurationComplete: _isProjectConfigurationComplete(cueAssignments),
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
        fallbackCueId: _normalizeCueId(model.fallbackCueId),
        sponsorLoopCueId: _normalizeCueId(model.sponsorLoopCueId),
        introCueId: _normalizeCueId(model.introCueId),
        goalCueId: _normalizeCueId(model.goalCueId),
        yellowCardCueId: _normalizeCueId(model.yellowCardCueId),
        redCardCueId: _normalizeCueId(model.redCardCueId),
        penaltyCueId: _normalizeCueId(model.penaltyCueId),
        sevenMeterCueId: _normalizeCueId(model.sevenMeterCueId),
        timeoutHomeCueId: _normalizeCueId(model.timeoutHomeCueId),
        timeoutGuestCueId: _normalizeCueId(model.timeoutGuestCueId),
        wiperCueId: _normalizeCueId(model.wiperCueId),
        halftimeCueId: _normalizeCueId(model.halftimeCueId),
        gameEndCueId: _normalizeCueId(model.gameEndCueId),
        isConfigurationComplete: _isProjectConfigurationComplete(model.cueAssignments),
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
      fileStatus: _resolveFileStatus(asset),
    );
  }

  ProjectCueFileStatus _resolveFileStatus(MediaAsset asset) {
    if (!kIsWeb) {
      final path = asset.filePath.trim();
      if (path.isEmpty || !File(path).existsSync()) {
        return ProjectCueFileStatus.missing;
      }
    }

    if (asset.metadataIncomplete) {
      return ProjectCueFileStatus.metadataIncomplete;
    }

    return ProjectCueFileStatus.available;
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

  String? _normalizeCueAssignment(Map<ProjectCueSlot, String?> cueAssignments, ProjectCueSlot slot) {
    return _normalizeCueId(cueAssignments[slot]);
  }

  String? _normalizeCueId(String? cueId) {
    final normalized = cueId?.trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    return normalized;
  }

  bool _isProjectConfigurationComplete(Map<ProjectCueSlot, String?> cueAssignments) {
    return Project.requiredSlots.every((slot) => _normalizeCueAssignment(cueAssignments, slot) != null);
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
