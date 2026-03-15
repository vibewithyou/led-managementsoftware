import 'package:led_management_software/features/live_control/model/live_cue_model.dart';

class LiveControlService {
  const LiveControlService();

  String loadFallbackCueLabel() {
    return 'Fallback Safe Loop';
  }

  Map<String, int> eventDurationsMs() {
    return const {
      'Tor': 7000,
      'Zeitstrafe': 8000,
      'Gelbe Karte': 6000,
      'Rote Karte': 7000,
      'Timeout': 9000,
      'Wischer': 10000,
      'Sponsor Loop': 30000,
      'Black Screen': 0,
      'Stop': 0,
      'Nächster Spieler': 6500,
    };
  }

  List<LiveCueModel> loadUpcomingCues() {
    final now = DateTime.now();
    return [
      LiveCueModel(
        id: 'q_1',
        title: 'Toranimation Heim',
        category: 'event',
        status: 'queued',
        remainingMs: 7000,
        queuedAt: now,
      ),
      LiveCueModel(
        id: 'q_2',
        title: 'Nächster Spieler',
        category: 'player',
        status: 'queued',
        remainingMs: 6500,
        queuedAt: now,
      ),
    ];
  }

  List<String> liveEventButtons() {
    return const [
      'Tor',
      'Zeitstrafe',
      'Gelbe Karte',
      'Rote Karte',
      'Timeout',
      'Wischer',
      'Sponsor Loop',
      'Black Screen',
      'Stop',
      'Nächster Spieler',
    ];
  }
}
