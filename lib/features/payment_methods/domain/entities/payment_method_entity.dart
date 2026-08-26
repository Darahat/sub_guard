import '../../../../core/utils/date_helper.dart';
import '../enums/payment_method_type.dart';

enum PaymentExpiryStatus {
  none('Valid'),
  normal('Safe'),
  upcoming('Expiring This Month'),
  actionSoon('Action Required Soon'),
  expiresToday('Expires Today'),
  expired('Expired');

  final String label;
  const PaymentExpiryStatus(this.label);

  bool get isActionable =>
      this == PaymentExpiryStatus.upcoming ||
      this == PaymentExpiryStatus.actionSoon ||
      this == PaymentExpiryStatus.expiresToday ||
      this == PaymentExpiryStatus.expired;
}

class PaymentMethodEntity {
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

  const PaymentMethodEntity({
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

  /// The exact calendar date and final second of the expiration month
  DateTime? get expirationDate {
    if (expiryMonth == null || expiryYear == null) return null;
    return DateTime(expiryYear!, expiryMonth! + 1, 0, 23, 59, 59);
  }

  /// Days remaining until the end of the expiration month
  int? daysUntilExpiry(DateTime now) {
    final exp = expirationDate;
    if (exp == null) return null;
    final today = DateHelper.dateOnly(now);
    final expiryDateOnly = DateHelper.dateOnly(exp);
    return expiryDateOnly.difference(today).inDays;
  }

  /// Evaluates whether this payment method is safe, expiring, or expired
  PaymentExpiryStatus evaluateStatus(DateTime now) {
    if (!type.supportsExpiry) return PaymentExpiryStatus.none;
    final exp = expirationDate;
    if (exp == null) return PaymentExpiryStatus.none;

    final daysRemaining = daysUntilExpiry(now)!;

    if (daysRemaining > 30) {
      return PaymentExpiryStatus.normal;
    } else if (daysRemaining >= 15 && daysRemaining <= 30) {
      return PaymentExpiryStatus.upcoming;
    } else if (daysRemaining >= 1 && daysRemaining <= 14) {
      return PaymentExpiryStatus.actionSoon;
    } else if (daysRemaining == 0) {
      return PaymentExpiryStatus.expiresToday;
    } else {
      return PaymentExpiryStatus.expired;
    }
  }

  /// Display string with last 4 digits if available
  String get displayLabel {
    if (last4 != null && last4!.isNotEmpty) {
      return '$name (···· $last4)';
    }
    return name;
  }

  /// Formatted expiry MM/YY string
  String? get formattedExpiry {
    if (expiryMonth == null || expiryYear == null) return null;
    final monthStr = expiryMonth.toString().padLeft(2, '0');
    final yearStr = (expiryYear! % 100).toString().padLeft(2, '0');
    return '$monthStr/$yearStr';
  }

  PaymentMethodEntity copyWith({
    String? id,
    String? name,
    PaymentMethodType? type,
    String? last4,
    int? expiryMonth,
    int? expiryYear,
    String? colorHex,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PaymentMethodEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      last4: last4 ?? this.last4,
      expiryMonth: expiryMonth ?? this.expiryMonth,
      expiryYear: expiryYear ?? this.expiryYear,
      colorHex: colorHex ?? this.colorHex,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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

  factory PaymentMethodEntity.fromJson(Map<String, dynamic> json) {
    return PaymentMethodEntity(
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentMethodEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
