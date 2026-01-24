import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/subscription_entity.dart';
import '../repositories/subscription_repository.dart';

class GetSubscriptionByIdUseCase {
  final SubscriptionRepository repository;

  GetSubscriptionByIdUseCase(this.repository);

  Future<Either<Failure, SubscriptionEntity>> call(String id) async {
    return await repository.getSubscriptionById(id);
  }
}
