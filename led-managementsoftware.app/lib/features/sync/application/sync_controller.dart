import 'package:led_managementsoftware_app/core/services/sync_service.dart';
import 'package:led_managementsoftware_app/features/sync/data/sync_conflict.dart';
import 'package:led_managementsoftware_app/features/sync/domain/sync_scope.dart';
import 'package:led_managementsoftware_app/features/sync/domain/sync_snapshot.dart';

class SyncController {
  SyncController(this.service);

  final SyncService service;

  Future<void> syncNow() => service.syncNow();
  Future<DateTime?> lastSyncAt() => service.lastSyncAt();
  Future<SyncSnapshot> snapshot(String entityId, SyncScope scope) => service.snapshot(entityId, scope);
  Future<SyncConflict?> detectConflict({
    required String entityId,
    required int localVersion,
    required int remoteVersion,
  }) {
    return service.detectConflict(entityId: entityId, localVersion: localVersion, remoteVersion: remoteVersion);
  }

  Future<void> resolveConflict(SyncConflict conflict, {required bool mainPcWins}) {
    return service.resolveConflict(conflict, mainPcWins: mainPcWins);
  }
}
