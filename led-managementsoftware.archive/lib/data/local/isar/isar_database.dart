import 'dart:io';

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
    if (_isar != null || _initError != null) {
      return;
    }

    if (kIsWeb) {
      _initError = UnsupportedError('Isar persistence is not available on web.');
      return;
    }

    final dir = await getApplicationSupportDirectory();

    Future<Isar> openDb() => Isar.open(
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

    try {
      final db = await openDb();
      await IsarMigrationRegistry.ensureMigrated(db);
      _isar = db;
    } catch (firstError, stackTrace) {
      debugPrint('Isar init failed (trying recovery): $firstError');
      debugPrint('$stackTrace');
      // Schema mismatch or corrupt DB – close any existing instance, delete
      // old files and retry once.
      try {
        // Close any lingering Isar instance that may be holding the file lock.
        final existing = Isar.getInstance('led_control_db');
        if (existing != null && existing.isOpen) {
          await existing.close();
        }
        for (final suffix in ['.isar', '.isar.lock']) {
          final f = File('${dir.path}/led_control_db$suffix');
          if (await f.exists()) await f.delete();
        }
        final db = await openDb();
        await IsarMigrationRegistry.ensureMigrated(db);
        _isar = db;
        debugPrint('Isar recovery successful – old DB was deleted.');
      } catch (recoveryError) {
        _initError = recoveryError;
        debugPrint('Isar recovery failed: $recoveryError');
        rethrow;
      }
    }
  }

  Future<Isar> get database async {
    if (_isar != null) {
      return _isar!;
    }
    await initialize();
    if (_isar == null) {
      throw StateError('Isar database is not initialized: ${_initError ?? 'unknown error'}');
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
