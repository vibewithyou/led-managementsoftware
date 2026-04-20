enum SyncStatus { localOnly, synced, pending, conflict }

extension SyncStatusX on SyncStatus {
  String get label {
    switch (this) {
      case SyncStatus.localOnly:
        return 'Nur lokal';
      case SyncStatus.synced:
        return 'Synchron';
      case SyncStatus.pending:
        return 'Ausstehend';
      case SyncStatus.conflict:
        return 'Konflikt';
    }
  }

  static SyncStatus fromValue(String raw) {
    return SyncStatus.values.firstWhere(
      (status) => status.name == raw,
      orElse: () => SyncStatus.localOnly,
    );
  }
}
