import 'package:led_managementsoftware_app/data/datasources/remote/remote_live_log_source.dart';
import 'package:led_managementsoftware_app/data/datasources/remote/supabase_tables.dart';
import 'package:led_managementsoftware_app/domain/entities/live_log_entry.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseRemoteLiveLogSource implements RemoteLiveLogSource {
  SupabaseRemoteLiveLogSource(this.client);

  final SupabaseClient client;

  @override
  Future<List<LiveLogEntry>> fetchLogsForProject(String projectId) async {
    final response = await client
        .from(SupabaseTables.liveLogEntries)
        .select()
        .eq('project_id', projectId)
        .order('timestamp', ascending: false)
        .limit(300);

    return response.map(_fromDb).toList(growable: false);
  }

  @override
  Future<LiveLogEntry> appendLog(LiveLogEntry entry) async {
    final response = await client
        .from(SupabaseTables.liveLogEntries)
        .insert(_toDb(entry))
        .select()
        .single();
    return _fromDb(response);
  }

  Map<String, dynamic> _toDb(LiveLogEntry entry) {
    return {
      'id': entry.id,
      'project_id': entry.projectId,
      'timestamp': entry.timestamp.toIso8601String(),
      'device_id': entry.deviceId,
      'actor_name': entry.actorName,
      'action': entry.action,
      'details': entry.details,
      'success': entry.success,
    };
  }

  LiveLogEntry _fromDb(Map<String, dynamic> map) {
    return LiveLogEntry(
      id: map['id'] as String,
      projectId: map['project_id'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      deviceId: map['device_id'] as String,
      actorName: map['actor_name'] as String,
      action: map['action'] as String,
      details: map['details'] as String,
      success: map['success'] as bool,
    );
  }
}
