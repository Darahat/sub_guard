import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/subscription_entity.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../datasources/local_subscription_datasource.dart';
import '../datasources/remote_subscription_datasource.dart';
import '../models/subscription_model.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final LocalSubscriptionDataSource localDataSource;
  final RemoteSubscriptionDataSource? remoteDataSource;
  final Uuid uuid;

  SubscriptionRepositoryImpl({
    required this.localDataSource,
    this.remoteDataSource,
    required this.uuid,
  });

  @override
  Future<Either<Failure, List<SubscriptionEntity>>>
  getAllSubscriptions() async {
    try {
      final subscriptions = await localDataSource.getAllSubscriptions();
      return Right(subscriptions.map((s) => s.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SubscriptionEntity>> getSubscriptionById(
    String id,
  ) async {
    try {
      final subscription = await localDataSource.getSubscriptionById(id);
      if (subscription == null) {
        return Left(NotFoundFailure('Subscription not found'));
      }
      return Right(subscription.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SubscriptionEntity>>> getSubscriptionsByStatus(
    SubscriptionStatus status,
  ) async {
    try {
      final subscriptions = await localDataSource.getSubscriptionsByStatus(
        status,
      );
      return Right(subscriptions.map((s) => s.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SubscriptionEntity>>> getSubscriptionsByCategory(
    String category,
  ) async {
    try {
      final subscriptions = await localDataSource.getSubscriptionsByCategory(
        category,
      );
      return Right(subscriptions.map((s) => s.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SubscriptionEntity>> addSubscription(
    SubscriptionEntity subscription,
  ) async {
    try {
      // Generate ID if not provided
      final subscriptionWithId = subscription.id.isEmpty
          ? subscription.copyWith(
              id: uuid.v4(),
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            )
          : subscription.copyWith(
              createdAt: subscription.createdAt ?? DateTime.now(),
              updatedAt: DateTime.now(),
            );

      final model = SubscriptionModel.fromEntity(subscriptionWithId);
      final added = await localDataSource.addSubscription(model);

      // Non-blocking remote sync if logged in
      if (remoteDataSource != null &&
          subscriptionWithId.userId.isNotEmpty &&
          subscriptionWithId.userId != 'local_user') {
        remoteDataSource!
            .createSubscription(subscriptionWithId.userId, added)
            .catchError((_) => '');
      }

      return Right(added.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SubscriptionEntity>> updateSubscription(
    SubscriptionEntity subscription,
  ) async {
    try {
      final updatedSubscription = subscription.copyWith(
        updatedAt: DateTime.now(),
      );
      final model = SubscriptionModel.fromEntity(updatedSubscription);
      final updated = await localDataSource.updateSubscription(model);

      // Non-blocking remote sync if logged in
      if (remoteDataSource != null &&
          subscription.userId.isNotEmpty &&
          subscription.userId != 'local_user') {
        remoteDataSource!
            .updateSubscription(
              subscription.userId,
              subscription.id,
              updated,
            )
            .catchError((_) {});
      }

      return Right(updated.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteSubscription(String id) async {
    try {
      final existing = await localDataSource.getSubscriptionById(id);
      await localDataSource.deleteSubscription(id);

      // Non-blocking remote delete if logged in
      if (existing != null &&
          remoteDataSource != null &&
          existing.userId.isNotEmpty &&
          existing.userId != 'local_user') {
        remoteDataSource!
            .deleteSubscription(existing.userId, id)
            .catchError((_) {});
      }

      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SubscriptionEntity>> cancelSubscription(
    String id,
  ) async {
    try {
      final subscription = await localDataSource.getSubscriptionById(id);
      if (subscription == null) {
        return Left(NotFoundFailure('Subscription not found'));
      }

      final entity = subscription.toEntity();
      final cancelled = entity.copyWith(
        status: SubscriptionStatus.cancelled,
        cancellationDate: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final model = SubscriptionModel.fromEntity(cancelled);
      final updated = await localDataSource.updateSubscription(model);

      if (remoteDataSource != null &&
          cancelled.userId.isNotEmpty &&
          cancelled.userId != 'local_user') {
        remoteDataSource!
            .updateSubscription(cancelled.userId, id, updated)
            .catchError((_) {});
      }

      return Right(updated.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SubscriptionEntity>> pauseSubscription(
    String id,
  ) async {
    try {
      final subscription = await localDataSource.getSubscriptionById(id);
      if (subscription == null) {
        return Left(NotFoundFailure('Subscription not found'));
      }

      final entity = subscription.toEntity();
      final paused = entity.copyWith(
        status: SubscriptionStatus.paused,
        updatedAt: DateTime.now(),
      );

      final model = SubscriptionModel.fromEntity(paused);
      final updated = await localDataSource.updateSubscription(model);

      if (remoteDataSource != null &&
          paused.userId.isNotEmpty &&
          paused.userId != 'local_user') {
        remoteDataSource!
            .updateSubscription(paused.userId, id, updated)
            .catchError((_) {});
      }

      return Right(updated.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SubscriptionEntity>> reactivateSubscription(
    String id,
  ) async {
    try {
      final subscription = await localDataSource.getSubscriptionById(id);
      if (subscription == null) {
        return Left(NotFoundFailure('Subscription not found'));
      }

      final entity = subscription.toEntity();
      final reactivated = entity.copyWith(
        status: SubscriptionStatus.active,
        cancellationDate: null,
        updatedAt: DateTime.now(),
      );

      final model = SubscriptionModel.fromEntity(reactivated);
      final updated = await localDataSource.updateSubscription(model);

      if (remoteDataSource != null &&
          reactivated.userId.isNotEmpty &&
          reactivated.userId != 'local_user') {
        remoteDataSource!
            .updateSubscription(reactivated.userId, id, updated)
            .catchError((_) {});
      }

      return Right(updated.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, double>> getTotalMonthlySpending() async {
    try {
      final subscriptions = await localDataSource.getSubscriptionsByStatus(
        SubscriptionStatus.active,
      );

      final total = subscriptions.fold<double>(
        0.0,
        (sum, sub) => sum + sub.toEntity().monthlyCost,
      );

      return Right(total);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, double>> getTotalYearlySpending() async {
    try {
      final subscriptions = await localDataSource.getSubscriptionsByStatus(
        SubscriptionStatus.active,
      );

      final total = subscriptions.fold<double>(
        0.0,
        (sum, sub) => sum + sub.toEntity().yearlyCost,
      );

      return Right(total);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SubscriptionEntity>>>
  getExpiringSoonSubscriptions(int days) async {
    try {
      final subscriptions = await localDataSource.getExpiringSoonSubscriptions(
        days,
      );
      return Right(subscriptions.map((s) => s.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SubscriptionEntity>>> searchSubscriptions(
    String query,
  ) async {
    try {
      final subscriptions = await localDataSource.searchSubscriptions(query);
      return Right(subscriptions.map((s) => s.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
