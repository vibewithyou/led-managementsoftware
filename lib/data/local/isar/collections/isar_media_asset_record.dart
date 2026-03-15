import 'package:isar/isar.dart';

part 'isar_media_asset_record.g.dart';

@collection
class IsarMediaAssetRecord {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String externalId;

  late String payloadJson;

  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
}
