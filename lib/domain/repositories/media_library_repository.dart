import 'package:led_management_software/domain/entities/media_asset_entity.dart';
import 'package:led_management_software/domain/enums/media_category.dart';

abstract class MediaLibraryRepository {
  Future<List<MediaAssetEntity>> getAllAssets();

  Future<List<MediaAssetEntity>> filterByCategory(MediaCategory? category);

  Future<List<MediaAssetEntity>> searchAssets(String query);

  Future<void> saveAsset(MediaAssetEntity asset);

  Future<void> importAsset({
    required String filePath,
    required String fileName,
    required String title,
    required MediaCategory category,
    required List<String> tags,
    String? sponsorName,
    String? playerName,
    required bool isCueLocked,
    required bool isFavorite,
    required String cueTypeValue,
  });
}
