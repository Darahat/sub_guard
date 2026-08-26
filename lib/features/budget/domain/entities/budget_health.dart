enum BudgetHealth {
  onTrack('On Track'),
  nearLimit('Near Limit'),
  overBudget('Over Budget');

  final String label;
  const BudgetHealth(this.label);
}

/// Evaluation result of the user's monthly subscription budget
class BudgetEvaluation {
  final double totalMonthlySpent;
  final double? budgetLimit;
  final String primaryCurrency;
  final double percentageUsed;
  final BudgetHealth health;
  final double remainingBudget;
  final bool hasBudget;

  const BudgetEvaluation({
    required this.totalMonthlySpent,
    this.budgetLimit,
    this.primaryCurrency = 'USD',
    required this.percentageUsed,
    required this.health,
    required this.remainingBudget,
    required this.hasBudget,
  });

  bool get isOverBudget => health == BudgetHealth.overBudget;

  static BudgetHealth evaluateHealth({
    required double spent,
    required double? limit,
  }) {
    if (limit == null || limit <= 0) return BudgetHealth.onTrack;
    final ratio = spent / limit;
    if (ratio >= 1.0) return BudgetHealth.overBudget;
    if (ratio >= 0.8) return BudgetHealth.nearLimit;
    return BudgetHealth.onTrack;
  }
}
