/// Represents long-term spending projections across multiple horizons
class SpendingProjection {
  final double monthlySpend;
  final double oneYearCost;
  final double threeYearCost;
  final double fiveYearCost;
  final double tenYearCost;

  /// Baseline costs at 0% annual price growth
  final double oneYearBaseline;
  final double threeYearBaseline;
  final double fiveYearBaseline;
  final double tenYearBaseline;

  /// Estimated annual price growth assumption (e.g., 0.05 for 5%)
  final double annualPriceGrowth;

  const SpendingProjection({
    required this.monthlySpend,
    required this.oneYearCost,
    required this.threeYearCost,
    required this.fiveYearCost,
    required this.tenYearCost,
    required this.oneYearBaseline,
    required this.threeYearBaseline,
    required this.fiveYearBaseline,
    required this.tenYearBaseline,
    this.annualPriceGrowth = 0.0,
  });

  /// Additional cost over 5 years caused solely by annual price increases
  double get fiveYearPriceGrowthDelta => fiveYearCost - fiveYearBaseline;

  /// Additional cost over 10 years caused solely by annual price increases
  double get tenYearPriceGrowthDelta => tenYearCost - tenYearBaseline;
}
