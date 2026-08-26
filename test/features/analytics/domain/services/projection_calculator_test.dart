import 'package:flutter_test/flutter_test.dart';
import 'package:sub_guard/features/analytics/domain/services/projection_calculator.dart';

void main() {
  group('ProjectionCalculator Tests', () {
    test('Calculates accurate baseline costs with 0% price growth', () {
      final projection = ProjectionCalculator.calculate(
        monthlySpend: 100.0,
        annualPriceGrowth: 0.0,
      );

      expect(projection.monthlySpend, equals(100.0));
      expect(projection.oneYearCost, equals(1200.0));
      expect(projection.threeYearCost, equals(3600.0));
      expect(projection.fiveYearCost, equals(6000.0));
      expect(projection.tenYearCost, equals(12000.0));
      expect(projection.fiveYearPriceGrowthDelta, equals(0.0));
    });

    test('Calculates compounding price growth accurately', () {
      // Monthly: $100, Growth: 5% per year
      // Year 1: $100 * 12 = $1200
      // Year 2: $100 * 1.05 * 12 = $1260
      // Year 3: $100 * 1.05^2 * 12 = $1323
      final projection = ProjectionCalculator.calculate(
        monthlySpend: 100.0,
        annualPriceGrowth: 0.05,
      );

      expect(projection.oneYearCost, closeTo(1200.0, 0.01));
      expect(projection.threeYearCost, closeTo(1200.0 + 1260.0 + 1323.0, 0.01));
      expect(projection.fiveYearBaseline, equals(6000.0));
      expect(projection.fiveYearCost, greaterThan(6000.0));
      expect(projection.fiveYearPriceGrowthDelta, greaterThan(0.0));
    });

    test('Handles 0 monthly spend gracefully', () {
      final projection = ProjectionCalculator.calculate(
        monthlySpend: 0.0,
        annualPriceGrowth: 0.05,
      );

      expect(projection.oneYearCost, equals(0.0));
      expect(projection.fiveYearCost, equals(0.0));
      expect(projection.tenYearCost, equals(0.0));
    });
  });
}
