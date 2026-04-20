class SyncConflict {
  const SyncConflict({
    required this.entityId,
    required this.scope,
    required this.localVersion,
    required this.remoteVersion,
  });

  final String entityId;
  final String scope;
  final int localVersion;
  final int remoteVersion;
}
