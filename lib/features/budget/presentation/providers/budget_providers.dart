import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/currency/currency_converter.dart';
import '../../../subscriptions/presentation/providers/subscription_notifier.dart';
import '../../domain/entities/budget_health.dart';
import '../../domain/services/budget_calculator.dart';

const _kPrimaryCurrencyKey = 'subguard_primary_currency';
const _kMonthlyBudgetKey = 'subguard_monthly_budget_limit';

final _secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

/// Notifier for user's primary display currency
class PrimaryCurrencyNotifier extends StateNotifier<String> {
  final FlutterSecureStorage _storage;

  PrimaryCurrencyNotifier(this._storage) : super('USD') {
    _load();
  }

  Future<void> _load() async {
    final saved = await _storage.read(key: _kPrimaryCurrencyKey);
    if (saved != null && saved.isNotEmpty) {
      state = saved;
    }
  }

  Future<void> setPrimaryCurrency(String currency) async {
    state = currency.toUpperCase();
    await _storage.write(key: _kPrimaryCurrencyKey, value: state);
  }
}

/// Provider for Primary Display Currency
final primaryCurrencyProvider =
    StateNotifierProvider<PrimaryCurrencyNotifier, String>((ref) {
      final storage = ref.watch(_secureStorageProvider);
      return PrimaryCurrencyNotifier(storage);
    });

/// Notifier for Monthly Subscription Budget Limit
class MonthlyBudgetNotifier extends StateNotifier<double?> {
  final FlutterSecureStorage _storage;

  MonthlyBudgetNotifier(this._storage) : super(null) {
    _load();
  }

  Future<void> _load() async {
    final saved = await _storage.read(key: _kMonthlyBudgetKey);
    if (saved != null && saved.isNotEmpty) {
      state = double.tryParse(saved);
    }
  }

  Future<void> setBudgetLimit(double? limit) async {
    state = limit;
    if (limit == null || limit <= 0) {
      await _storage.delete(key: _kMonthlyBudgetKey);
    } else {
      await _storage.write(key: _kMonthlyBudgetKey, value: limit.toString());
    }
  }
}

/// Provider for Monthly Budget Limit
final monthlyBudgetLimitProvider =
    StateNotifierProvider<MonthlyBudgetNotifier, double?>((ref) {
      final storage = ref.watch(_secureStorageProvider);
      return MonthlyBudgetNotifier(storage);
    });

/// Provider that calculates the live BudgetEvaluation across all active subscriptions
final budgetEvaluationProvider = Provider<BudgetEvaluation>((ref) {
  final subscriptionState = ref.watch(subscriptionNotifierProvider);
  final budgetLimit = ref.watch(monthlyBudgetLimitProvider);
  final primaryCurrency = ref.watch(primaryCurrencyProvider);
  final converter = ref.watch(currencyConverterProvider);

  return BudgetCalculator.evaluate(
    subscriptions: subscriptionState.subscriptions,
    budgetLimit: budgetLimit,
    primaryCurrency: primaryCurrency,
    converter: converter,
  );
});
