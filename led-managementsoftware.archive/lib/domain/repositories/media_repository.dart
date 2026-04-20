import 'package:led_management_software/domain/entities/media_asset.dart';
import 'package:led_management_software/domain/enums/media_category.dart';

abstract class MediaRepository {
  Future<List<MediaAsset>> getAllMediaAssets();

  Future<MediaAsset?> getMediaAssetById(String id);

  Future<List<MediaAsset>> getMediaAssetsByCategory(MediaCategory category);

  Future<List<MediaAsset>> searchMediaAssets(String query);

  Future<void> saveMediaAsset(MediaAsset mediaAsset);

  Future<void> deleteMediaAsset(String id);
}
