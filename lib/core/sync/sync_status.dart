/// Represents the sync status of the app
class SyncStatus {
  final bool isSyncing;
  final bool hasError;
  final String? errorMessage;
  final DateTime? lastSyncedAt;
  final int pendingChanges;
  final SyncState state;

  const SyncStatus({
    this.isSyncing = false,
    this.hasError = false,
    this.errorMessage,
    this.lastSyncedAt,
    this.pendingChanges = 0,
    this.state = SyncState.idle,
  });

  SyncStatus copyWith({
    bool? isSyncing,
    bool? hasError,
    String? errorMessage,
    DateTime? lastSyncedAt,
    int? pendingChanges,
    SyncState? state,
  }) {
    return SyncStatus(
      isSyncing: isSyncing ?? this.isSyncing,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      pendingChanges: pendingChanges ?? this.pendingChanges,
      state: state ?? this.state,
    );
  }
}

/// Sync state enum
enum SyncState { idle, syncing, success, error, offline }
