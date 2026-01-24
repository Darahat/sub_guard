import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/subscription_entity.dart';
import '../repositories/subscription_repository.dart';

class GetAllSubscriptionsUseCase {
  final SubscriptionRepository repository;

  GetAllSubscriptionsUseCase(this.repository);

  Future<Either<Failure, List<SubscriptionEntity>>> call() async {
    return await repository.getAllSubscriptions();
  }
}
