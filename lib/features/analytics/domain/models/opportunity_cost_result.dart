/// Result of an educational opportunity-cost / compound savings simulation
class OpportunityCostResult {
  final double monthlyContribution;
  final double annualReturnRate;
  final int years;
  final double totalContributions;
  final double compoundGrowth;
  final double futureValue;

  const OpportunityCostResult({
    required this.monthlyContribution,
    required this.annualReturnRate,
    required this.years,
    required this.totalContributions,
    required this.compoundGrowth,
    required this.futureValue,
  });

  /// Percentage gain over baseline contributions
  double get growthPercentage => totalContributions > 0
      ? (compoundGrowth / totalContributions) * 100.0
      : 0.0;
}
