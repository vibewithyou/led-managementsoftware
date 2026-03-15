import 'package:isar/isar.dart';

part 'isar_project_record.g.dart';

@collection
class IsarProjectRecord {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String externalId;

  late String payloadJson;

  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
}
