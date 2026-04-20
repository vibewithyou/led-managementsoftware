import 'package:led_managementsoftware_app/core/config/backend_runtime.dart';
import 'package:led_managementsoftware_app/core/services/sync_service.dart';
import 'package:led_managementsoftware_app/domain/enums/sync_status.dart';
import 'package:led_managementsoftware_app/features/sync/data/sync_conflict.dart';
import 'package:led_managementsoftware_app/features/sync/domain/sync_scope.dart';
import 'package:led_managementsoftware_app/features/sync/domain/sync_snapshot.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseSyncService implements SyncService {
  SupabaseSyncService({
    required this.runtime,
    SupabaseClient? client,
  }) : _client = client ?? runtime.client;

  final BackendRuntime runtime;
  final SupabaseClient? _client;

  DateTime? _lastSync;
  final Map<String, SyncStatus> _projectState = {};
  final Map<String, SyncStatus> _mediaState = {};
  final Map<String, SyncStatus> _deviceState = {};

  bool get _remoteEnabled => runtime.remoteEnabled && _client != null;

  @override
  Future<void> syncNow() async {
    _lastSync = DateTime.now();

    if (_remoteEnabled) {
      final client = _client!;
      try {
        await client.from('device_profiles').upsert({
          'id': runtime.config.mainDeviceId,
          'name': 'Haupt-PC',
          'type': 'mainPc',
          'is_online': true,
          'is_main_pc': runtime.config.mainPcPriority,
          'last_sync_at': _lastSync!.toIso8601String(),
          'main_pc_last_editor': runtime.config.mainDeviceId,
          'sync_version': 1,
        }, onConflict: 'id');
      } catch (_) {
        // Keep offline-first behavior when remote update fails.
      }
    }

    _markAllSynced();
  }

  @override
  Future<DateTime?> lastSyncAt() async => _lastSync;

  @override
  Future<SyncSnapshot> snapshot(String entityId, SyncScope scope) async {
    if (_remoteEnabled) {
      final client = _client!;
      try {
        final row = await client
            .from(_tableForScope(scope))
            .select('id,updated_at')
            .eq('id', entityId)
            .limit(1)
            .maybeSingle();

        if (row != null) {
          final updatedAtRaw = row['updated_at'] as String?;
          final status = SyncStatus.synced;
          _setState(scope, entityId, status);
          return SyncSnapshot(
            entityId: entityId,
            scope: scope,
            status: status,
            lastSync: updatedAtRaw == null ? _lastSync : DateTime.tryParse(updatedAtRaw) ?? _lastSync,
          );
        }

        _setState(scope, entityId, SyncStatus.localOnly);
        return SyncSnapshot(entityId: entityId, scope: scope, status: SyncStatus.localOnly, lastSync: _lastSync);
      } catch (_) {
        // Fall through to local snapshot state.
      }
    }

    final state = _getState(scope, entityId);
    return SyncSnapshot(entityId: entityId, scope: scope, status: state, lastSync: _lastSync);
  }

  @override
  Future<SyncConflict?> detectConflict({
    required String entityId,
    required int localVersion,
    required int remoteVersion,
  }) async {
    if (localVersion == remoteVersion) {
      return null;
    }

    return SyncConflict(
      entityId: entityId,
      scope: SyncScope.project.name,
      localVersion: localVersion,
      remoteVersion: remoteVersion,
    );
  }

  @override
  Future<void> resolveConflict(SyncConflict conflict, {required bool mainPcWins}) async {
    final status = mainPcWins ? SyncStatus.synced : SyncStatus.conflict;
    _setState(SyncScope.project, conflict.entityId, status);

    if (!_remoteEnabled) {
      return;
    }

    final client = _client!;
    try {
      final resolvedVersion = mainPcWins ? conflict.localVersion + 1 : conflict.remoteVersion;
      await client.from('projects').update({
        'sync_version': resolvedVersion,
        'main_pc_last_editor': mainPcWins ? runtime.config.mainDeviceId : null,
      }).eq('id', conflict.entityId);
    } catch (_) {
      // Keep state local-only if backend update is blocked.
    }
  }

  void _markAllSynced() {
    for (final id in _projectState.keys) {
      _projectState[id] = SyncStatus.synced;
    }
    for (final id in _mediaState.keys) {
      _mediaState[id] = SyncStatus.synced;
    }
    for (final id in _deviceState.keys) {
      _deviceState[id] = SyncStatus.synced;
    }
    _deviceState[runtime.config.mainDeviceId] = SyncStatus.synced;
  }

  String _tableForScope(SyncScope scope) {
    return switch (scope) {
      SyncScope.project => 'projects',
      SyncScope.media => 'media_items',
      SyncScope.device => 'device_profiles',
    };
  }

  SyncStatus _getState(SyncScope scope, String entityId) {
    return switch (scope) {
      SyncScope.project => _projectState[entityId] ?? SyncStatus.localOnly,
      SyncScope.media => _mediaState[entityId] ?? SyncStatus.localOnly,
      SyncScope.device => _deviceState[entityId] ?? SyncStatus.localOnly,
    };
  }

  void _setState(SyncScope scope, String entityId, SyncStatus status) {
    switch (scope) {
      case SyncScope.project:
        _projectState[entityId] = status;
      case SyncScope.media:
        _mediaState[entityId] = status;
      case SyncScope.device:
        _deviceState[entityId] = status;
    }
  }
}
