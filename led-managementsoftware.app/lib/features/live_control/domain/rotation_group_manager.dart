/// RotationGroupManager verwaltet die automatische Rotation von Clips.
/// 
/// Ziel: Wenn mehrere Varianten einer Aktion existieren (z.B. 4 Clips für "2 Min Heim"),
/// sollen sie erst alle einmal durchlaufen, bevor Wiederholungen kommen.
/// 
/// Tracking pro Rotationsgruppe:
/// - Welche Clips gehören dazu?
/// - Wie viele wurden bereits gespielt?
/// - Welcher Clip sollte als nächstes kommen?
class RotationGroupManager {
  /// Speichert pro Rotationsgruppe den Zustand.
  /// Schlüssel: rotationGroup name
  /// Wert: {clipIds: [...], playedIndices: [...], totalPlayed: int}
  final Map<String, RotationState> _rotationStates = {};

  /// Registriert eine Rotationsgruppe mit ihren Clips.
  void registerGroup({
    required String groupName,
    required List<String> clipIds,
  }) {
    _rotationStates[groupName] = RotationState(
      clipIds: clipIds,
      playedIndices: [],
      totalPlayed: 0,
    );
  }

  /// Holt den nächsten Clip-Index aus einer Rotationsgruppe.
  /// 
  /// Logik:
  /// - Wenn noch nicht alle Clips der Gruppe gespielt wurden: nächster ungespielte Clip
  /// - Wenn alle gespielt: Reset und nächster Clip ab 0
  /// 
  /// Rückgabe: Index des nächsten Clips (oder -1 wenn Gruppe leer)
  int getNextClipIndex(String groupName) {
    final state = _rotationStates[groupName];
    if (state == null || state.clipIds.isEmpty) return -1;

    // Wenn wir alle Clips dieser Runde gespielt haben, reset
    if (state.playedIndices.length >= state.clipIds.length) {
      state.playedIndices.clear();
    }

    // Finde den nächsten ungespielte Clip
    for (int i = 0; i < state.clipIds.length; i++) {
      if (!state.playedIndices.contains(i)) {
        state.playedIndices.add(i);
        state.totalPlayed++;
        return i;
      }
    }

    // Fallback (sollte nicht vorkommen)
    return 0;
  }

  /// Markiert einen Clip als gespielt.
  void markAsPlayed({
    required String groupName,
    required int clipIndex,
  }) {
    final state = _rotationStates[groupName];
    if (state != null && !state.playedIndices.contains(clipIndex)) {
      state.playedIndices.add(clipIndex);
    }
  }

  /// Reset einer Rotationsgruppe (z.B. Projektende, Neustart).
  void resetGroup(String groupName) {
    final state = _rotationStates[groupName];
    if (state != null) {
      state.playedIndices.clear();
      state.totalPlayed = 0;
    }
  }

  /// Reset aller Rotationsgruppen.
  void resetAll() {
    _rotationStates.clear();
  }

  /// Gibt den aktuellen Zustand einer Gruppe zurück (für Debugging/UI).
  RotationState? getGroupState(String groupName) {
    return _rotationStates[groupName];
  }

  /// Gibt die Anzahl der Gruppen zurück.
  int get groupCount => _rotationStates.length;
}

/// Zustand einer Rotationsgruppe.
class RotationState {
  RotationState({
    required this.clipIds,
    required this.playedIndices,
    required this.totalPlayed,
  });

  final List<String> clipIds; // alle clip-ids in dieser gruppe
  final List<int> playedIndices; // indizes, die in dieser runde bereits gespielt wurden
  int totalPlayed; // gesamtzahl bisher gespielter clips aus dieser gruppe

  /// Fortschritt in % (0-100)
  int get progressPercent {
    if (clipIds.isEmpty) return 0;
    return ((playedIndices.length / clipIds.length) * 100).toInt();
  }

  /// Gibt den Status aus (z.B. "2 von 4 clips gespielt")
  String get statusLabel => '${playedIndices.length} von ${clipIds.length} Clips gespielt';
}
