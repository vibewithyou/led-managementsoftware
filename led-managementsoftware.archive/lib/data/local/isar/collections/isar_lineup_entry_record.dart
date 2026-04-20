import 'package:isar/isar.dart';

part 'isar_lineup_entry_record.g.dart';

@collection
class IsarLineupEntryRecord {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String externalId;

  late String payloadJson;

  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
}
