import 'package:led_managementsoftware_app/domain/enums/sync_status.dart';
import 'package:led_managementsoftware_app/features/sync/domain/sync_scope.dart';

class SyncSnapshot {
  const SyncSnapshot({
    required this.entityId,
    required this.scope,
    required this.status,
    required this.lastSync,
  });

  final String entityId;
  final SyncScope scope;
  final SyncStatus status;
  final DateTime? lastSync;
}
