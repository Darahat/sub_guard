import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/subscription_entity.dart';
import '../repositories/subscription_repository.dart';

class AddSubscriptionUseCase {
  final SubscriptionRepository repository;

  AddSubscriptionUseCase(this.repository);

  Future<Either<Failure, SubscriptionEntity>> call(
    SubscriptionEntity subscription,
  ) async {
    return await repository.addSubscription(subscription);
  }
}
