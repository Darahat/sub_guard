import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../notifications/domain/usecases/notification_usecases.dart';
import '../../../notifications/presentation/providers/notification_providers.dart';
import '../../domain/entities/subscription_entity.dart';
import '../../domain/usecases/add_subscription_usecase.dart';
import '../../domain/usecases/cancel_subscription_usecase.dart';
import '../../domain/usecases/delete_subscription_usecase.dart';
import '../../domain/usecases/export_subscriptions_csv_usecase.dart';
import '../../domain/usecases/get_all_subscriptions_usecase.dart';
import '../../domain/usecases/get_total_spending_usecase.dart';
import '../../domain/usecases/import_subscriptions_csv_usecase.dart';
import '../../domain/usecases/update_subscription_usecase.dart';
import 'subscription_providers.dart';

/// Subscription state
class SubscriptionState {
  final List<SubscriptionEntity> subscriptions;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;
  final double totalMonthlySpending;
  final double totalYearlySpending;

  const SubscriptionState({
    this.subscriptions = const [],
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
    this.totalMonthlySpending = 0.0,
    this.totalYearlySpending = 0.0,
  });

  SubscriptionState copyWith({
    List<SubscriptionEntity>? subscriptions,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    double? totalMonthlySpending,
    double? totalYearlySpending,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return SubscriptionState(
      subscriptions: subscriptions ?? this.subscriptions,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
      totalMonthlySpending: totalMonthlySpending ?? this.totalMonthlySpending,
      totalYearlySpending: totalYearlySpending ?? this.totalYearlySpending,
    );
  }

  /// Get active subscriptions
  List<SubscriptionEntity> get activeSubscriptions {
    return subscriptions
        .where((s) => s.status == SubscriptionStatus.active)
        .toList();
  }

  /// Get expiring soon subscriptions
  List<SubscriptionEntity> get expiringSoonSubscriptions {
    return activeSubscriptions.where((s) => s.isExpiringSoon).toList();
  }

  /// Get subscription count
  int get subscriptionCount => subscriptions.length;

  /// Get active subscription count
  int get activeSubscriptionCount => activeSubscriptions.length;
}

/// Subscription state notifier
class SubscriptionNotifier extends StateNotifier<SubscriptionState> {
  final GetAllSubscriptionsUseCase getAllSubscriptionsUseCase;
  final AddSubscriptionUseCase addSubscriptionUseCase;
  final UpdateSubscriptionUseCase updateSubscriptionUseCase;
  final DeleteSubscriptionUseCase deleteSubscriptionUseCase;
  final CancelSubscriptionUseCase cancelSubscriptionUseCase;
  final GetTotalMonthlySpendingUseCase getTotalMonthlySpendingUseCase;
  final GetTotalYearlySpendingUseCase getTotalYearlySpendingUseCase;
  final ScheduleRenewalReminderUseCase scheduleRenewalReminderUseCase;
  final CancelNotificationsBySubscriptionUseCase
  cancelNotificationsBySubscriptionUseCase;
  final GetNotificationSettingsUseCase getNotificationSettingsUseCase;
  final ExportSubscriptionsCsvUseCase exportSubscriptionsCsvUseCase;
  final ImportSubscriptionsCsvUseCase importSubscriptionsCsvUseCase;

  SubscriptionNotifier({
    required this.getAllSubscriptionsUseCase,
    required this.addSubscriptionUseCase,
    required this.updateSubscriptionUseCase,
    required this.deleteSubscriptionUseCase,
    required this.cancelSubscriptionUseCase,
    required this.getTotalMonthlySpendingUseCase,
    required this.getTotalYearlySpendingUseCase,
    required this.scheduleRenewalReminderUseCase,
    required this.cancelNotificationsBySubscriptionUseCase,
    required this.getNotificationSettingsUseCase,
    required this.exportSubscriptionsCsvUseCase,
    required this.importSubscriptionsCsvUseCase,
  }) : super(const SubscriptionState()) {
    // Load subscriptions on init
    loadSubscriptions();
  }

