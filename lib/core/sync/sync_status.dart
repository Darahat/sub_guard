import 'package:freezed_annotation/freezed_annotation.dart';

part 'sync_status.freezed.dart';

/// Represents the sync status of the app
@freezed
class SyncStatus with _$SyncStatus {
  const factory SyncStatus({
    @Default(false) bool isSyncing,
    @Default(false) bool hasError,
    String? errorMessage,
    DateTime? lastSyncedAt,
    @Default(0) int pendingChanges,
    @Default(SyncState.idle) SyncState state,
  }) = _SyncStatus;
}

/// Sync state enum
enum SyncState { idle, syncing, success, error, offline }
