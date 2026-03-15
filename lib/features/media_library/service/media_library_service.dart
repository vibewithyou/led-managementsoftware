import 'package:led_management_software/data/repositories/media_library_repository_impl.dart';
import 'package:led_management_software/domain/entities/media_asset_entity.dart';
import 'package:led_management_software/domain/enums/media_category.dart';
import 'package:led_management_software/domain/repositories/media_library_repository.dart';

class MediaLibraryService {
  MediaLibraryService({MediaLibraryRepository? repository}) : _repository = repository ?? MediaLibraryRepositoryImpl();

  final MediaLibraryRepository _repository;

  static const List<String> allowedExtensions = ['mp4', 'mov', 'mkv', 'avi'];

  Future<List<MediaAssetEntity>> loadAssets() {
    return _repository.getAllAssets();
  }

  Future<void> importClip({
    required String filePath,
    required String fileName,
    required String title,
    required MediaCategory category,
    required List<String> tags,
    String? sponsorName,
    String? playerName,
    required String cueTypeValue,
    required bool isCueLocked,
    required bool isFavorite,
  }) async {
    final extension = _extractExtension(fileName);
    if (!allowedExtensions.contains(extension)) {
      throw ArgumentError('Nur Videodateien erlaubt: ${allowedExtensions.join(', ')}');
    }

    await _repository.importAsset(
      filePath: filePath,
      fileName: fileName,
      title: title,
      category: category,
      tags: tags,
      sponsorName: sponsorName,
      playerName: playerName,
      cueTypeValue: cueTypeValue,
      isCueLocked: isCueLocked,
      isFavorite: isFavorite,
    );
  }

  String _extractExtension(String fileName) {
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex <= 0 || dotIndex == fileName.length - 1) {
      return '';
    }
    return fileName.substring(dotIndex + 1).toLowerCase();
  }
}
