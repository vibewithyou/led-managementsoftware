import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:led_management_software/data/local/isar/collections/isar_project_record.dart';
import 'package:led_management_software/data/local/isar/isar_database.dart';
import 'package:led_management_software/domain/entities/project.dart';
import 'package:led_management_software/domain/repositories/project_repository.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  static final List<Project> _memoryProjects = <Project>[];

  bool get _useMemoryStore => kIsWeb || IsarDatabase.instance.initializationError != null;

  @override
  Future<List<Project>> getAllProjects() async {
    if (_useMemoryStore) {
      _seedMemoryIfEmpty();
      return List<Project>.from(_memoryProjects)..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    }

    try {
      await _seedIfEmpty();
      final isar = await IsarDatabase.instance.database;
      final records = await isar.isarProjectRecords.where().findAll();
      return records
          .map((record) => Project.fromJson(jsonDecode(record.payloadJson) as Map<String, dynamic>))
          .toList(growable: false)
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    } catch (error) {
      throw Exception('Projekte konnten nicht geladen werden: $error');
    }
  }

  @override
  Future<Project?> getProjectById(String id) async {
    final projects = await getAllProjects();
    return projects.where((item) => item.id == id).cast<Project?>().firstWhere((item) => item != null, orElse: () => null);
  }

  @override
  Future<Project?> getActiveProject() async {
    final projects = await getAllProjects();
    return projects.where((item) => item.isActive).cast<Project?>().firstWhere((item) => item != null, orElse: () => null);
  }

  @override
  Future<void> setActiveProject(String id) async {
    if (_useMemoryStore) {
      _seedMemoryIfEmpty();
      for (var i = 0; i < _memoryProjects.length; i++) {
        final project = _memoryProjects[i];
        _memoryProjects[i] = project.copyWith(isActive: project.id == id, updatedAt: DateTime.now());
      }
      return;
    }

    final all = await getAllProjects();
    final updated = all
        .map((project) => project.copyWith(isActive: project.id == id, updatedAt: DateTime.now()))
        .toList(growable: false);

    final isar = await IsarDatabase.instance.database;
    await isar.writeTxn(() async {
      for (final project in updated) {
        final existing = await isar.isarProjectRecords.filter().externalIdEqualTo(project.id).findFirst();
        final record = existing ?? IsarProjectRecord();
        record.externalId = project.id;
        record.payloadJson = jsonEncode(project.toJson());
        record.updatedAt = DateTime.now();
        if (existing == null) {
          record.createdAt = DateTime.now();
        }
        await isar.isarProjectRecords.put(record);
      }
    });
  }

  @override
  Future<void> saveProject(Project project) async {
    if (_useMemoryStore) {
      _seedMemoryIfEmpty();
      final index = _memoryProjects.indexWhere((item) => item.id == project.id);
      if (index >= 0) {
        _memoryProjects[index] = project;
      } else {
        _memoryProjects.add(project);
      }
      return;
    }

    final isar = await IsarDatabase.instance.database;
    await isar.writeTxn(() async {
      final existing = await isar.isarProjectRecords.filter().externalIdEqualTo(project.id).findFirst();
      final record = existing ?? IsarProjectRecord();
      record.externalId = project.id;
      record.payloadJson = jsonEncode(project.toJson());
      record.updatedAt = DateTime.now();
      if (existing == null) {
        record.createdAt = DateTime.now();
      }
      await isar.isarProjectRecords.put(record);
    });
  }

  @override
  Future<void> deleteProject(String id) async {
    if (_useMemoryStore) {
      _seedMemoryIfEmpty();
      _memoryProjects.removeWhere((item) => item.id == id);
      if (_memoryProjects.isNotEmpty && !_memoryProjects.any((project) => project.isActive)) {
        final first = _memoryProjects.first;
        _memoryProjects[0] = first.copyWith(isActive: true, updatedAt: DateTime.now());
      }
      return;
    }

    final isar = await IsarDatabase.instance.database;
    await isar.writeTxn(() async {
      final existing = await isar.isarProjectRecords.filter().externalIdEqualTo(id).findFirst();
      if (existing != null) {
        await isar.isarProjectRecords.delete(existing.id);
      }
    });

    final all = await getAllProjects();
    if (all.isNotEmpty && !all.any((project) => project.isActive)) {
      await setActiveProject(all.first.id);
    }
  }

  void _seedMemoryIfEmpty() {
    if (_memoryProjects.isNotEmpty) {
      return;
    }

    _memoryProjects.addAll(_buildSeedProjects());
  }

  List<Project> _buildSeedProjects() {
    final now = DateTime.now();
    return [
      Project(
        id: 'project_1',
        name: 'HBL Heimspiel 23',
        opponent: 'SG Blau-Weiß',
        venue: 'Arena Süd',
        date: DateTime(now.year, now.month, now.day + 1),
        fallbackCueId: 'seed_1',
        sponsorLoopCueId: 'seed_2',
        clipCount: 18,
        isActive: true,
        isConfigurationComplete: true,
        createdAt: now,
        updatedAt: now,
      ),
      Project(
        id: 'project_2',
        name: 'EHF Viertelfinale',
        opponent: 'HC Rhein',
        venue: 'Arena West',
        date: DateTime(now.year, now.month, now.day + 7),
        fallbackCueId: 'seed_1',
        sponsorLoopCueId: null,
        clipCount: 24,
        isActive: false,
        isConfigurationComplete: false,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  Future<void> _seedIfEmpty() async {
    final isar = await IsarDatabase.instance.database;
    final count = await isar.isarProjectRecords.count();
    if (count > 0) {
      return;
    }

    final now = DateTime.now();
    final seed = _buildSeedProjects();

    await isar.writeTxn(() async {
      for (final project in seed) {
        final record = IsarProjectRecord()
          ..externalId = project.id
          ..payloadJson = jsonEncode(project.toJson())
          ..createdAt = now
          ..updatedAt = now;
        await isar.isarProjectRecords.put(record);
      }
    });
  }
}
