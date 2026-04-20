import 'package:led_managementsoftware_app/domain/entities/live_log_entry.dart';

abstract class RemoteLiveLogSource {
  Future<List<LiveLogEntry>> fetchLogsForProject(String projectId);
  Future<LiveLogEntry> appendLog(LiveLogEntry entry);
}