  /// Load all subscriptions
  Future<void> loadSubscriptions() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await getAllSubscriptionsUseCase();

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (subscriptions) async {
        // Calculate totals
        final monthlyResult = await getTotalMonthlySpendingUseCase();
        final yearlyResult = await getTotalYearlySpendingUseCase();

        double monthlyTotal = 0.0;
        double yearlyTotal = 0.0;

        monthlyResult.fold((l) => null, (r) => monthlyTotal = r);
        yearlyResult.fold((l) => null, (r) => yearlyTotal = r);

        state = state.copyWith(
          isLoading: false,
          subscriptions: subscriptions,
          totalMonthlySpending: monthlyTotal,
          totalYearlySpending: yearlyTotal,
        );
      },
    );
  }

  /// Add new subscription
  Future<void> addSubscription(SubscriptionEntity subscription) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
    );

    final result = await addSubscriptionUseCase(subscription);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (added) async {
        // Schedule notifications for active subscriptions
        if (added.status == SubscriptionStatus.active) {
          await _scheduleNotificationsForSubscription(added);
        }

        state = state.copyWith(
          isLoading: false,
          successMessage: 'Subscription added successfully!',
        );
        loadSubscriptions(); // Reload to update totals
      },
    );
  }

  /// Update subscription
  Future<void> updateSubscription(SubscriptionEntity subscription) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
    );

    final result = await updateSubscriptionUseCase(subscription);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (updated) async {
        // Cancel existing notifications
        await cancelNotificationsBySubscriptionUseCase(updated.id);

        // Reschedule if active
        if (updated.status == SubscriptionStatus.active) {
          await _scheduleNotificationsForSubscription(updated);
        }

        state = state.copyWith(
          isLoading: false,
          successMessage: 'Subscription updated successfully!',
        );
        loadSubscriptions();
      },
    );
  }

  /// Delete subscription
  Future<void> deleteSubscription(String id) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
    );

    final result = await deleteSubscriptionUseCase(id);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (_) async {
        // Cancel all notifications for this subscription
        await cancelNotificationsBySubscriptionUseCase(id);

        state = state.copyWith(
          isLoading: false,
          successMessage: 'Subscription deleted successfully!',
        );
        loadSubscriptions();
      },
    );
  }

  /// Cancel subscription
  Future<void> cancelSubscription(String id) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
    );

    final result = await cancelSubscriptionUseCase(id);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (cancelled) {
        state = state.copyWith(
          isLoading: false,
          successMessage: 'Subscription cancelled successfully!',
        );
        loadSubscriptions();
      },
    );
  }

  /// Search subscriptions
  void searchSubscriptions(String query) {
    if (query.isEmpty) {
      loadSubscriptions();
      return;
    }

    final filtered = state.subscriptions.where((sub) {
      return sub.serviceName.toLowerCase().contains(query.toLowerCase()) ||
          (sub.description?.toLowerCase().contains(query.toLowerCase()) ??
              false);
    }).toList();

    state = state.copyWith(subscriptions: filtered);
  }

  /// Filter by status
  void filterByStatus(SubscriptionStatus status) {
    final filtered = state.subscriptions
        .where((sub) => sub.status == status)
        .toList();
    state = state.copyWith(subscriptions: filtered);
  }

  /// Clear messages
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void clearSuccess() {
    state = state.copyWith(clearSuccess: true);
  }

  /// Export all subscriptions to CSV and trigger share
  Future<void> exportCsv() async {
    if (state.subscriptions.isEmpty) {
      state = state.copyWith(errorMessage: 'No subscriptions to export.');
      return;
    }

    state = state.copyWith(isLoading: true);
    final result = await exportSubscriptionsCsvUseCase.execute(state.subscriptions);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (filePath) => state = state.copyWith(
        isLoading: false,
        successMessage: 'CSV exported successfully!',
      ),
    );
  }

  /// Pick and import subscriptions from CSV file
  Future<void> importCsv({required String userId}) async {
    state = state.copyWith(isLoading: true);
    final result = await importSubscriptionsCsvUseCase.execute(userId: userId);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (importResult) {
        if (importResult == null) {
          // Cancelled by user
          state = state.copyWith(isLoading: false);
          return;
        }

        if (importResult.validCount == 0) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: importResult.errorMessages.isNotEmpty
                ? importResult.errorMessages.first
                : 'No valid subscriptions could be imported from CSV.',
          );
        } else {
          state = state.copyWith(
            isLoading: false,
            successMessage:
                'Successfully imported ${importResult.validCount} subscriptions!'
                '${importResult.skippedCount > 0 ? ' (${importResult.skippedCount} rows skipped)' : ''}',
          );
          // Reload subscriptions to update list and totals
          loadSubscriptions();
        }
      },
    );
  }

  /// Schedule notifications for a subscription
  Future<void> _scheduleNotificationsForSubscription(
    SubscriptionEntity subscription,
  ) async {
    // Get notification settings
    final settingsResult = await getNotificationSettingsUseCase();

    settingsResult.fold(
      (failure) => null, // Silently fail if settings can't be loaded
      (settings) async {
        if (!settings.enabled) return;

        // Schedule notifications for each configured reminder day
        for (final days in settings.defaultReminderDays) {
          await scheduleRenewalReminderUseCase(
            subscription: subscription,
            daysBeforeRenewal: days,
          );
        }
      },
    );
  }
}

/// Subscription notifier provider
final subscriptionNotifierProvider =
    StateNotifierProvider<SubscriptionNotifier, SubscriptionState>((ref) {
      return SubscriptionNotifier(
        getAllSubscriptionsUseCase: ref.watch(
          getAllSubscriptionsUseCaseProvider,
        ),
        addSubscriptionUseCase: ref.watch(addSubscriptionUseCaseProvider),
        updateSubscriptionUseCase: ref.watch(updateSubscriptionUseCaseProvider),
        deleteSubscriptionUseCase: ref.watch(deleteSubscriptionUseCaseProvider),
        cancelSubscriptionUseCase: ref.watch(cancelSubscriptionUseCaseProvider),
        getTotalMonthlySpendingUseCase: ref.watch(
          getTotalMonthlySpendingUseCaseProvider,
        ),
        getTotalYearlySpendingUseCase: ref.watch(
          getTotalYearlySpendingUseCaseProvider,
        ),
        scheduleRenewalReminderUseCase: ref.watch(
          scheduleRenewalReminderUseCaseProvider,
        ),
        cancelNotificationsBySubscriptionUseCase: ref.watch(
          cancelNotificationsBySubscriptionUseCaseProvider,
        ),
        getNotificationSettingsUseCase: ref.watch(
          getNotificationSettingsUseCaseProvider,
        ),
        exportSubscriptionsCsvUseCase: ref.watch(
          exportSubscriptionsCsvUseCaseProvider,
        ),
        importSubscriptionsCsvUseCase: ref.watch(
          importSubscriptionsCsvUseCaseProvider,
        ),
      );
    });
