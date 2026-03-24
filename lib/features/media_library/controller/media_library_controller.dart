import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:led_management_software/domain/entities/media_asset_entity.dart';
import 'package:led_management_software/domain/enums/cue_type.dart';
import 'package:led_management_software/domain/enums/media_category.dart';
import 'package:led_management_software/features/media_library/model/media_library_view_models.dart';
import 'package:led_management_software/features/media_library/service/media_library_service.dart';

class MediaLibraryController extends ChangeNotifier {
  MediaLibraryController({MediaLibraryService? service}) : _service = service ?? MediaLibraryService();

  final MediaLibraryService _service;

  List<MediaAssetEntity> _allAssets = const [];
  List<MediaAssetEntity> _filteredAssets = const [];
  final Map<String, bool> _fileExistsByAssetId = {};
  bool _isLoading = true;
  String _searchQuery = '';
  MediaCategory? _selectedCategory;
  MediaAssetEntity? _selectedAsset;
  String? _error;
  String? _lastImportWarning;
  String? _lastImportedId;
  bool _onlyFavorites = false;
  bool _onlyLockedSponsor = false;
  bool _onlyMissingFiles = false;
  MediaLibrarySortMode _sortMode = MediaLibrarySortMode.importedNewest;

  bool get isLoading => _isLoading;
  List<MediaAssetEntity> get assets => _filteredAssets;
  String get searchQuery => _searchQuery;
  MediaCategory? get selectedCategory => _selectedCategory;
  MediaAssetEntity? get selectedAsset => _selectedAsset;
  String? get error => _error;
  String? get lastImportedId => _lastImportedId;
  String? get lastImportWarning => _lastImportWarning;
  bool get onlyFavorites => _onlyFavorites;
  bool get onlyLockedSponsor => _onlyLockedSponsor;
  bool get onlyMissingFiles => _onlyMissingFiles;
  MediaLibrarySortMode get sortMode => _sortMode;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allAssets = await _service.loadAssets();
      _refreshFileStatus();
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

  void setOnlyFavorites(bool value) {
    _onlyFavorites = value;
    _applyFilters();
    notifyListeners();
  }

  void setOnlyLockedSponsor(bool value) {
    _onlyLockedSponsor = value;
    _applyFilters();
    notifyListeners();
  }

  void setOnlyMissingFiles(bool value) {
    _onlyMissingFiles = value;
    _applyFilters();
    notifyListeners();
  }

  void setSortMode(MediaLibrarySortMode mode) {
    _sortMode = mode;
    _applyFilters();
    notifyListeners();
  }

  void selectAsset(MediaAssetEntity asset) {
    _selectedAsset = asset;
    notifyListeners();
  }

  MediaFileStatus fileStatusFor(MediaAssetEntity asset) {
    final exists = _fileExistsByAssetId[asset.id] ?? true;
    if (!exists) {
      return MediaFileStatus.missing;
    }
    if (asset.metadataIncomplete) {
      return MediaFileStatus.metadataIncomplete;
    }
    return MediaFileStatus.available;
  }

  Future<MediaImportResultModel> importAsset({
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
    _lastImportWarning = null;
    notifyListeners();

    try {
      final result = await _service.importClip(
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

      _lastImportWarning = result.warning;
      final before = _allAssets.map((a) => a.id).toSet();
      await _loadSilent();
      final newAsset = _filteredAssets.where((a) => !before.contains(a.id)).firstOrNull;
      _lastImportedId = newAsset?.id ?? result.assetId;
      _selectedAsset = newAsset ?? (_filteredAssets.isNotEmpty ? _filteredAssets.first : null);
      notifyListeners();
      return result;
    } catch (exception) {
      _error = exception.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateAsset({
    required MediaAssetEntity asset,
    required String title,
    required MediaCategory category,
    required List<String> tags,
    required CueType cueType,
    required bool isCueLocked,
    required bool isFavorite,
    String? sponsorName,
    String? playerName,
  }) async {
    await _service.updateClip(
      asset: asset,
      title: title,
      category: category,
      tags: tags,
      cueType: cueType,
      isCueLocked: isCueLocked,
      isFavorite: isFavorite,
      sponsorName: sponsorName,
      playerName: playerName,
    );
    await load();
  }

  Future<void> deleteAsset(String id) async {
    await _service.deleteClip(id);
    await load();
  }

  void clearLastImportedId() {
    _lastImportedId = null;
  }

  Future<void> _loadSilent() async {
    try {
      _allAssets = await _service.loadAssets();
      _refreshFileStatus();
      _applyFilters();
    } catch (_) {
      // Silent – errors bubble up through public calls.
    }
  }

  void _refreshFileStatus() {
    _fileExistsByAssetId
      ..clear()
      ..addEntries(_allAssets.map((asset) => MapEntry(asset.id, File(asset.filePath).existsSync())));
  }

  void _applyFilters() {
    final normalizedQuery = _searchQuery.trim().toLowerCase();

    _filteredAssets = _allAssets.where((asset) {
      if (!asset.isActive) return false;
      final categoryMatches = _selectedCategory == null || asset.category == _selectedCategory;
      if (!categoryMatches) return false;

      if (_onlyFavorites && !asset.isFavorite) return false;
      if (_onlyLockedSponsor && !(asset.isCueLocked && asset.category == MediaCategory.sponsor)) return false;
      if (_onlyMissingFiles && ((_fileExistsByAssetId[asset.id] ?? true))) return false;

      if (normalizedQuery.isEmpty) return true;

      final inTitle = asset.title.toLowerCase().contains(normalizedQuery);
      final inTags = asset.tags.any((tag) => tag.toLowerCase().contains(normalizedQuery));
      final inSponsor = (asset.sponsorName ?? '').toLowerCase().contains(normalizedQuery);
      final inPlayer = (asset.playerName ?? '').toLowerCase().contains(normalizedQuery);
      return inTitle || inTags || inSponsor || inPlayer;
    }).toList(growable: false);

    switch (_sortMode) {
      case MediaLibrarySortMode.importedNewest:
        _filteredAssets = [..._filteredAssets]..sort((a, b) => b.importedAt.compareTo(a.importedAt));
        break;
      case MediaLibrarySortMode.alphabetical:
        _filteredAssets = [..._filteredAssets]..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case MediaLibrarySortMode.category:
        _filteredAssets = [..._filteredAssets]..sort((a, b) {
          final categoryCompare = a.category.name.compareTo(b.category.name);
          if (categoryCompare != 0) return categoryCompare;
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
        });
        break;
    }

    if (_selectedAsset != null && !_filteredAssets.contains(_selectedAsset)) {
      _selectedAsset = _filteredAssets.isNotEmpty ? _filteredAssets.first : null;
    }
  }
}
