import 'dart:convert';

import 'package:hive_ce/hive.dart';

import '../../../../core/error/exceptions.dart';
import '../models/payment_method_model.dart';

abstract class PaymentMethodLocalDataSource {
  Future<List<PaymentMethodModel>> getPaymentMethods();
  Future<PaymentMethodModel> addPaymentMethod(PaymentMethodModel method);
  Future<PaymentMethodModel> updatePaymentMethod(PaymentMethodModel method);
  Future<void> deletePaymentMethod(String id);
}

class PaymentMethodLocalDataSourceImpl implements PaymentMethodLocalDataSource {
  final Box<String> _paymentMethodsBox;

  PaymentMethodLocalDataSourceImpl({required Box<String> paymentMethodsBox})
    : _paymentMethodsBox = paymentMethodsBox;

  @override
  Future<List<PaymentMethodModel>> getPaymentMethods() async {
    try {
      final List<PaymentMethodModel> methods = [];
      for (var i = 0; i < _paymentMethodsBox.length; i++) {
        final jsonString = _paymentMethodsBox.getAt(i);
        if (jsonString != null) {
          final Map<String, dynamic> jsonMap = json.decode(jsonString);
          methods.add(PaymentMethodModel.fromJson(jsonMap));
        }
      }
      return methods;
    } catch (e) {
      throw CacheException(
        'Failed to get payment methods from local storage: $e',
      );
    }
  }

  @override
  Future<PaymentMethodModel> addPaymentMethod(PaymentMethodModel method) async {
    try {
      final jsonString = json.encode(method.toJson());
      await _paymentMethodsBox.put(method.id, jsonString);
      return method;
    } catch (e) {
      throw CacheException(
        'Failed to save payment method to local storage: $e',
      );
    }
  }

  @override
  Future<PaymentMethodModel> updatePaymentMethod(
    PaymentMethodModel method,
  ) async {
    try {
      final jsonString = json.encode(method.toJson());
      await _paymentMethodsBox.put(method.id, jsonString);
      return method;
    } catch (e) {
      throw CacheException(
        'Failed to update payment method in local storage: $e',
      );
    }
  }

  @override
  Future<void> deletePaymentMethod(String id) async {
    try {
      await _paymentMethodsBox.delete(id);
    } catch (e) {
      throw CacheException(
        'Failed to delete payment method from local storage: $e',
      );
    }
  }
}
