enum TeamSide { home, away }

extension TeamSideX on TeamSide {
  String get label => this == TeamSide.home ? 'Heim' : 'Gegner';

  static TeamSide fromValue(String raw) {
    return TeamSide.values.firstWhere(
      (side) => side.name == raw,
      orElse: () => TeamSide.home,
    );
  }
}
