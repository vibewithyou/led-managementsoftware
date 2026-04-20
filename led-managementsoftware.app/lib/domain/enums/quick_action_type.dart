enum QuickActionType {
  preGame,
  kickoff,
  breakPhase,
  postGame,
  intro,
  twoMinute,
  timeout,
  redCard,
  wiper,
  homeGoal,
  awayGoal,
  injury,
  custom,
}

extension QuickActionTypeX on QuickActionType {
  String get label {
    switch (this) {
      case QuickActionType.homeGoal:
        return 'Tor Heim';
      case QuickActionType.awayGoal:
        return 'Tor Gegner';
      case QuickActionType.preGame:
        return 'Vor dem Spiel';
      case QuickActionType.kickoff:
        return 'Spielbeginn';
      case QuickActionType.breakPhase:
        return 'Pause';
      case QuickActionType.postGame:
        return 'Nach dem Spiel';
      case QuickActionType.intro:
        return 'Einlauf';
      case QuickActionType.twoMinute:
        return '2 Minuten';
      case QuickActionType.timeout:
        return 'Timeout';
      case QuickActionType.redCard:
        return 'Rote Karte';
      case QuickActionType.wiper:
        return 'Wischer';
      case QuickActionType.injury:
        return 'Verletzung';
      case QuickActionType.custom:
        return 'Benutzeraktion';
    }
  }

  static QuickActionType fromValue(String raw) {
    return QuickActionType.values.firstWhere(
      (type) => type.name == raw,
      orElse: () => QuickActionType.custom,
    );
  }
}
