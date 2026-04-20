import 'package:led_managementsoftware_app/data/datasources/local/local_live_log_source.dart';
import 'package:led_managementsoftware_app/data/datasources/remote/remote_live_log_source.dart';
import 'package:led_managementsoftware_app/domain/entities/live_log_entry.dart';
import 'package:led_managementsoftware_app/domain/repositories/live_log_repository.dart';

class LiveLogRepositoryImpl implements LiveLogRepository {
  LiveLogRepositoryImpl({
    required this.localSource,
    required this.remoteSource,
  });

  final LocalLiveLogSource localSource;
  final RemoteLiveLogSource remoteSource;

  @override
  Future<List<LiveLogEntry>> fetchLogsForProject(String projectId) async {
    try {
      final remote = await remoteSource.fetchLogsForProject(projectId);
      await localSource.writeLogsForProject(projectId, remote);
      return remote;
    } catch (_) {
      return localSource.readLogsForProject(projectId);
    }
  }

  @override
  Future<LiveLogEntry> appendLog(LiveLogEntry entry) async {
    try {
      final saved = await remoteSource.appendLog(entry);
      final all = await localSource.readLogsForProject(entry.projectId);
      final next = [...all, saved];
      await localSource.writeLogsForProject(entry.projectId, next);
      return saved;
    } catch (_) {
      final all = await localSource.readLogsForProject(entry.projectId);
      final next = [...all, entry];
      await localSource.writeLogsForProject(entry.projectId, next);
      return entry;
    }
  }
}
