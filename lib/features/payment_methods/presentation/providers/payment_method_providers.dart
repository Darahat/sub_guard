import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/currency/currency_converter.dart';
import '../../../../core/database/hive_provider.dart';
import '../../../budget/presentation/providers/budget_providers.dart';
import '../../../notifications/domain/services/payment_expiry_notification_scheduler.dart';
import '../../../notifications/presentation/providers/notification_providers.dart';
import '../../../subscriptions/presentation/providers/subscription_notifier.dart';
import '../../data/datasources/payment_method_local_datasource.dart';
import '../../data/repositories/payment_method_repository_impl.dart';
import '../../domain/entities/payment_method_entity.dart';
import '../../domain/repositories/payment_method_repository.dart';
import '../../domain/services/payment_shield_evaluator.dart';

/// Provider for local data source
final paymentMethodLocalDataSourceProvider =
    Provider<PaymentMethodLocalDataSource>((ref) {
      return PaymentMethodLocalDataSourceImpl(
        paymentMethodsBox: ref.watch(paymentMethodsBoxProvider),
      );
    });

/// Provider for repository
final paymentMethodRepositoryProvider = Provider<PaymentMethodRepository>((
  ref,
) {
  return PaymentMethodRepositoryImpl(
    ref.watch(paymentMethodLocalDataSourceProvider),
  );
});

/// Payment Methods State
class PaymentMethodState {
  final List<PaymentMethodEntity> paymentMethods;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  const PaymentMethodState({
    this.paymentMethods = const [],
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  PaymentMethodEntity? get defaultMethod =>
      paymentMethods.where((m) => m.isDefault).firstOrNull ??
      paymentMethods.firstOrNull;

  PaymentMethodState copyWith({
    List<PaymentMethodEntity>? paymentMethods,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return PaymentMethodState(
      paymentMethods: paymentMethods ?? this.paymentMethods,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
    );
  }
}

/// Payment Methods State Notifier
class PaymentMethodNotifier extends StateNotifier<PaymentMethodState> {
  final PaymentMethodRepository _repository;
  final Ref _ref;

  PaymentMethodNotifier(this._repository, this._ref)
    : super(const PaymentMethodState()) {
    loadPaymentMethods();
  }

  /// Load all payment methods
  Future<void> loadPaymentMethods() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _repository.getPaymentMethods();
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (methods) {
        state = state.copyWith(isLoading: false, paymentMethods: methods);
      },
    );
  }

  /// Add a new payment method
  Future<bool> addPaymentMethod(PaymentMethodEntity method) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
    );
    final result = await _repository.addPaymentMethod(method);
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
      (saved) async {
        final scheduler = PaymentExpiryNotificationScheduler(
          notificationService: _ref.read(notificationServiceProvider),
        );
        await scheduler.scheduleExpiryReminders(saved);

        state = state.copyWith(
          isLoading: false,
          successMessage: 'Payment method added successfully',
        );
        await loadPaymentMethods();
        return true;
      },
    );
  }

  /// Update an existing payment method
  Future<bool> updatePaymentMethod(PaymentMethodEntity method) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
    );
    final result = await _repository.updatePaymentMethod(method);
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
      (updated) async {
        final scheduler = PaymentExpiryNotificationScheduler(
          notificationService: _ref.read(notificationServiceProvider),
        );
        await scheduler.scheduleExpiryReminders(updated);

        state = state.copyWith(
          isLoading: false,
          successMessage: 'Payment method updated successfully',
        );
        await loadPaymentMethods();
        return true;
      },
    );
  }

  /// Delete a payment method and optionally unlink attached subscriptions
  Future<bool> deletePaymentMethod(String id) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
    );

    // Cancel alarms
    final scheduler = PaymentExpiryNotificationScheduler(
      notificationService: _ref.read(notificationServiceProvider),
    );
    await scheduler.cancelExpiryReminders(id);

    final result = await _repository.deletePaymentMethod(id);
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
      (_) async {
        // Unlink any subscriptions using this payment method
        final subs = _ref.read(subscriptionNotifierProvider).subscriptions;
        for (final sub in subs) {
          if (sub.paymentMethodId == id) {
            await _ref
                .read(subscriptionNotifierProvider.notifier)
                .updateSubscription(sub.copyWith(clearPaymentMethod: true));
          }
        }

        state = state.copyWith(
          isLoading: false,
          successMessage: 'Payment method removed',
        );
        await loadPaymentMethods();
        return true;
      },
    );
  }

  /// Bulk reassigns a list of subscriptions from one payment method to another
  Future<void> reassignSubscriptions({
    required List<String> subscriptionIds,
    required String? newPaymentMethodId,
  }) async {
    final subs = _ref.read(subscriptionNotifierProvider).subscriptions;
    for (final sub in subs) {
      if (subscriptionIds.contains(sub.id)) {
        final updated = newPaymentMethodId == null
            ? sub.copyWith(clearPaymentMethod: true)
            : sub.copyWith(paymentMethodId: newPaymentMethodId);
        await _ref
            .read(subscriptionNotifierProvider.notifier)
            .updateSubscription(updated);
      }
    }
  }
}

/// Main StateNotifier provider for payment methods
final paymentMethodNotifierProvider =
    StateNotifierProvider<PaymentMethodNotifier, PaymentMethodState>((ref) {
      final repository = ref.watch(paymentMethodRepositoryProvider);
      return PaymentMethodNotifier(repository, ref);
    });

/// Evaluates active risks for Payment Shield on Dashboard
final paymentShieldRisksProvider = Provider<List<PaymentShieldRiskGroup>>((
  ref,
) {
  final paymentState = ref.watch(paymentMethodNotifierProvider);
  final subscriptions = ref.watch(subscriptionNotifierProvider).subscriptions;
  final primaryCurrency = ref.watch(primaryCurrencyProvider);
  final converter = ref.watch(currencyConverterProvider);

  return PaymentShieldEvaluator.evaluate(
    paymentMethods: paymentState.paymentMethods,
    subscriptions: subscriptions,
    primaryCurrency: primaryCurrency,
    converter: converter,
  );
});

/// Evaluates spending breakdown across all payment methods
final paymentMethodSpendBreakdownProvider =
    Provider<List<PaymentMethodSpendSummary>>((ref) {
      final paymentState = ref.watch(paymentMethodNotifierProvider);
      final subscriptions = ref
          .watch(subscriptionNotifierProvider)
          .subscriptions;
      final primaryCurrency = ref.watch(primaryCurrencyProvider);
      final converter = ref.watch(currencyConverterProvider);

      return PaymentShieldEvaluator.calculateSpendBreakdown(
        paymentMethods: paymentState.paymentMethods,
        subscriptions: subscriptions,
        primaryCurrency: primaryCurrency,
        converter: converter,
      );
    });
