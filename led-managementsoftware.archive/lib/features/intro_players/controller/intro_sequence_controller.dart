import 'package:flutter/foundation.dart';

class IntroSequenceEntry {
  const IntroSequenceEntry({
    required this.id,
    required this.playerName,
    required this.mediaAssetId,
    required this.clipTitle,
    required this.category,
    required this.sortOrder,
    required this.isActive,
    required this.hasValidClip,
  });

  final String id;
  final String playerName;
  final String? mediaAssetId;
  final String clipTitle;
  final String category;
  final int sortOrder;
  final bool isActive;
  final bool hasValidClip;
}

class IntroSequenceController extends ChangeNotifier {
  bool _isRunning = false;
  int _activeIndex = -1;
  IntroSequenceEntry? _activePlayer;
  String _statusMessage = 'Bereit';

  bool get isRunning => _isRunning;
  int get activeIndex => _activeIndex;
  IntroSequenceEntry? get activePlayer => _activePlayer;
  String get statusMessage => _statusMessage;

  void startIntro(List<IntroSequenceEntry> teamEntries) {
    final playable = _playableEntries(teamEntries);

    if (playable.isEmpty) {
      _isRunning = false;
      _activeIndex = -1;
      _activePlayer = null;
      _statusMessage = 'Keine spielbaren Spielerclips';
      notifyListeners();
      return;
    }

    _isRunning = true;
    _activeIndex = 0;
    _activePlayer = playable.first;
    _statusMessage = 'Intro gestartet';
    notifyListeners();
  }

  void playNextPlayer(List<IntroSequenceEntry> teamEntries) {
    final playable = _playableEntries(teamEntries);
    if (playable.isEmpty) {
      _statusMessage = 'Keine spielbaren Spielerclips';
      notifyListeners();
      return;
    }

    if (!_isRunning) {
      startIntro(teamEntries);
      return;
    }

    if (_activeIndex >= playable.length - 1) {
      _activeIndex = playable.length - 1;
      _activePlayer = playable[_activeIndex];
      _statusMessage = 'Letzter Spieler erreicht';
      notifyListeners();
      return;
    }

    _activeIndex += 1;
    _activePlayer = playable[_activeIndex];
    _statusMessage = 'Nächster Spieler';
    notifyListeners();
  }

  void playPreviousPlayer(List<IntroSequenceEntry> teamEntries) {
    final playable = _playableEntries(teamEntries);
    if (playable.isEmpty) {
      _statusMessage = 'Keine spielbaren Spielerclips';
      notifyListeners();
      return;
    }

    if (!_isRunning) {
      startIntro(teamEntries);
      return;
    }

    _activeIndex = (_activeIndex - 1).clamp(0, playable.length - 1);
    _activePlayer = playable[_activeIndex];
    _statusMessage = 'Vorheriger Spieler';
    notifyListeners();
  }

  void skipCurrentPlayer(List<IntroSequenceEntry> teamEntries) {
    if (!_isRunning) {
      _statusMessage = 'Intro ist nicht aktiv';
      notifyListeners();
      return;
    }

    final previous = _activePlayer?.playerName ?? 'Spieler';
    playNextPlayer(teamEntries);
    _statusMessage = '$previous übersprungen';
    notifyListeners();
  }

  void playEndClip() {
    _isRunning = false;
    _activeIndex = -1;
    _activePlayer = null;
    _statusMessage = 'Endclip abgespielt';
    notifyListeners();
  }

  List<IntroSequenceEntry> _playableEntries(List<IntroSequenceEntry> teamEntries) {
    return teamEntries
        .where((entry) => entry.isActive && entry.hasValidClip)
        .toList(growable: false)
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }
}
