import 'package:led_managementsoftware_app/data/datasources/local/local_live_log_source.dart';
import 'package:led_managementsoftware_app/domain/entities/live_log_entry.dart';

class InMemoryLiveLogSource implements LocalLiveLogSource {
  final Map<String, List<LiveLogEntry>> _store = {};

  @override
  Future<List<LiveLogEntry>> readLogsForProject(String projectId) async {
    return List<LiveLogEntry>.from(_store[projectId] ?? const []);
  }

  @override
  Future<void> writeLogsForProject(String projectId, List<LiveLogEntry> entries) async {
    _store[projectId] = List<LiveLogEntry>.from(entries);
  }
}
