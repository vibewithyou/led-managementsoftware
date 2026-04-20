import 'package:led_management_software/data/repositories/media_library_repository_impl.dart';
import 'package:led_management_software/domain/entities/media_asset.dart';
import 'package:led_management_software/domain/enums/media_category.dart';
import 'package:led_management_software/domain/repositories/media_repository.dart';

class MediaRepositoryImpl implements MediaRepository {
  MediaRepositoryImpl({MediaLibraryRepositoryImpl? delegate}) : _delegate = delegate ?? MediaLibraryRepositoryImpl();

  final MediaLibraryRepositoryImpl _delegate;

  @override
  Future<List<MediaAsset>> getAllMediaAssets() => _delegate.getAllAssets();

  @override
  Future<MediaAsset?> getMediaAssetById(String id) async {
    final all = await _delegate.getAllAssets();
    return all.where((asset) => asset.id == id).cast<MediaAsset?>().firstWhere((item) => item != null, orElse: () => null);
  }

  @override
  Future<List<MediaAsset>> getMediaAssetsByCategory(MediaCategory category) => _delegate.filterByCategory(category);

  @override
  Future<List<MediaAsset>> searchMediaAssets(String query) => _delegate.searchAssets(query);

  @override
  Future<void> saveMediaAsset(MediaAsset mediaAsset) => _delegate.saveAsset(mediaAsset);

  @override
  Future<void> deleteMediaAsset(String id) async {
    final all = await _delegate.getAllAssets();
    final target = all.where((asset) => asset.id == id).cast<MediaAsset?>().firstWhere((item) => item != null, orElse: () => null);
    if (target == null) {
      return;
    }
    await _delegate.saveAsset(target.copyWith(isActive: false, updatedAt: DateTime.now()));
  }
}
