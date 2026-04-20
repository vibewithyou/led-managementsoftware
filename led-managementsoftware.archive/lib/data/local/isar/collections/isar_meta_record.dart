import 'package:isar/isar.dart';

part 'isar_meta_record.g.dart';

@collection
class IsarMetaRecord {
  Id id = 0;

  int schemaVersion = 1;

  DateTime updatedAt = DateTime.now();
}
