import 'package:flutter/material.dart';

enum PaymentMethodType {
  creditCard('Credit Card', Icons.credit_card_outlined),
  debitCard('Debit Card', Icons.credit_card),
  paypal('PayPal', Icons.account_balance_wallet_outlined),
  bankAccount('Bank Account', Icons.account_balance_outlined),
  applePay('Apple Pay', Icons.phone_iphone_outlined),
  googlePay('Google Pay', Icons.android_outlined),
  other('Other', Icons.payments_outlined);

  final String label;
  final IconData icon;

  const PaymentMethodType(this.label, this.icon);

  bool get supportsExpiry =>
      this == PaymentMethodType.creditCard ||
      this == PaymentMethodType.debitCard;
}
