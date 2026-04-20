import 'package:isar/isar.dart';

part 'isar_event_log_record.g.dart';

@collection
class IsarEventLogRecord {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String externalId;

  late String payloadJson;

  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
}
