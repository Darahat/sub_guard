import 'dart:math' as math;

import '../models/opportunity_cost_result.dart';

/// Pure mathematical calculation engine for educational compound savings opportunity-cost
class OpportunityCostCalculator {
  /// Calculates future compound value for monthly contributions over a given time horizon
  static OpportunityCostResult calculate({
    required double monthlyContribution,
    required double annualReturnRate,
    required int years,
  }) {
    if (monthlyContribution <= 0 || years <= 0) {
      return const OpportunityCostResult(
        monthlyContribution: 0,
        annualReturnRate: 0,
        years: 0,
        totalContributions: 0,
        compoundGrowth: 0,
        futureValue: 0,
      );
    }

    final totalContributions = monthlyContribution * 12.0 * years;

    // Explicit divide-by-zero protection for 0% return scenario
    if (annualReturnRate <= 0.0) {
      return OpportunityCostResult(
        monthlyContribution: monthlyContribution,
        annualReturnRate: 0.0,
        years: years,
        totalContributions: totalContributions,
        compoundGrowth: 0.0,
        futureValue: totalContributions,
      );
    }

    final monthlyRate = annualReturnRate / 12.0;
    final totalMonths = years * 12;
    final futureValue =
        monthlyContribution *
        ((math.pow(1.0 + monthlyRate, totalMonths) - 1.0) / monthlyRate);
    final compoundGrowth = math.max(0.0, futureValue - totalContributions);

    return OpportunityCostResult(
      monthlyContribution: monthlyContribution,
      annualReturnRate: annualReturnRate,
      years: years,
      totalContributions: totalContributions,
      compoundGrowth: compoundGrowth,
      futureValue: futureValue,
    );
  }
}
