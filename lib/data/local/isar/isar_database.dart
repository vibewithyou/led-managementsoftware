import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:led_management_software/data/local/isar/collections/isar_cue_record.dart';
import 'package:led_management_software/data/local/isar/collections/isar_event_log_record.dart';
import 'package:led_management_software/data/local/isar/collections/isar_lineup_entry_record.dart';
import 'package:led_management_software/data/local/isar/collections/isar_media_asset_record.dart';
import 'package:led_management_software/data/local/isar/collections/isar_meta_record.dart';
import 'package:led_management_software/data/local/isar/collections/isar_project_record.dart';
import 'package:led_management_software/data/local/isar/migrations/isar_migration_registry.dart';
import 'package:path_provider/path_provider.dart';

/// Provides a single Isar instance for the whole app runtime.
class IsarDatabase {
  IsarDatabase._();

  static final IsarDatabase instance = IsarDatabase._();

  Isar? _isar;
  Object? _initError;

  bool get isInitialized => _isar != null;

  Object? get initializationError => _initError;

  Future<void> initialize() async {
    if (_isar != null) {
      return;
    }

    try {
      final dir = await getApplicationSupportDirectory();
      final db = await Isar.open(
        [
          IsarMediaAssetRecordSchema,
          IsarCueRecordSchema,
          IsarProjectRecordSchema,
          IsarLineupEntryRecordSchema,
          IsarEventLogRecordSchema,
          IsarMetaRecordSchema,
        ],
        directory: dir.path,
        name: 'led_control_db',
        inspector: kDebugMode,
      );

      await IsarMigrationRegistry.ensureMigrated(db);
      _isar = db;
    } catch (error, stackTrace) {
      _initError = error;
      debugPrint('Isar init failed: $error');
      debugPrint('$stackTrace');
      rethrow;
    }
  }

  Future<Isar> get database async {
    if (_isar != null) {
      return _isar!;
    }
    await initialize();
    if (_isar == null) {
      throw StateError('Isar database is not initialized.');
    }
    return _isar!;
  }

  Future<void> close() async {
    final db = _isar;
    _isar = null;
    if (db != null && db.isOpen) {
      await db.close();
    }
  }
}
