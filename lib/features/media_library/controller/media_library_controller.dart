import 'package:flutter/foundation.dart';
import 'package:led_management_software/domain/entities/media_asset_entity.dart';
import 'package:led_management_software/domain/enums/media_category.dart';
import 'package:led_management_software/features/media_library/service/media_library_service.dart';

class MediaLibraryController extends ChangeNotifier {
  MediaLibraryController({MediaLibraryService? service}) : _service = service ?? MediaLibraryService();

  final MediaLibraryService _service;

  List<MediaAssetEntity> _allAssets = const [];
  List<MediaAssetEntity> _filteredAssets = const [];
  bool _isLoading = true;
  String _searchQuery = '';
  MediaCategory? _selectedCategory;
  MediaAssetEntity? _selectedAsset;
  String? _error;

  /// The id of the most recently imported asset – used to trigger FadeIn.
  String? _lastImportedId;

  bool get isLoading => _isLoading;
  List<MediaAssetEntity> get assets => _filteredAssets;
  String get searchQuery => _searchQuery;
  MediaCategory? get selectedCategory => _selectedCategory;
  MediaAssetEntity? get selectedAsset => _selectedAsset;
  String? get error => _error;
  String? get lastImportedId => _lastImportedId;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allAssets = await _service.loadAssets();
      _applyFilters();
      _selectedAsset ??= _filteredAssets.isNotEmpty ? _filteredAssets.first : null;
    } catch (exception) {
      _error = exception.toString();
      _filteredAssets = const [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateSearchQuery(String value) {
    _searchQuery = value;
    _applyFilters();
    notifyListeners();
  }

  void selectCategory(MediaCategory? category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  void selectAsset(MediaAssetEntity asset) {
    _selectedAsset = asset;
    notifyListeners();
  }

  Future<void> importAsset({
    required String filePath,
    required String fileName,
    required String title,
    required MediaCategory category,
    required List<String> tags,
    required String cueTypeValue,
    required bool isCueLocked,
    required bool isFavorite,
    String? sponsorName,
    String? playerName,
  }) async {
    _error = null;
    notifyListeners();

    try {
      await _service.importClip(
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

      // Reload and mark the newest asset for FadeIn animation.
      final before = _allAssets.map((a) => a.id).toSet();
      await _loadSilent();
      final newAsset = _filteredAssets.where((a) => !before.contains(a.id)).firstOrNull;
      _lastImportedId = newAsset?.id;
      _selectedAsset = newAsset ?? (_filteredAssets.isNotEmpty ? _filteredAssets.first : null);
      notifyListeners();
    } catch (exception) {
      _error = exception.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Clears the FadeIn mark after the animation has played.
  void clearLastImportedId() {
    _lastImportedId = null;
  }

  Future<void> _loadSilent() async {
    try {
      _allAssets = await _service.loadAssets();
      _applyFilters();
    } catch (_) {
      // Silent – errors bubble up through the public importAsset call.
    }
  }

  void _applyFilters() {
    final normalizedQuery = _searchQuery.trim().toLowerCase();

    _filteredAssets = _allAssets.where((asset) {
      final categoryMatches = _selectedCategory == null || asset.category == _selectedCategory;

      if (!categoryMatches) {
        return false;
      }

      if (normalizedQuery.isEmpty) {
        return true;
      }

      final inTitle = asset.title.toLowerCase().contains(normalizedQuery);
      final inTags = asset.tags.any((tag) => tag.toLowerCase().contains(normalizedQuery));
      final inSponsor = (asset.sponsorName ?? '').toLowerCase().contains(normalizedQuery);
      final inPlayer = (asset.playerName ?? '').toLowerCase().contains(normalizedQuery);
      return inTitle || inTags || inSponsor || inPlayer;
    }).toList(growable: false);

    if (_selectedAsset != null && !_filteredAssets.contains(_selectedAsset)) {
      _selectedAsset = _filteredAssets.isNotEmpty ? _filteredAssets.first : null;
    }
  }

}