enum MediaType { mp4, jpg }

extension MediaTypeX on MediaType {
  String get label => this == MediaType.mp4 ? 'MP4' : 'JPG';

  static MediaType fromValue(String raw) {
    return MediaType.values.firstWhere(
      (type) => type.name == raw,
      orElse: () => MediaType.mp4,
    );
  }
}
