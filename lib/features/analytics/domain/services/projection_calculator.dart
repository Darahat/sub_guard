import 'dart:math' as math;

import '../models/spending_projection.dart';

/// Pure mathematical calculation engine for multi-horizon subscription spending projections
class ProjectionCalculator {
  /// Calculates long-term cumulative cost for given monthly spend and optional annual price growth
  static SpendingProjection calculate({
    required double monthlySpend,
    double annualPriceGrowth = 0.0,
  }) {
    if (monthlySpend <= 0) {
      return const SpendingProjection(
        monthlySpend: 0,
        oneYearCost: 0,
        threeYearCost: 0,
        fiveYearCost: 0,
        tenYearCost: 0,
        oneYearBaseline: 0,
        threeYearBaseline: 0,
        fiveYearBaseline: 0,
        tenYearBaseline: 0,
        annualPriceGrowth: 0,
      );
    }

    final oneYearBaseline = monthlySpend * 12.0;
    final threeYearBaseline = monthlySpend * 36.0;
    final fiveYearBaseline = monthlySpend * 60.0;
    final tenYearBaseline = monthlySpend * 120.0;

    final oneYearCost = _calculateHorizon(monthlySpend, 1, annualPriceGrowth);
    final threeYearCost = _calculateHorizon(monthlySpend, 3, annualPriceGrowth);
    final fiveYearCost = _calculateHorizon(monthlySpend, 5, annualPriceGrowth);
    final tenYearCost = _calculateHorizon(monthlySpend, 10, annualPriceGrowth);

    return SpendingProjection(
      monthlySpend: monthlySpend,
      oneYearCost: oneYearCost,
      threeYearCost: threeYearCost,
      fiveYearCost: fiveYearCost,
      tenYearCost: tenYearCost,
      oneYearBaseline: oneYearBaseline,
      threeYearBaseline: threeYearBaseline,
      fiveYearBaseline: fiveYearBaseline,
      tenYearBaseline: tenYearBaseline,
      annualPriceGrowth: annualPriceGrowth,
    );
  }

  /// Helper to calculate cumulative cost over [years] accounting for compounding annual price growth
  static double _calculateHorizon(
    double monthlySpend,
    int years,
    double annualGrowth,
  ) {
    if (annualGrowth <= 0.0) {
      return monthlySpend * 12.0 * years;
    }

    double total = 0.0;
    for (int y = 1; y <= years; y++) {
      final yearMonthlyRate =
          monthlySpend * math.pow(1.0 + annualGrowth, y - 1);
      total += yearMonthlyRate * 12.0;
    }
    return total;
  }
}
