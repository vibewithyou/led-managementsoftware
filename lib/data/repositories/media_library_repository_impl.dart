import 'dart:convert';

import 'package:isar/isar.dart';
import 'package:led_management_software/data/local/isar/collections/isar_media_asset_record.dart';
import 'package:led_management_software/data/local/isar/isar_database.dart';
import 'package:led_management_software/data/services/video_metadata_service.dart';
import 'package:led_management_software/domain/entities/media_asset.dart';
import 'package:led_management_software/domain/entities/media_asset_entity.dart';
import 'package:led_management_software/domain/enums/cue_type.dart';
import 'package:led_management_software/domain/enums/media_category.dart';
import 'package:led_management_software/domain/enums/team_type.dart';
import 'package:led_management_software/domain/repositories/media_library_repository.dart';

class MediaLibraryRepositoryImpl implements MediaLibraryRepository {
  MediaLibraryRepositoryImpl({VideoMetadataService? metadataService})
      : _metadataService = metadataService ?? VideoMetadataService();

  final VideoMetadataService _metadataService;

  @override
  Future<List<MediaAssetEntity>> getAllAssets() async {
    try {
      await _seedIfEmpty();
      final isar = await IsarDatabase.instance.database;
      final records = await isar.isarMediaAssetRecords.where().findAll();
      return records
          .map((record) => MediaAsset.fromJson(jsonDecode(record.payloadJson) as Map<String, dynamic>))
          .toList(growable: false)
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    } catch (error) {
      throw Exception('Media assets konnten nicht geladen werden: $error');
    }
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
  Future<void> deleteAsset(String id) async {
    final all = await getAllAssets();
    final target = all.where((asset) => asset.id == id).cast<MediaAsset?>().firstWhere((item) => item != null, orElse: () => null);
    if (target == null) {
      return;
    }
    await saveAsset(target.copyWith(isActive: false, updatedAt: DateTime.now()));
  }

  @override
  Future<void> saveAsset(MediaAssetEntity asset) async {
    try {
      final isar = await IsarDatabase.instance.database;
      await isar.writeTxn(() async {
        final existing = await isar.isarMediaAssetRecords.filter().externalIdEqualTo(asset.id).findFirst();

        final record = existing ?? IsarMediaAssetRecord();
        record.externalId = asset.id;
        record.payloadJson = jsonEncode(asset.toJson());
        record.updatedAt = DateTime.now();
        if (existing == null) {
          record.createdAt = DateTime.now();
        }
        await isar.isarMediaAssetRecords.put(record);
      });
    } catch (error) {
      throw Exception('Media asset konnte nicht gespeichert werden: $error');
    }
  }

  @override
  Future<MediaAssetImportResult> importAsset({
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
    final now = DateTime.now();
    final nextId = 'media_${now.microsecondsSinceEpoch}';
    final metadata = await _metadataService.analyzeFile(filePath: filePath, fileName: fileName);

    final entity = MediaAsset(
      id: nextId,
      title: title.trim().isEmpty ? fileName : title.trim(),
      filePath: filePath,
      fileName: fileName,
      thumbnailPath: '',
      durationMs: metadata.durationMs,
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
      metadataIncomplete: metadata.metadataIncomplete,
      fileSizeBytes: metadata.fileSizeBytes,
      fileExtension: metadata.fileExtension,
      importedAt: now,
      lastValidatedAt: metadata.lastValidatedAt,
    );

    await saveAsset(entity);

    return MediaAssetImportResult(
      assetId: nextId,
      durationMs: metadata.durationMs,
      metadataIncomplete: metadata.metadataIncomplete,
      warning: metadata.warning,
    );
  }

  Future<void> _seedIfEmpty() async {
    final isar = await IsarDatabase.instance.database;
    final count = await isar.isarMediaAssetRecords.count();
    if (count > 0) {
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
        metadataIncomplete: false,
        fileSizeBytes: null,
        fileExtension: 'mp4',
        importedAt: now,
        lastValidatedAt: now,
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
        metadataIncomplete: false,
        fileSizeBytes: null,
        fileExtension: 'mov',
        importedAt: now,
        lastValidatedAt: now,
      ),
    ];

    await isar.writeTxn(() async {
      for (final asset in seedAssets) {
        final record = IsarMediaAssetRecord()
          ..externalId = asset.id
          ..payloadJson = jsonEncode(asset.toJson())
          ..createdAt = now
          ..updatedAt = now;
        await isar.isarMediaAssetRecords.put(record);
      }
    });
  }

  String? _cleanOptional(String? value) {
    if (value == null) {
      return null;
    }
    final normalized = value.trim();
    return normalized.isEmpty ? null : normalized;
  }
}
