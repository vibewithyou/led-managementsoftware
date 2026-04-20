import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:led_management_software/data/local/isar/collections/isar_lineup_entry_record.dart';
import 'package:led_management_software/data/local/isar/isar_database.dart';
import 'package:led_management_software/domain/entities/lineup_entry.dart';
import 'package:led_management_software/domain/enums/team_type.dart';
import 'package:led_management_software/domain/repositories/lineup_repository.dart';

class LineupRepositoryImpl implements LineupRepository {
  static final List<LineupEntry> _memoryEntries = <LineupEntry>[];

  bool get _useMemoryStore => kIsWeb || IsarDatabase.instance.initializationError != null;

  @override
  Future<List<LineupEntry>> getLineupForProject(String projectId) async {
    if (_useMemoryStore) {
      _seedMemoryProjectIfNeeded(projectId);
      return _memoryEntries
          .where((entry) => entry.projectId == projectId)
          .toList(growable: false)
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    }

    await _seedProjectIfNeeded(projectId);
    final isar = await IsarDatabase.instance.database;
    final records = await isar.isarLineupEntryRecords.where().findAll();
    return records
        .map((record) => LineupEntry.fromJson(jsonDecode(record.payloadJson) as Map<String, dynamic>))
        .where((entry) => entry.projectId == projectId)
        .toList(growable: false)
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  @override
  Future<List<LineupEntry>> getLineupForTeam({
    required String projectId,
    required TeamType teamType,
  }) async {
    final all = await getLineupForProject(projectId);
    return all.where((entry) => entry.teamType == teamType).toList(growable: false)
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  @override
  Future<void> saveLineupEntry(LineupEntry lineupEntry) async {
    if (_useMemoryStore) {
      _seedMemoryProjectIfNeeded(lineupEntry.projectId);
      final index = _memoryEntries.indexWhere((item) => item.id == lineupEntry.id);
      if (index >= 0) {
        _memoryEntries[index] = lineupEntry;
      } else {
        _memoryEntries.add(lineupEntry);
      }
      return;
    }

    await _seedProjectIfNeeded(lineupEntry.projectId);
    final isar = await IsarDatabase.instance.database;
    await isar.writeTxn(() async {
      final existing = await isar.isarLineupEntryRecords.filter().externalIdEqualTo(lineupEntry.id).findFirst();
      final record = existing ?? IsarLineupEntryRecord();
      record.externalId = lineupEntry.id;
      record.payloadJson = jsonEncode(lineupEntry.toJson());
      record.updatedAt = DateTime.now();
      if (existing == null) {
        record.createdAt = DateTime.now();
      }
      await isar.isarLineupEntryRecords.put(record);
    });
  }

  @override
  Future<void> reorderLineup({
    required String projectId,
    required TeamType teamType,
    required List<String> entryIdsInOrder,
  }) async {
    if (_useMemoryStore) {
      _seedMemoryProjectIfNeeded(projectId);
      final orderMap = <String, int>{
        for (var index = 0; index < entryIdsInOrder.length; index++) entryIdsInOrder[index]: index,
      };

      for (var i = 0; i < _memoryEntries.length; i++) {
        final entry = _memoryEntries[i];
        if (entry.projectId == projectId && entry.teamType == teamType) {
          _memoryEntries[i] = entry.copyWith(sortOrder: orderMap[entry.id] ?? entry.sortOrder);
        }
      }
      return;
    }

    final entries = await getLineupForTeam(projectId: projectId, teamType: teamType);
    final isar = await IsarDatabase.instance.database;

    final orderMap = <String, int>{
      for (var index = 0; index < entryIdsInOrder.length; index++) entryIdsInOrder[index]: index,
    };

    await isar.writeTxn(() async {
      for (final entry in entries) {
        final updated = entry.copyWith(sortOrder: orderMap[entry.id] ?? entry.sortOrder);
        final existing = await isar.isarLineupEntryRecords.filter().externalIdEqualTo(entry.id).findFirst();
        if (existing != null) {
          existing.payloadJson = jsonEncode(updated.toJson());
          existing.updatedAt = DateTime.now();
          await isar.isarLineupEntryRecords.put(existing);
        }
      }
    });
  }

  @override
  Future<void> deleteLineupEntry(String id) async {
    if (_useMemoryStore) {
      _memoryEntries.removeWhere((item) => item.id == id);
      return;
    }

    final isar = await IsarDatabase.instance.database;
    await isar.writeTxn(() async {
      final existing = await isar.isarLineupEntryRecords.filter().externalIdEqualTo(id).findFirst();
      if (existing != null) {
        await isar.isarLineupEntryRecords.delete(existing.id);
      }
    });
  }

  Future<void> _seedProjectIfNeeded(String projectId) async {
    final existingProject = await getLineupForProjectUnsafe(projectId);
    if (existingProject.isNotEmpty) {
      return;
    }

    final seedEntries = [
      LineupEntry(
        id: '${projectId}_home_1',
        projectId: projectId,
        playerName: 'Max Muster',
        jerseyNumber: '1',
        position: 'TW',
        teamType: TeamType.home,
        introCueId: 'seed_1',
        sortOrder: 0,
        isCaptain: false,
        isActive: true,
      ),
      LineupEntry(
        id: '${projectId}_guest_1',
        projectId: projectId,
        playerName: 'Guest One',
        jerseyNumber: '3',
        position: 'RL',
        teamType: TeamType.guest,
        introCueId: 'seed_2',
        sortOrder: 0,
        isCaptain: false,
        isActive: true,
      ),
    ];

    final isar = await IsarDatabase.instance.database;
    await isar.writeTxn(() async {
      for (final entry in seedEntries) {
        final record = IsarLineupEntryRecord()
          ..externalId = entry.id
          ..payloadJson = jsonEncode(entry.toJson())
          ..createdAt = DateTime.now()
          ..updatedAt = DateTime.now();
        await isar.isarLineupEntryRecords.put(record);
      }
    });
  }

  Future<List<LineupEntry>> getLineupForProjectUnsafe(String projectId) async {
    if (_useMemoryStore) {
      return _memoryEntries.where((entry) => entry.projectId == projectId).toList(growable: false);
    }

    final isar = await IsarDatabase.instance.database;
    final records = await isar.isarLineupEntryRecords.where().findAll();
    return records
        .map((record) => LineupEntry.fromJson(jsonDecode(record.payloadJson) as Map<String, dynamic>))
        .where((entry) => entry.projectId == projectId)
        .toList(growable: false);
  }

  void _seedMemoryProjectIfNeeded(String projectId) {
    final existingProject = _memoryEntries.where((entry) => entry.projectId == projectId).toList(growable: false);
    if (existingProject.isNotEmpty) {
      return;
    }

    _memoryEntries.addAll([
      LineupEntry(
        id: '${projectId}_home_1',
        projectId: projectId,
        playerName: 'Max Muster',
        jerseyNumber: '1',
        position: 'TW',
        teamType: TeamType.home,
        introCueId: 'seed_1',
        sortOrder: 0,
        isCaptain: false,
        isActive: true,
      ),
      LineupEntry(
        id: '${projectId}_guest_1',
        projectId: projectId,
        playerName: 'Guest One',
        jerseyNumber: '3',
        position: 'RL',
        teamType: TeamType.guest,
        introCueId: 'seed_2',
        sortOrder: 0,
        isCaptain: false,
        isActive: true,
      ),
    ]);
  }
}
