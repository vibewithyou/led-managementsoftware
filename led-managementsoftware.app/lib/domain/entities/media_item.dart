import 'package:led_managementsoftware_app/domain/entities/entity_utils.dart';
import 'package:led_managementsoftware_app/domain/enums/media_type.dart';
import 'package:led_managementsoftware_app/domain/enums/sync_status.dart';

class MediaItem {
  const MediaItem({
    required this.id,
    required this.name,
    required this.localPath,
    this.remotePath,
    required this.type,
    required this.categoryId,
    required this.tags,
    required this.duration,
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
  final MediaType type;
  final String categoryId;
  final List<String> tags;
  final Duration duration;
  final bool isActive;
  final SyncStatus syncStatus;
  final String checksum;
  final DateTime createdAt;
  final DateTime updatedAt;

  MediaItem copyWith({
    String? id,
    String? name,
    String? localPath,
    String? remotePath,
    MediaType? type,
    String? categoryId,
    List<String>? tags,
    Duration? duration,
    bool? isActive,
    SyncStatus? syncStatus,
    String? checksum,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MediaItem(
      id: id ?? this.id,
      name: name ?? this.name,
      localPath: localPath ?? this.localPath,
      remotePath: remotePath ?? this.remotePath,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      tags: tags ?? this.tags,
      duration: duration ?? this.duration,
      isActive: isActive ?? this.isActive,
      syncStatus: syncStatus ?? this.syncStatus,
      checksum: checksum ?? this.checksum,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'localPath': localPath,
      'remotePath': remotePath,
      'type': type.name,
      'categoryId': categoryId,
      'tags': tags,
      'duration': duration.inMilliseconds,
      'isActive': isActive,
      'syncStatus': syncStatus.name,
      'checksum': checksum,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory MediaItem.fromMap(Map<String, dynamic> map) {
    return MediaItem(
      id: map['id'] as String,
      name: map['name'] as String,
      localPath: map['localPath'] as String,
      remotePath: map['remotePath'] as String?,
      type: MediaTypeX.fromValue(map['type'] as String),
      categoryId: map['categoryId'] as String,
      tags: ((map['tags'] as List<dynamic>?) ?? const []).map((entry) => entry.toString()).toList(),
      duration: Duration(milliseconds: map['duration'] as int),
      isActive: map['isActive'] as bool,
      syncStatus: SyncStatusX.fromValue(map['syncStatus'] as String),
      checksum: map['checksum'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MediaItem &&
        other.id == id &&
        other.name == name &&
        other.localPath == localPath &&
        other.remotePath == remotePath &&
        other.type == type &&
        other.categoryId == categoryId &&
        listEqualsByValue(other.tags, tags) &&
        other.duration == duration &&
        other.isActive == isActive &&
        other.syncStatus == syncStatus &&
        other.checksum == checksum &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        name,
        localPath,
        remotePath,
        type,
        categoryId,
        listHash(tags),
        duration,
        isActive,
        syncStatus,
        checksum,
        createdAt,
        updatedAt,
      );
}
