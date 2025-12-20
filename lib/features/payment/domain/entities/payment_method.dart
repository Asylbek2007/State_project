import 'package:flutter/material.dart';

/// Payment method enum.
enum PaymentMethod {
  qrCode('QR-код для перевода', 'Сканируйте QR-код в приложении банка', Icons.qr_code),
  bankDetails('Реквизиты для перевода', 'Скопируйте реквизиты и переведите вручную', Icons.account_balance),
  kaspiTransfer('Перевод на Kaspi', 'Перевод по номеру телефона', Icons.phone_android),
  halykTransfer('Перевод на Halyk', 'Перевод по номеру телефона', Icons.phone_android);

  final String title;
  final String subtitle;
  final IconData icon;

  const PaymentMethod(this.title, this.subtitle, this.icon);
}

/// Payment status enum.
enum PaymentStatus {
  pending('Ожидает оплаты'),
  processing('Обрабатывается'),
  confirmed('Подтверждено'),
  failed('Ошибка');

  final String label;

  const PaymentStatus(this.label);
}

