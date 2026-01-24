import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/notifications/notification_service.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/usecases/notification_usecases.dart';
import 'notification_providers.dart';

/// Notification settings state
class NotificationSettingsState {
  final NotificationSettingsEntity settings;
  final bool isLoading;
  final String? errorMessage;

  const NotificationSettingsState({
    required this.settings,
    this.isLoading = false,
    this.errorMessage,
  });

  NotificationSettingsState copyWith({
    NotificationSettingsEntity? settings,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return NotificationSettingsState(
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Notification settings notifier
class NotificationSettingsNotifier
    extends StateNotifier<NotificationSettingsState> {
  final GetNotificationSettingsUseCase _getSettingsUseCase;
  final UpdateNotificationSettingsUseCase _updateSettingsUseCase;
  final NotificationService _notificationService;

  NotificationSettingsNotifier(
    this._getSettingsUseCase,
    this._updateSettingsUseCase,
    this._notificationService,
  ) : super(
        NotificationSettingsState(settings: const NotificationSettingsEntity()),
      ) {
    loadSettings();
  }

  /// Load notification settings
  Future<void> loadSettings() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _getSettingsUseCase();

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (NotificationSettingsEntity settings) =>
          state = state.copyWith(isLoading: false, settings: settings),
    );
  }

  /// Toggle notifications on/off
  Future<void> toggleNotifications(bool enabled) async {
    final updatedSettings = state.settings.copyWith(enabled: enabled);
    await _updateSettings(updatedSettings);
  }

  /// Toggle sound on/off
  Future<void> toggleSound(bool enabled) async {
    final updatedSettings = state.settings.copyWith(soundEnabled: enabled);
    await _updateSettings(updatedSettings);
  }

  /// Toggle vibration on/off
  Future<void> toggleVibration(bool enabled) async {
    final updatedSettings = state.settings.copyWith(vibrationEnabled: enabled);
    await _updateSettings(updatedSettings);
  }

  /// Toggle badge on/off
  Future<void> toggleBadge(bool enabled) async {
    final updatedSettings = state.settings.copyWith(badgeEnabled: enabled);
    await _updateSettings(updatedSettings);
  }

  /// Toggle reminder day
  Future<void> toggleReminderDay(int days) async {
    final currentDays = List<int>.from(state.settings.defaultReminderDays);

    if (currentDays.contains(days)) {
      currentDays.remove(days);
    } else {
      currentDays.add(days);
    }

    // Sort in ascending order
    currentDays.sort();

    final updatedSettings = state.settings.copyWith(
      defaultReminderDays: currentDays,
    );
    await _updateSettings(updatedSettings);
  }

  /// Send test notification
  Future<void> sendTestNotification() async {
    try {
      await _notificationService.scheduleNotification(
        id: 99999,
        title: 'Test Notification',
        body: 'This is a test notification from SubGuard!',
        scheduledDate: DateTime.now().add(const Duration(seconds: 5)),
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to send test notification: $e',
      );
    }
  }

  /// Update settings
  Future<void> _updateSettings(NotificationSettingsEntity settings) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _updateSettingsUseCase(settings);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (_) => state = state.copyWith(isLoading: false, settings: settings),
    );
  }
}

/// Notification settings notifier provider
final notificationSettingsNotifierProvider =
    StateNotifierProvider<
      NotificationSettingsNotifier,
      NotificationSettingsState
    >((ref) {
      return NotificationSettingsNotifier(
        ref.watch(getNotificationSettingsUseCaseProvider),
        ref.watch(updateNotificationSettingsUseCaseProvider),
        ref.watch(notificationServiceProvider),
      );
    });
