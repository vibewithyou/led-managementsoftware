import 'dart:convert';

import 'package:isar/isar.dart';
import 'package:led_management_software/data/local/isar/collections/isar_project_record.dart';
import 'package:led_management_software/data/local/isar/isar_database.dart';
import 'package:led_management_software/domain/entities/project.dart';
import 'package:led_management_software/domain/repositories/project_repository.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  @override
  Future<List<Project>> getAllProjects() async {
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

  Future<void> _seedIfEmpty() async {
    final isar = await IsarDatabase.instance.database;
    final count = await isar.isarProjectRecords.count();
    if (count > 0) {
      return;
    }

    final now = DateTime.now();
    final seed = [
      Project(
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
      Project(
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
    ];

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
