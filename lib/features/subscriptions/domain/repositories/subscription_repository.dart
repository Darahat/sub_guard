import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/subscription_entity.dart';

/// Subscription repository interface
abstract class SubscriptionRepository {
  /// Get all subscriptions for the current user
  Future<Either<Failure, List<SubscriptionEntity>>> getAllSubscriptions();

  /// Get subscription by ID
  Future<Either<Failure, SubscriptionEntity>> getSubscriptionById(String id);

  /// Get subscriptions by status
  Future<Either<Failure, List<SubscriptionEntity>>> getSubscriptionsByStatus(
    SubscriptionStatus status,
  );

  /// Get subscriptions by category
  Future<Either<Failure, List<SubscriptionEntity>>> getSubscriptionsByCategory(
    String category,
  );

  /// Add new subscription
  Future<Either<Failure, SubscriptionEntity>> addSubscription(
    SubscriptionEntity subscription,
  );

  /// Update subscription
  Future<Either<Failure, SubscriptionEntity>> updateSubscription(
    SubscriptionEntity subscription,
  );

  /// Delete subscription
  Future<Either<Failure, Unit>> deleteSubscription(String id);

  /// Mark subscription as cancelled
  Future<Either<Failure, SubscriptionEntity>> cancelSubscription(String id);

  /// Mark subscription as paused
  Future<Either<Failure, SubscriptionEntity>> pauseSubscription(String id);

  /// Reactivate subscription
  Future<Either<Failure, SubscriptionEntity>> reactivateSubscription(String id);

  /// Get total monthly spending
  Future<Either<Failure, double>> getTotalMonthlySpending();

  /// Get total yearly spending
  Future<Either<Failure, double>> getTotalYearlySpending();

  /// Get subscriptions expiring soon (within days)
  Future<Either<Failure, List<SubscriptionEntity>>>
  getExpiringSoonSubscriptions(int days);

  /// Search subscriptions by name
  Future<Either<Failure, List<SubscriptionEntity>>> searchSubscriptions(
    String query,
  );
}
