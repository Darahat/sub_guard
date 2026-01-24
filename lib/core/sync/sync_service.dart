import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/subscriptions/data/datasources/local_subscription_datasource.dart';
import '../../features/subscriptions/data/datasources/remote_subscription_datasource.dart';
import '../../features/subscriptions/presentation/providers/subscription_providers.dart';
import 'sync_status.dart';

/// Service for synchronizing local and remote data
class SyncService {
  final LocalSubscriptionDataSource _localDataSource;
  final RemoteSubscriptionDataSource _remoteDataSource;
  final Connectivity _connectivity;
  final Ref _ref;

  SyncService(
    this._localDataSource,
    this._remoteDataSource,
    this._connectivity,
    this._ref,
  );

  final _syncStatusController = StreamController<SyncStatus>.broadcast();
  Stream<SyncStatus> get syncStatusStream => _syncStatusController.stream;

  SyncStatus _currentStatus = const SyncStatus();
  SyncStatus get currentStatus => _currentStatus;

  Timer? _periodicSyncTimer;
  StreamSubscription? _connectivitySubscription;

  /// Initialize sync service
  Future<void> initialize() async {
    // Listen to connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      result,
    ) {
      if (result.contains(ConnectivityResult.none)) {
        _updateStatus(_currentStatus.copyWith(state: SyncState.offline));
      } else if (_currentStatus.state == SyncState.offline) {
        // Back online, trigger sync
        syncAll();
      }
    });

    // Start periodic sync (every 5 minutes)
    _periodicSyncTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => syncAll(),
    );

    // Initial sync
    await syncAll();
  }

  /// Sync all data (subscriptions, budgets, etc.)
  Future<void> syncAll({String? userId}) async {
    if (_currentStatus.isSyncing) {
      return; // Already syncing
    }

    // Check connectivity
    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      _updateStatus(_currentStatus.copyWith(state: SyncState.offline));
      return;
    }

    try {
      _updateStatus(
        _currentStatus.copyWith(
          isSyncing: true,
          hasError: false,
          state: SyncState.syncing,
        ),
      );

      // Get user ID from auth if not provided
      // TODO: Get from auth provider
      final currentUserId =
          userId ?? 'demo-user'; // Replace with actual user ID

      // Sync subscriptions
      await _syncSubscriptions(currentUserId);

      // Update status to success
      _updateStatus(
        _currentStatus.copyWith(
          isSyncing: false,
          hasError: false,
          lastSyncedAt: DateTime.now(),
          pendingChanges: 0,
          state: SyncState.success,
        ),
      );
    } catch (e) {
      _updateStatus(
        _currentStatus.copyWith(
          isSyncing: false,
          hasError: true,
          errorMessage: e.toString(),
          state: SyncState.error,
        ),
      );
    }
  }

  /// Sync subscriptions between local and remote
  Future<void> _syncSubscriptions(String userId) async {
    try {
      // Get local subscriptions
      final localSubscriptions = await _localDataSource.getAllSubscriptions();

      // Get remote subscriptions
      final remoteSubscriptions = await _remoteDataSource.getAllSubscriptions(
        userId,
      );

      // Create maps for easier lookup
      final localMap = {
        for (var sub in localSubscriptions) sub.subscriptionId: sub,
      };
      final remoteMap = {
        for (var sub in remoteSubscriptions) sub.subscriptionId: sub,
      };

      // Find items to upload (local but not remote, or local is newer)
      for (final local in localSubscriptions) {
        final remote = remoteMap[local.subscriptionId];

        if (remote == null) {
          // Local item doesn't exist remotely, upload it
          await _remoteDataSource.createSubscription(userId, local);
        } else if (local.updatedAt != null &&
            remote.updatedAt != null &&
            local.updatedAt!.isAfter(remote.updatedAt!)) {
          // Local is newer, update remote
          await _remoteDataSource.updateSubscription(
            userId,
            local.subscriptionId,
            local,
          );
        }
      }

      // Find items to download (remote but not local, or remote is newer)
      for (final remote in remoteSubscriptions) {
        final local = localMap[remote.subscriptionId];

        if (local == null) {
          // Remote item doesn't exist locally, download it
          await _localDataSource.addSubscription(remote);
        } else if (remote.updatedAt != null &&
            local.updatedAt != null &&
            remote.updatedAt!.isAfter(local.updatedAt!)) {
          // Remote is newer, update local
          await _localDataSource.updateSubscription(remote);
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Update sync status and notify listeners
  void _updateStatus(SyncStatus status) {
    _currentStatus = status;
    _syncStatusController.add(status);
  }

  /// Dispose resources
  void dispose() {
    _periodicSyncTimer?.cancel();
    _connectivitySubscription?.cancel();
    _syncStatusController.close();
  }
}

/// Provider for SyncService
final syncServiceProvider = Provider<SyncService>((ref) {
  final localDataSource = ref.watch(localSubscriptionDataSourceProvider);
  final remoteDataSource = ref.watch(remoteSubscriptionDataSourceProvider);
  final connectivity = Connectivity();

  final service = SyncService(
    localDataSource,
    remoteDataSource,
    connectivity,
    ref,
  );

  // Initialize on creation
  service.initialize();

  // Dispose when provider is disposed
  ref.onDispose(() {
    service.dispose();
  });

  return service;
});

/// Provider for remote subscription data source
final remoteSubscriptionDataSourceProvider =
    Provider<RemoteSubscriptionDataSource>((ref) {
      // TODO: Get Firestore instance from Firebase setup
      throw UnimplementedError(
        'Remote subscription data source not configured yet',
      );
    });
