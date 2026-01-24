import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/insight_entity.dart';

/// Repository for insights and analytics data
abstract class InsightRepository {
  /// Get spending trends over time
  Future<Either<Failure, List<SpendingDataPoint>>> getSpendingTrends({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Get category breakdown of spending
  Future<Either<Failure, List<CategorySpending>>> getCategoryBreakdown({
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get overall subscription statistics
  Future<Either<Failure, SubscriptionStats>> getSubscriptionStats();

  /// Get top subscriptions by spending
  Future<Either<Failure, List<TopSubscription>>> getTopSubscriptions({
    int limit = 5,
  });

  /// Get monthly spending for a specific year
  Future<Either<Failure, List<SpendingDataPoint>>> getMonthlySpending({
    required int year,
  });

  /// Get yearly spending comparison
  Future<Either<Failure, Map<int, double>>> getYearlyComparison();

  /// Calculate potential savings (e.g., unused subscriptions)
  Future<Either<Failure, double>> calculatePotentialSavings();
}
