import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/subscription_entity.dart';
import '../repositories/subscription_repository.dart';

class UpdateSubscriptionUseCase {
  final SubscriptionRepository repository;

  UpdateSubscriptionUseCase(this.repository);

  Future<Either<Failure, SubscriptionEntity>> call(
    SubscriptionEntity subscription,
  ) async {
    return await repository.updateSubscription(subscription);
  }
}
