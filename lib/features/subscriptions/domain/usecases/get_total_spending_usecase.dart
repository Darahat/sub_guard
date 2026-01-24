import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/subscription_repository.dart';

class GetTotalMonthlySpendingUseCase {
  final SubscriptionRepository repository;

  GetTotalMonthlySpendingUseCase(this.repository);

  Future<Either<Failure, double>> call() async {
    return await repository.getTotalMonthlySpending();
  }
}

class GetTotalYearlySpendingUseCase {
  final SubscriptionRepository repository;

  GetTotalYearlySpendingUseCase(this.repository);

  Future<Either<Failure, double>> call() async {
    return await repository.getTotalYearlySpending();
  }
}
