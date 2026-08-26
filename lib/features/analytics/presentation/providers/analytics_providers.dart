import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/currency/currency_converter.dart';
import '../../../budget/presentation/providers/budget_providers.dart';
import '../../../subscriptions/presentation/providers/subscription_notifier.dart';
import '../../domain/models/opportunity_cost_result.dart';
import '../../domain/models/savings_opportunity.dart';
import '../../domain/models/spending_projection.dart';
import '../../domain/services/opportunity_cost_calculator.dart';
import '../../domain/services/projection_calculator.dart';
import '../../domain/services/savings_calculator.dart';

/// State provider for estimated annual subscription price growth assumption
final annualPriceGrowthProvider = StateProvider<double>((ref) => 0.0);

/// Provider computing multi-horizon spending projections from current normalized monthly spend
final spendingProjectionProvider = Provider<SpendingProjection>((ref) {
  final budget = ref.watch(budgetEvaluationProvider);
  final growth = ref.watch(annualPriceGrowthProvider);

  return ProjectionCalculator.calculate(
    monthlySpend: budget.totalMonthlySpent,
    annualPriceGrowth: growth,
  );
});

/// Provider detecting subscriptions to review and potential savings
final savingsOpportunityProvider = Provider<SavingsOpportunity>((ref) {
  final subscriptions = ref.watch(subscriptionNotifierProvider).subscriptions;
  final primaryCurrency = ref.watch(primaryCurrencyProvider);
  final converter = ref.watch(currencyConverterProvider);

  return SavingsCalculator.evaluateSavings(
    subscriptions: subscriptions,
    primaryCurrency: primaryCurrency,
    converter: converter,
  );
});

/// Parameters for interactive opportunity-cost simulation
class SimulationParams {
  final double monthlyAmount;
  final double annualReturn;
  final int years;

  const SimulationParams({
    required this.monthlyAmount,
    required this.annualReturn,
    required this.years,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SimulationParams &&
          runtimeType == other.runtimeType &&
          monthlyAmount == other.monthlyAmount &&
          annualReturn == other.annualReturn &&
          years == other.years;

  @override
  int get hashCode => Object.hash(monthlyAmount, annualReturn, years);
}

/// Provider computing opportunity-cost result for specified simulation parameters
final opportunityCostResultProvider =
    Provider.family<OpportunityCostResult, SimulationParams>((ref, params) {
      return OpportunityCostCalculator.calculate(
        monthlyContribution: params.monthlyAmount,
        annualReturnRate: params.annualReturn,
        years: params.years,
      );
    });
