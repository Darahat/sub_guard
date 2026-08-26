import '../../domain/entities/payment_method_entity.dart';
import '../../domain/enums/payment_method_type.dart';

class PaymentMethodModel {
  final String id;
  final String name;
  final PaymentMethodType type;
  final String? last4;
  final int? expiryMonth;
  final int? expiryYear;
  final String? colorHex;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  PaymentMethodModel({
    required this.id,
    required this.name,
    this.type = PaymentMethodType.creditCard,
    this.last4,
    this.expiryMonth,
    this.expiryYear,
    this.colorHex,
    this.isDefault = false,
    required this.createdAt,
    required this.updatedAt,
  });

  PaymentMethodEntity toEntity() {
    return PaymentMethodEntity(
      id: id,
      name: name,
      type: type,
      last4: last4,
      expiryMonth: expiryMonth,
      expiryYear: expiryYear,
      colorHex: colorHex,
      isDefault: isDefault,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory PaymentMethodModel.fromEntity(PaymentMethodEntity entity) {
    return PaymentMethodModel(
      id: entity.id,
      name: entity.name,
      type: entity.type,
      last4: entity.last4,
      expiryMonth: entity.expiryMonth,
      expiryYear: entity.expiryYear,
      colorHex: entity.colorHex,
      isDefault: entity.isDefault,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'last4': last4,
      'expiryMonth': expiryMonth,
      'expiryYear': expiryYear,
      'colorHex': colorHex,
      'isDefault': isDefault,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: PaymentMethodType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PaymentMethodType.creditCard,
      ),
      last4: json['last4'] as String?,
      expiryMonth: json['expiryMonth'] as int?,
      expiryYear: json['expiryYear'] as int?,
      colorHex: json['colorHex'] as String?,
      isDefault: json['isDefault'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }
}
