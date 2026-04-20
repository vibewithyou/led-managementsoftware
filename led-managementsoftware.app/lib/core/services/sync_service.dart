import 'package:led_managementsoftware_app/features/sync/data/sync_conflict.dart';
import 'package:led_managementsoftware_app/features/sync/domain/sync_scope.dart';
import 'package:led_managementsoftware_app/features/sync/domain/sync_snapshot.dart';

abstract class SyncService {
  Future<void> syncNow();
  Future<DateTime?> lastSyncAt();
  Future<SyncSnapshot> snapshot(String entityId, SyncScope scope);
  Future<SyncConflict?> detectConflict({
    required String entityId,
    required int localVersion,
    required int remoteVersion,
  });
  Future<void> resolveConflict(SyncConflict conflict, {required bool mainPcWins});
}
