import 'dart:async';
import 'dart:convert';

import 'package:isar/isar.dart';
import 'package:led_management_software/data/local/isar/collections/isar_event_log_record.dart';
import 'package:led_management_software/data/local/isar/isar_database.dart';
import 'package:led_management_software/domain/entities/live_event_log.dart';
import 'package:led_management_software/domain/repositories/live_log_repository.dart';

class LiveLogRepositoryImpl implements LiveLogRepository {
  @override
  Future<void> appendLog(LiveEventLog eventLog) async {
    final isar = await IsarDatabase.instance.database;
    await isar.writeTxn(() async {
      final existing = await isar.isarEventLogRecords.filter().externalIdEqualTo(eventLog.id).findFirst();
      final record = existing ?? IsarEventLogRecord();
      record.externalId = eventLog.id;
      record.payloadJson = jsonEncode(eventLog.toJson());
      record.updatedAt = DateTime.now();
      if (existing == null) {
        record.createdAt = DateTime.now();
      }
      await isar.isarEventLogRecords.put(record);
    });
  }

  @override
  Future<List<LiveEventLog>> getLogsForProject(String projectId) async {
    final isar = await IsarDatabase.instance.database;
    final records = await isar.isarEventLogRecords.where().findAll();
    return records
        .map((record) => LiveEventLog.fromJson(jsonDecode(record.payloadJson) as Map<String, dynamic>))
        .where((log) => log.projectId == projectId)
        .toList(growable: false)
      ..sort((a, b) => (a.timestamp ?? DateTime.fromMillisecondsSinceEpoch(0))
          .compareTo(b.timestamp ?? DateTime.fromMillisecondsSinceEpoch(0)));
  }

  @override
  Stream<LiveEventLog> watchLiveLogs(String projectId) async* {
    final isar = await IsarDatabase.instance.database;
    yield* isar.isarEventLogRecords.where().watchLazy(fireImmediately: true).asyncExpand((_) async* {
      final logs = await getLogsForProject(projectId);
      if (logs.isNotEmpty) {
        yield logs.last;
      }
    });
  }

  @override
  Future<void> clearLogsForProject(String projectId) async {
    final isar = await IsarDatabase.instance.database;
    final records = await isar.isarEventLogRecords.where().findAll();
    final target = records.where((record) {
      final decoded = LiveEventLog.fromJson(jsonDecode(record.payloadJson) as Map<String, dynamic>);
      return decoded.projectId == projectId;
    }).toList(growable: false);

    await isar.writeTxn(() async {
      for (final record in target) {
        await isar.isarEventLogRecords.delete(record.id);
      }
    });
  }
}
