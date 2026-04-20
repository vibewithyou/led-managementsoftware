import 'package:led_managementsoftware_app/data/datasources/remote/remote_live_log_source.dart';
import 'package:led_managementsoftware_app/domain/entities/live_log_entry.dart';

class OfflineRemoteLiveLogSource implements RemoteLiveLogSource {
  final Map<String, List<LiveLogEntry>> _store = {};

  @override
  Future<List<LiveLogEntry>> fetchLogsForProject(String projectId) async {
    return List<LiveLogEntry>.from(_store[projectId] ?? const []);
  }

  @override
  Future<LiveLogEntry> appendLog(LiveLogEntry entry) async {
    final logs = List<LiveLogEntry>.from(_store[entry.projectId] ?? const []);
    logs.add(entry);
    _store[entry.projectId] = logs;
    return entry;
  }
}
