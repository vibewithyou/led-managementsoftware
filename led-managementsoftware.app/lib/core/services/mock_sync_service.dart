import 'package:led_managementsoftware_app/core/services/sync_service.dart';
import 'package:led_managementsoftware_app/domain/enums/sync_status.dart';
import 'package:led_managementsoftware_app/features/sync/data/sync_conflict.dart';
import 'package:led_managementsoftware_app/features/sync/domain/sync_scope.dart';
import 'package:led_managementsoftware_app/features/sync/domain/sync_snapshot.dart';

class MockSyncService implements SyncService {
  DateTime? _lastSync;
  final Map<String, SyncStatus> _projectState = {};
  final Map<String, SyncStatus> _mediaState = {};
  final Map<String, SyncStatus> _deviceState = {'main-pc': SyncStatus.synced, 'tablet-1': SyncStatus.pending};

  @override
  Future<DateTime?> lastSyncAt() async => _lastSync;

  @override
  Future<void> syncNow() async {
    _lastSync = DateTime.now();
    for (final id in _projectState.keys) {
      _projectState[id] = SyncStatus.synced;
    }
    for (final id in _mediaState.keys) {
      _mediaState[id] = SyncStatus.synced;
    }
    for (final id in _deviceState.keys) {
      _deviceState[id] = SyncStatus.synced;
    }
  }

  @override
  Future<SyncSnapshot> snapshot(String entityId, SyncScope scope) async {
    final state = switch (scope) {
      SyncScope.project => _projectState[entityId] ?? SyncStatus.localOnly,
      SyncScope.media => _mediaState[entityId] ?? SyncStatus.localOnly,
      SyncScope.device => _deviceState[entityId] ?? SyncStatus.localOnly,
    };
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
    final resolved = mainPcWins ? SyncStatus.synced : SyncStatus.conflict;
    _projectState[conflict.entityId] = resolved;
  }
}
