enum MediaCategory {
  general,
  pregame,
  sponsor,
  introHome,
  introGuest,
  player,
  event,
  halftime,
  postgame,
  emergency,
}

extension MediaCategoryX on MediaCategory {
  String get value => name;

  static MediaCategory fromValue(String? value) {
    return MediaCategory.values.firstWhere(
      (item) => item.name == value,
      orElse: () => MediaCategory.general,
    );
  }
}
