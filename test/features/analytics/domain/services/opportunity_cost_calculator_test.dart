import 'package:flutter_test/flutter_test.dart';
import 'package:sub_guard/features/analytics/domain/services/opportunity_cost_calculator.dart';

void main() {
  group('OpportunityCostCalculator Tests', () {
    test('Handles 0% annual return rate safely without division by zero', () {
      final result = OpportunityCostCalculator.calculate(
        monthlyContribution: 50.0,
        annualReturnRate: 0.0,
        years: 5,
      );

      expect(result.totalContributions, equals(3000.0)); // 50 * 12 * 5
      expect(result.compoundGrowth, equals(0.0));
      expect(result.futureValue, equals(3000.0));
      expect(result.growthPercentage, equals(0.0));
    });

    test('Calculates 8% moderate compound return over 5 years correctly', () {
      final result = OpportunityCostCalculator.calculate(
        monthlyContribution: 35.0,
        annualReturnRate: 0.08,
        years: 5,
      );

      expect(result.totalContributions, equals(2100.0)); // 35 * 60
      expect(result.futureValue, closeTo(2571.6, 1.0)); // ~2,571
      expect(result.compoundGrowth, closeTo(471.6, 1.0)); // ~471
      expect(result.growthPercentage, greaterThan(20.0));
    });

    test('Calculates 5% and 10% scenarios properly', () {
      final res5 = OpportunityCostCalculator.calculate(
        monthlyContribution: 35.0,
        annualReturnRate: 0.05,
        years: 5,
      );
      final res10 = OpportunityCostCalculator.calculate(
        monthlyContribution: 35.0,
        annualReturnRate: 0.10,
        years: 5,
      );

      expect(res5.futureValue, closeTo(2380.21, 1.0));
      expect(res10.futureValue, closeTo(2710.30, 1.0));
    });

    test('Handles edge cases of 0 contribution or 0 years', () {
      final zeroContrib = OpportunityCostCalculator.calculate(
        monthlyContribution: 0.0,
        annualReturnRate: 0.08,
        years: 5,
      );
      final zeroYears = OpportunityCostCalculator.calculate(
        monthlyContribution: 50.0,
        annualReturnRate: 0.08,
        years: 0,
      );

      expect(zeroContrib.futureValue, equals(0.0));
      expect(zeroYears.futureValue, equals(0.0));
    });
  });
}
