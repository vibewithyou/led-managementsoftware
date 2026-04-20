import 'package:led_management_software/domain/entities/live_event_log.dart';

abstract class LiveLogRepository {
  Future<void> appendLog(LiveEventLog eventLog);

  Future<List<LiveEventLog>> getLogsForProject(String projectId);

  Stream<LiveEventLog> watchLiveLogs(String projectId);

  Future<void> clearLogsForProject(String projectId);
}
