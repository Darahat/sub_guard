import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/payment_method_entity.dart';

abstract class PaymentMethodRepository {
  Future<Either<Failure, List<PaymentMethodEntity>>> getPaymentMethods();
  Future<Either<Failure, PaymentMethodEntity>> addPaymentMethod(
    PaymentMethodEntity paymentMethod,
  );
  Future<Either<Failure, PaymentMethodEntity>> updatePaymentMethod(
    PaymentMethodEntity paymentMethod,
  );
  Future<Either<Failure, void>> deletePaymentMethod(String id);
}
