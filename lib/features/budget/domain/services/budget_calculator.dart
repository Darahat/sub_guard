import '../../../../core/currency/currency_converter.dart';
import '../../../subscriptions/domain/entities/subscription_entity.dart';
import '../entities/budget_health.dart';

/// Financial calculator for subscription budgets and multi-currency normalization
class BudgetCalculator {
  /// Evaluates total monthly subscription spending normalized to [primaryCurrency]
  static BudgetEvaluation evaluate({
    required List<SubscriptionEntity> subscriptions,
    required double? budgetLimit,
    required String primaryCurrency,
    required CurrencyConverter converter,
  }) {
    double totalMonthly = 0.0;

    for (final sub in subscriptions) {
      if (sub.status == SubscriptionStatus.active) {
        // 1. Get personal share if family/split plan, else full amount
        final personalAmount = sub.effectivePersonalAmount;

        // 2. Convert to primary currency
        final convertedAmount = converter.convert(
          amount: personalAmount,
          fromCurrency: sub.currency,
          toCurrency: primaryCurrency,
        );

        // 3. Normalize to monthly cost
        final monthlyCost = _normalizeToMonthly(
          convertedAmount,
          sub.billingCycle,
        );
        totalMonthly += monthlyCost;
      }
    }

    final hasBudget = budgetLimit != null && budgetLimit > 0;
    final percentage = hasBudget ? (totalMonthly / budgetLimit) : 0.0;
    final remaining = hasBudget ? (budgetLimit - totalMonthly) : 0.0;
    final health = BudgetEvaluation.evaluateHealth(
      spent: totalMonthly,
      limit: budgetLimit,
    );

    return BudgetEvaluation(
      totalMonthlySpent: totalMonthly,
      budgetLimit: budgetLimit,
      primaryCurrency: primaryCurrency,
      percentageUsed: percentage,
      health: health,
      remainingBudget: remaining,
      hasBudget: hasBudget,
    );
  }

  /// Calculates the live impact of adding or updating a subscription on the monthly budget
  static ({
    double newTotal,
    double difference,
    double remainingAfter,
    BudgetHealth newHealth,
    bool isOverBudget,
  })
  evaluateImpact({
    required double currentTotalMonthly,
    required double newAmount,
    required BillingCycle newCycle,
    required String newCurrency,
    required double? budgetLimit,
    required String primaryCurrency,
    required CurrencyConverter converter,
  }) {
    final converted = converter.convert(
      amount: newAmount,
      fromCurrency: newCurrency,
      toCurrency: primaryCurrency,
    );

    final monthlyAddition = _normalizeToMonthly(converted, newCycle);
    final newTotal = currentTotalMonthly + monthlyAddition;
    final remaining = (budgetLimit ?? 0) - newTotal;
    final health = BudgetEvaluation.evaluateHealth(
      spent: newTotal,
      limit: budgetLimit,
    );

    return (
      newTotal: newTotal,
      difference: monthlyAddition,
      remainingAfter: remaining,
      newHealth: health,
      isOverBudget: health == BudgetHealth.overBudget,
    );
  }

  static double _normalizeToMonthly(double amount, BillingCycle cycle) {
    switch (cycle) {
      case BillingCycle.monthly:
        return amount;
      case BillingCycle.quarterly:
        return amount / 3;
      case BillingCycle.yearly:
        return amount / 12;
      case BillingCycle.weekly:
        return amount * 4.33;
      case BillingCycle.daily:
        return amount * 30;
    }
  }
}
