import 'dart:convert';

import 'package:isar/isar.dart';
import 'package:led_management_software/data/local/isar/collections/isar_cue_record.dart';
import 'package:led_management_software/data/local/isar/isar_database.dart';
import 'package:led_management_software/domain/entities/cue.dart';
import 'package:led_management_software/domain/repositories/cue_repository.dart';

class CueRepositoryImpl implements CueRepository {
  @override
  Future<List<Cue>> getAllCues() async {
    try {
      final isar = await IsarDatabase.instance.database;
      final records = await isar.isarCueRecords.where().findAll();
      return records
          .map((record) => Cue.fromJson(jsonDecode(record.payloadJson) as Map<String, dynamic>))
          .toList(growable: false);
    } catch (error) {
      throw Exception('Cues konnten nicht geladen werden: $error');
    }
  }

  @override
  Future<Cue?> getCueById(String id) async {
    final all = await getAllCues();
    return all.where((cue) => cue.id == id).cast<Cue?>().firstWhere((cue) => cue != null, orElse: () => null);
  }

  @override
  Future<List<Cue>> getFavoriteCues() async {
    final all = await getAllCues();
    return all.where((cue) => cue.isFavorite).toList(growable: false);
  }

  @override
  Future<void> saveCue(Cue cue) async {
    final isar = await IsarDatabase.instance.database;
    await isar.writeTxn(() async {
      final existing = await isar.isarCueRecords.filter().externalIdEqualTo(cue.id).findFirst();
      final record = existing ?? IsarCueRecord();
      record.externalId = cue.id;
      record.payloadJson = jsonEncode(cue.toJson());
      record.updatedAt = DateTime.now();
      if (existing == null) {
        record.createdAt = DateTime.now();
      }
      await isar.isarCueRecords.put(record);
    });
  }

  @override
  Future<void> deleteCue(String id) async {
    final isar = await IsarDatabase.instance.database;
    await isar.writeTxn(() async {
      final existing = await isar.isarCueRecords.filter().externalIdEqualTo(id).findFirst();
      if (existing != null) {
        await isar.isarCueRecords.delete(existing.id);
      }
    });
  }
}
