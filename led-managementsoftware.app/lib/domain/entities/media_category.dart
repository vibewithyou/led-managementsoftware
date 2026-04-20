class MediaCategory {
  const MediaCategory({
    required this.id,
    required this.name,
    required this.isSystemCategory,
  });

  final String id;
  final String name;
  final bool isSystemCategory;

  MediaCategory copyWith({
    String? id,
    String? name,
    bool? isSystemCategory,
  }) {
    return MediaCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      isSystemCategory: isSystemCategory ?? this.isSystemCategory,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'isSystemCategory': isSystemCategory,
    };
  }

  factory MediaCategory.fromMap(Map<String, dynamic> map) {
    return MediaCategory(
      id: map['id'] as String,
      name: map['name'] as String,
      isSystemCategory: map['isSystemCategory'] as bool,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MediaCategory && other.id == id && other.name == name && other.isSystemCategory == isSystemCategory;
  }

  @override
  int get hashCode => Object.hash(id, name, isSystemCategory);
}
