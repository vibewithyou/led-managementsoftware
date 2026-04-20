enum SceneCategory { preGame, inGame, breakTime, specialAction, postGame, custom }

extension SceneCategoryX on SceneCategory {
  String get label {
    switch (this) {
      case SceneCategory.preGame:
        return 'Vor dem Spiel';
      case SceneCategory.inGame:
        return 'Während des Spiels';
      case SceneCategory.breakTime:
        return 'Pause';
      case SceneCategory.specialAction:
        return 'Sonderaktion';
      case SceneCategory.postGame:
        return 'Nach dem Spiel';
      case SceneCategory.custom:
        return 'Benutzerdefiniert';
    }
  }

  static SceneCategory fromValue(String raw) {
    return SceneCategory.values.firstWhere(
      (category) => category.name == raw,
      orElse: () => SceneCategory.custom,
    );
  }
}
