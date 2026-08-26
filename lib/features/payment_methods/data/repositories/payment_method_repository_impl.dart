import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/payment_method_entity.dart';
import '../../domain/repositories/payment_method_repository.dart';
import '../datasources/payment_method_local_datasource.dart';
import '../models/payment_method_model.dart';

class PaymentMethodRepositoryImpl implements PaymentMethodRepository {
  final PaymentMethodLocalDataSource _localDataSource;

  PaymentMethodRepositoryImpl(this._localDataSource);

  @override
  Future<Either<Failure, List<PaymentMethodEntity>>> getPaymentMethods() async {
    try {
      final models = await _localDataSource.getPaymentMethods();
      final entities = models.map((m) => m.toEntity()).toList();
      return Right(entities);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error loading payment methods: $e'));
    }
  }

  @override
  Future<Either<Failure, PaymentMethodEntity>> addPaymentMethod(
    PaymentMethodEntity paymentMethod,
  ) async {
    try {
      final model = PaymentMethodModel.fromEntity(paymentMethod);
      final saved = await _localDataSource.addPaymentMethod(model);
      return Right(saved.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to save payment method: $e'));
    }
  }

  @override
  Future<Either<Failure, PaymentMethodEntity>> updatePaymentMethod(
    PaymentMethodEntity paymentMethod,
  ) async {
    try {
      final model = PaymentMethodModel.fromEntity(paymentMethod);
      final updated = await _localDataSource.updatePaymentMethod(model);
      return Right(updated.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to update payment method: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deletePaymentMethod(String id) async {
    try {
      await _localDataSource.deletePaymentMethod(id);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to delete payment method: $e'));
    }
  }
}
