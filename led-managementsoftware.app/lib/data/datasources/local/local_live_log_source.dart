import 'package:led_managementsoftware_app/domain/entities/live_log_entry.dart';

abstract class LocalLiveLogSource {
  Future<List<LiveLogEntry>> readLogsForProject(String projectId);
  Future<void> writeLogsForProject(String projectId, List<LiveLogEntry> entries);
}
