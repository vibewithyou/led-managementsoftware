import 'package:led_management_software/features/live_control/model/live_action_config.dart';

class LiveControlService {
  const LiveControlService();

  String loadFallbackCueLabel() {
    return 'Fallback Safe Loop';
  }

  int fallbackDurationFor(LiveActionConfig action) {
    return switch (action.id) {
      'goal' => 7000,
      'penalty' => 8000,
      'yellow_card' => 6000,
      'red_card' => 7000,
      'timeout' => 9000,
      'wiper' => 10000,
      'sponsor_loop' => 30000,
      'black_screen' => 0,
      'stop' => 0,
      'next_player' => 6500,
      _ => 7000,
    };
  }
}
