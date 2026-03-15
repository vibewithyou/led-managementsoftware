import 'package:led_management_software/domain/entities/entity_utils.dart';
import 'package:led_management_software/domain/enums/cue_type.dart';
import 'package:led_management_software/domain/enums/media_category.dart';
import 'package:led_management_software/domain/enums/team_type.dart';

class MediaAsset {
  const MediaAsset({
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
  });

  factory MediaAsset.empty() {
    final now = DateTime.now();
    return MediaAsset(
      id: '',
      title: '',
      filePath: '',
      fileName: '',
      thumbnailPath: '',
      durationMs: 0,
      category: MediaCategory.general,
      tags: const [],
      sponsorName: null,
      playerName: null,
      teamType: TeamType.unknown,
      cueType: CueType.oneShot,
      isCueLocked: false,
      isFavorite: false,
      createdAt: now,
      updatedAt: now,
      isActive: true,
    );
  }

  factory MediaAsset.fromJson(Map<String, dynamic> json) {
    return MediaAsset(
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
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0),
      isActive: json['isActive'] as bool? ?? true,
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

  MediaAsset copyWith({
    String? id,
    String? title,
    String? filePath,
    String? fileName,
    String? thumbnailPath,
    int? durationMs,
    MediaCategory? category,
    List<String>? tags,
    Object? sponsorName = _unset,
    Object? playerName = _unset,
    TeamType? teamType,
    CueType? cueType,
    bool? isCueLocked,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return MediaAsset(
      id: id ?? this.id,
      title: title ?? this.title,
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      durationMs: durationMs ?? this.durationMs,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      sponsorName: sponsorName == _unset ? this.sponsorName : sponsorName as String?,
      playerName: playerName == _unset ? this.playerName : playerName as String?,
      teamType: teamType ?? this.teamType,
      cueType: cueType ?? this.cueType,
      isCueLocked: isCueLocked ?? this.isCueLocked,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
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
    };
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is MediaAsset &&
            runtimeType == other.runtimeType &&
            id == other.id &&
            title == other.title &&
            filePath == other.filePath &&
            fileName == other.fileName &&
            thumbnailPath == other.thumbnailPath &&
            durationMs == other.durationMs &&
            category == other.category &&
            listEqualsByValue(tags, other.tags) &&
            sponsorName == other.sponsorName &&
            playerName == other.playerName &&
            teamType == other.teamType &&
            cueType == other.cueType &&
            isCueLocked == other.isCueLocked &&
            isFavorite == other.isFavorite &&
            createdAt == other.createdAt &&
            updatedAt == other.updatedAt &&
            isActive == other.isActive;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      filePath,
      fileName,
      thumbnailPath,
      durationMs,
      category,
      listHashByValue(tags),
      sponsorName,
      playerName,
      teamType,
      cueType,
      isCueLocked,
      isFavorite,
      createdAt,
      updatedAt,
      isActive,
    );
  }
}

const _unset = Object();
