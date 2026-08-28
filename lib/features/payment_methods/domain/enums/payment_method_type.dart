import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';

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

  HeroIcons get heroIcon {
    switch (this) {
      case PaymentMethodType.creditCard:
      case PaymentMethodType.debitCard:
        return HeroIcons.creditCard;
      case PaymentMethodType.paypal:
        return HeroIcons.wallet;
      case PaymentMethodType.bankAccount:
        return HeroIcons.buildingLibrary;
      case PaymentMethodType.applePay:
        return HeroIcons.devicePhoneMobile;
      case PaymentMethodType.googlePay:
        return HeroIcons.globeAlt;
      case PaymentMethodType.other:
        return HeroIcons.banknotes;
    }
  }

  bool get supportsExpiry =>
      this == PaymentMethodType.creditCard ||
      this == PaymentMethodType.debitCard;
}
