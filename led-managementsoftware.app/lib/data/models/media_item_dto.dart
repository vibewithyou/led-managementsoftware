import 'package:led_managementsoftware_app/domain/entities/media_item.dart';
import 'package:led_managementsoftware_app/domain/enums/media_type.dart';
import 'package:led_managementsoftware_app/domain/enums/sync_status.dart';

class MediaItemDto {
  const MediaItemDto({
    required this.id,
    required this.name,
    required this.localPath,
    this.remotePath,
    required this.type,
    required this.categoryId,
    required this.tags,
    required this.durationMs,
    required this.isActive,
    required this.syncStatus,
    required this.checksum,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String localPath;
  final String? remotePath;
  final String type;
  final String categoryId;
  final List<String> tags;
  final int durationMs;
  final bool isActive;
  final String syncStatus;
  final String checksum;
  final String createdAt;
  final String updatedAt;

  factory MediaItemDto.fromEntity(MediaItem entity) {
    return MediaItemDto(
      id: entity.id,
      name: entity.name,
      localPath: entity.localPath,
      remotePath: entity.remotePath,
      type: entity.type.name,
      categoryId: entity.categoryId,
      tags: entity.tags,
      durationMs: entity.duration.inMilliseconds,
      isActive: entity.isActive,
      syncStatus: entity.syncStatus.name,
      checksum: entity.checksum,
      createdAt: entity.createdAt.toIso8601String(),
      updatedAt: entity.updatedAt.toIso8601String(),
    );
  }

  MediaItem toEntity() {
    return MediaItem(
      id: id,
      name: name,
      localPath: localPath,
      remotePath: remotePath,
      type: MediaTypeX.fromValue(type),
      categoryId: categoryId,
      tags: tags,
      duration: Duration(milliseconds: durationMs),
      isActive: isActive,
      syncStatus: SyncStatusX.fromValue(syncStatus),
      checksum: checksum,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'localPath': localPath,
      'remotePath': remotePath,
      'type': type,
      'categoryId': categoryId,
      'tags': tags,
      'durationMs': durationMs,
      'isActive': isActive,
      'syncStatus': syncStatus,
      'checksum': checksum,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory MediaItemDto.fromMap(Map<String, dynamic> map) {
    return MediaItemDto(
      id: map['id'] as String,
      name: map['name'] as String,
      localPath: map['localPath'] as String,
      remotePath: map['remotePath'] as String?,
      type: map['type'] as String,
      categoryId: map['categoryId'] as String,
      tags: ((map['tags'] as List<dynamic>?) ?? const []).map((entry) => entry.toString()).toList(),
      durationMs: map['durationMs'] as int,
      isActive: map['isActive'] as bool,
      syncStatus: map['syncStatus'] as String,
      checksum: map['checksum'] as String,
      createdAt: map['createdAt'] as String,
      updatedAt: map['updatedAt'] as String,
    );
  }
}
