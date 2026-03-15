import 'package:led_management_software/data/models/media_asset_model.dart';
import 'package:led_management_software/domain/entities/media_asset.dart';
import 'package:led_management_software/domain/entities/media_asset_entity.dart';
import 'package:led_management_software/domain/enums/cue_type.dart';
import 'package:led_management_software/domain/enums/media_category.dart';
import 'package:led_management_software/domain/enums/team_type.dart';
import 'package:led_management_software/domain/repositories/media_library_repository.dart';

class MediaLibraryRepositoryImpl implements MediaLibraryRepository {
  MediaLibraryRepositoryImpl();

  final List<MediaAssetModel> _storage = [];

  @override
  Future<List<MediaAssetEntity>> getAllAssets() async {
    _seedIfEmpty();
    return _storage.map((model) => model.toEntity()).toList(growable: false);
  }

  @override
  Future<List<MediaAssetEntity>> filterByCategory(MediaCategory? category) async {
    final allAssets = await getAllAssets();
    if (category == null) {
      return allAssets;
    }
    return allAssets.where((asset) => asset.category == category).toList(growable: false);
  }

  @override
  Future<List<MediaAssetEntity>> searchAssets(String query) async {
    final normalized = query.trim().toLowerCase();
    final allAssets = await getAllAssets();
    if (normalized.isEmpty) {
      return allAssets;
    }

    return allAssets.where((asset) {
      final inTitle = asset.title.toLowerCase().contains(normalized);
      final inTags = asset.tags.any((tag) => tag.toLowerCase().contains(normalized));
      final inSponsor = (asset.sponsorName ?? '').toLowerCase().contains(normalized);
      final inPlayer = (asset.playerName ?? '').toLowerCase().contains(normalized);
      return inTitle || inTags || inSponsor || inPlayer;
    }).toList(growable: false);
  }

  @override
  Future<void> saveAsset(MediaAssetEntity asset) async {
    final index = _storage.indexWhere((item) => item.id == asset.id);
    final model = MediaAssetModel.fromEntity(asset);

    if (index == -1) {
      _storage.add(model);
      return;
    }
    _storage[index] = model;
  }

  @override
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
  }) async {
    _seedIfEmpty();

    final now = DateTime.now();
    final nextId = 'media_${now.microsecondsSinceEpoch}';

    final entity = MediaAsset(
      id: nextId,
      title: title.trim().isEmpty ? fileName : title.trim(),
      filePath: filePath,
      fileName: fileName,
      thumbnailPath: '',
      durationMs: 0,
      category: category,
      tags: tags,
      sponsorName: _cleanOptional(sponsorName),
      playerName: _cleanOptional(playerName),
      teamType: TeamType.unknown,
      cueType: CueTypeX.fromValue(cueTypeValue),
      isCueLocked: isCueLocked,
      isFavorite: isFavorite,
      createdAt: now,
      updatedAt: now,
      isActive: true,
    );

    await saveAsset(entity);
  }

  void _seedIfEmpty() {
    if (_storage.isNotEmpty) {
      return;
    }

    final now = DateTime.now();
    final seedAssets = [
      MediaAsset(
        id: 'seed_1',
        title: 'Pregame Countdown',
        filePath: r'D:\clips\pregame_countdown.mp4',
        fileName: 'pregame_countdown.mp4',
        thumbnailPath: '',
        durationMs: 30000,
        category: MediaCategory.pregame,
        tags: const ['countdown', 'stadion'],
        sponsorName: null,
        playerName: null,
        teamType: TeamType.neutral,
        cueType: CueType.loop,
        isCueLocked: false,
        isFavorite: true,
        createdAt: now,
        updatedAt: now,
        isActive: true,
      ),
      MediaAsset(
        id: 'seed_2',
        title: 'Sponsor Premium Loop',
        filePath: r'D:\clips\sponsor_premium.mov',
        fileName: 'sponsor_premium.mov',
        thumbnailPath: '',
        durationMs: 20000,
        category: MediaCategory.sponsor,
        tags: const ['sponsor', 'loop'],
        sponsorName: 'Muster Energie',
        playerName: null,
        teamType: TeamType.neutral,
        cueType: CueType.lockedSponsor,
        isCueLocked: true,
        isFavorite: true,
        createdAt: now,
        updatedAt: now,
        isActive: true,
      ),
      MediaAsset(
        id: 'seed_3',
        title: 'Player Intro #13',
        filePath: r'D:\clips\player_13_intro.mp4',
        fileName: 'player_13_intro.mp4',
        thumbnailPath: '',
        durationMs: 9000,
        category: MediaCategory.player,
        tags: const ['player', 'intro'],
        sponsorName: null,
        playerName: 'Max Mustermann',
        teamType: TeamType.home,
        cueType: CueType.oneShot,
        isCueLocked: false,
        isFavorite: false,
        createdAt: now,
        updatedAt: now,
        isActive: true,
      ),
      MediaAsset(
        id: 'seed_4',
        title: 'Emergency Hold Frame',
        filePath: r'D:\clips\emergency_hold.avi',
        fileName: 'emergency_hold.avi',
        thumbnailPath: '',
        durationMs: 0,
        category: MediaCategory.emergency,
        tags: const ['emergency', 'fallback'],
        sponsorName: null,
        playerName: null,
        teamType: TeamType.neutral,
        cueType: CueType.fallback,
        isCueLocked: true,
        isFavorite: false,
        createdAt: now,
        updatedAt: now,
        isActive: true,
      ),
    ];

    _storage.addAll(seedAssets.map(MediaAssetModel.fromEntity));
  }

  String? _cleanOptional(String? value) {
    if (value == null) {
      return null;
    }
    final normalized = value.trim();
    return normalized.isEmpty ? null : normalized;
  }
}
