import 'package:led_managementsoftware_app/domain/entities/live_log_entry.dart';

class LoggingController {
  const LoggingController();

  List<LiveLogEntry> filterByAction(List<LiveLogEntry> entries, String action) {
    return entries.where((entry) => entry.action == action).toList();
  }
}
