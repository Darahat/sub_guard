import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/subscription_repository.dart';

class DeleteSubscriptionUseCase {
  final SubscriptionRepository repository;

  DeleteSubscriptionUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String id) async {
    return await repository.deleteSubscription(id);
  }
}
