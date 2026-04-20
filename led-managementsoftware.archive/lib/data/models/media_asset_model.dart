import 'package:led_management_software/domain/entities/media_asset.dart';
import 'package:led_management_software/domain/enums/cue_type.dart';
import 'package:led_management_software/domain/enums/media_category.dart';
import 'package:led_management_software/domain/enums/team_type.dart';

class MediaAssetModel {
  const MediaAssetModel({
    required this.id,
    required this.title,
    required this.filePath,
    required this.fileName,
    required this.thumbnailPath,
    required this.durationMs,
    required this.category,
    required this.tags,
    required this.sponsorName,
    required this.playerName,
    required this.teamType,
    required this.cueType,
    required this.isCueLocked,
    required this.isFavorite,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
    required this.metadataIncomplete,
    required this.fileSizeBytes,
    required this.fileExtension,
    required this.importedAt,
    required this.lastValidatedAt,
  });

  factory MediaAssetModel.fromEntity(MediaAsset entity) {
    return MediaAssetModel(
      id: entity.id,
      title: entity.title,
      filePath: entity.filePath,
      fileName: entity.fileName,
      thumbnailPath: entity.thumbnailPath,
      durationMs: entity.durationMs,
      category: entity.category,
      tags: entity.tags,
      sponsorName: entity.sponsorName,
      playerName: entity.playerName,
      teamType: entity.teamType,
      cueType: entity.cueType,
      isCueLocked: entity.isCueLocked,
      isFavorite: entity.isFavorite,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isActive: entity.isActive,
      metadataIncomplete: entity.metadataIncomplete,
      fileSizeBytes: entity.fileSizeBytes,
      fileExtension: entity.fileExtension,
      importedAt: entity.importedAt,
      lastValidatedAt: entity.lastValidatedAt,
    );
  }

  factory MediaAssetModel.fromJson(Map<String, dynamic> json) {
    final createdAt = DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
    return MediaAssetModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      filePath: json['filePath'] as String? ?? '',
      fileName: json['fileName'] as String? ?? '',
      thumbnailPath: json['thumbnailPath'] as String? ?? '',
      durationMs: json['durationMs'] as int? ?? 0,
      category: MediaCategoryX.fromValue(json['category'] as String?),
      tags: ((json['tags'] as List<dynamic>?) ?? const <dynamic>[])
          .map((item) => item.toString())
          .toList(growable: false),
      sponsorName: json['sponsorName'] as String?,
      playerName: json['playerName'] as String?,
      teamType: TeamTypeX.fromValue(json['teamType'] as String?),
      cueType: CueTypeX.fromValue(json['cueType'] as String?),
      isCueLocked: json['isCueLocked'] as bool? ?? false,
      isFavorite: json['isFavorite'] as bool? ?? false,
      createdAt: createdAt,
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0),
      isActive: json['isActive'] as bool? ?? true,
      metadataIncomplete: json['metadataIncomplete'] as bool? ?? ((json['durationMs'] as int? ?? 0) <= 0),
      fileSizeBytes: json['fileSizeBytes'] as int?,
      fileExtension: json['fileExtension'] as String?,
      importedAt: DateTime.tryParse(json['importedAt'] as String? ?? '') ?? createdAt,
      lastValidatedAt: DateTime.tryParse(json['lastValidatedAt'] as String? ?? ''),
    );
  }

  final String id;
  final String title;
  final String filePath;
  final String fileName;
  final String thumbnailPath;
  final int durationMs;
  final MediaCategory category;
  final List<String> tags;
  final String? sponsorName;
  final String? playerName;
  final TeamType teamType;
  final CueType cueType;
  final bool isCueLocked;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final bool metadataIncomplete;
  final int? fileSizeBytes;
  final String? fileExtension;
  final DateTime importedAt;
  final DateTime? lastValidatedAt;

  MediaAsset toEntity() {
    return MediaAsset(
      id: id,
      title: title,
      filePath: filePath,
      fileName: fileName,
      thumbnailPath: thumbnailPath,
      durationMs: durationMs,
      category: category,
      tags: tags,
      sponsorName: sponsorName,
      playerName: playerName,
      teamType: teamType,
      cueType: cueType,
      isCueLocked: isCueLocked,
      isFavorite: isFavorite,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isActive: isActive,
      metadataIncomplete: metadataIncomplete,
      fileSizeBytes: fileSizeBytes,
      fileExtension: fileExtension,
      importedAt: importedAt,
      lastValidatedAt: lastValidatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'filePath': filePath,
      'fileName': fileName,
      'thumbnailPath': thumbnailPath,
      'durationMs': durationMs,
      'category': category.value,
      'tags': tags,
      'sponsorName': sponsorName,
      'playerName': playerName,
      'teamType': teamType.value,
      'cueType': cueType.value,
      'isCueLocked': isCueLocked,
      'isFavorite': isFavorite,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
      'metadataIncomplete': metadataIncomplete,
      'fileSizeBytes': fileSizeBytes,
      'fileExtension': fileExtension,
      'importedAt': importedAt.toIso8601String(),
      'lastValidatedAt': lastValidatedAt?.toIso8601String(),
    };
  }
}
