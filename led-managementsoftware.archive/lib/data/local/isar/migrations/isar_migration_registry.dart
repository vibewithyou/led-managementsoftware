import 'package:isar/isar.dart';
import 'package:led_management_software/data/local/isar/collections/isar_meta_record.dart';

typedef IsarMigrationStep = Future<void> Function(Isar isar);

/// Holds schema version and future migration steps.
class IsarMigrationRegistry {
  const IsarMigrationRegistry._();

  static const int currentSchemaVersion = 1;

  static final Map<int, IsarMigrationStep> _steps = {
    // 2: (isar) async { /* future migration */ },
  };

  static Future<void> ensureMigrated(Isar isar) async {
    final existingMeta = await isar.isarMetaRecords.get(0);
    final existingVersion = existingMeta?.schemaVersion ?? 0;

    if (existingVersion >= currentSchemaVersion) {
      return;
    }

    for (var version = existingVersion + 1; version <= currentSchemaVersion; version++) {
      final step = _steps[version];
      if (step != null) {
        await step(isar);
      }
    }

    await isar.writeTxn(() async {
      final record = existingMeta ?? IsarMetaRecord();
      record.id = 0;
      record.schemaVersion = currentSchemaVersion;
      record.updatedAt = DateTime.now();
      await isar.isarMetaRecords.put(record);
    });
  }
}
