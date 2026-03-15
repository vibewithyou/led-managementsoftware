import 'package:isar/isar.dart';

part 'isar_cue_record.g.dart';

@collection
class IsarCueRecord {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String externalId;

  late String payloadJson;

  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
}
