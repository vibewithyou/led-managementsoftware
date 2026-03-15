import 'package:flutter/foundation.dart';
import 'package:led_management_software/domain/entities/lineup_entry.dart';

/// Handles intro sequence flow and active player navigation.
class IntroSequenceController extends ChangeNotifier {
  bool _isRunning = false;
  int _activeIndex = -1;
  LineupEntry? _activePlayer;
  String _statusMessage = 'Bereit';

  bool get isRunning => _isRunning;
  int get activeIndex => _activeIndex;
  LineupEntry? get activePlayer => _activePlayer;
  String get statusMessage => _statusMessage;

  /// Starts intro flow from first active player.
  void startIntro(List<LineupEntry> teamEntries) {
    final activeEntries = teamEntries.where((entry) => entry.isActive).toList(growable: false)
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    if (activeEntries.isEmpty) {
      _isRunning = false;
      _activeIndex = -1;
      _activePlayer = null;
      _statusMessage = 'Keine aktiven Spieler';
      notifyListeners();
      return;
    }

    _isRunning = true;
    _activeIndex = 0;
    _activePlayer = activeEntries.first;
    _statusMessage = 'Intro gestartet';
    notifyListeners();
  }

  /// Moves to next player in active lineup.
  void playNextPlayer(List<LineupEntry> teamEntries) {
    final activeEntries = _activeEntries(teamEntries);
    if (activeEntries.isEmpty) {
      _statusMessage = 'Keine aktiven Spieler';
      notifyListeners();
      return;
    }

    if (!_isRunning) {
      startIntro(teamEntries);
      return;
    }

    final nextIndex = (_activeIndex + 1).clamp(0, activeEntries.length - 1);
    _activeIndex = nextIndex;
    _activePlayer = activeEntries[_activeIndex];
    _statusMessage = 'Nächster Spieler';
    notifyListeners();
  }

  /// Moves to previous player in active lineup.
  void playPreviousPlayer(List<LineupEntry> teamEntries) {
    final activeEntries = _activeEntries(teamEntries);
    if (activeEntries.isEmpty) {
      _statusMessage = 'Keine aktiven Spieler';
      notifyListeners();
      return;
    }

    if (!_isRunning) {
      startIntro(teamEntries);
      return;
    }

    final previousIndex = (_activeIndex - 1).clamp(0, activeEntries.length - 1);
    _activeIndex = previousIndex;
    _activePlayer = activeEntries[_activeIndex];
    _statusMessage = 'Vorheriger Spieler';
    notifyListeners();
  }

  /// Plays final outro/end clip and ends sequence state.
  void playEndClip() {
    _isRunning = false;
    _activeIndex = -1;
    _activePlayer = null;
    _statusMessage = 'Endclip abgespielt';
    notifyListeners();
  }

  List<LineupEntry> _activeEntries(List<LineupEntry> teamEntries) {
    return teamEntries.where((entry) => entry.isActive).toList(growable: false)
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }
}
