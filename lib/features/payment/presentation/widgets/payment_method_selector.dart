import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/config/payment_config.dart';
import '../../domain/entities/payment_method.dart';
import '../widgets/payment_method_card.dart';
import '../pages/qr_payment_page.dart';
import '../pages/bank_details_page.dart';
import '../pages/payment_confirmation_page.dart';

/// Widget for selecting payment method.
class PaymentMethodSelector extends StatelessWidget {
  final double amount;
  final PaymentMethod? selectedMethod;
  final Function(PaymentMethod) onMethodSelected;
  final String? goalName;
  final String userName;
  final String userGroup;

  const PaymentMethodSelector({
    super.key,
    required this.amount,
    this.selectedMethod,
    required this.onMethodSelected,
    this.goalName,
    required this.userName,
    required this.userGroup,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Способ оплаты:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.titleMedium?.color,
          ),
        ),
        const SizedBox(height: AppTheme.spacing12),

        // QR Code Method
        PaymentMethodCard(
          method: PaymentMethod.qrCode,
          isSelected: selectedMethod == PaymentMethod.qrCode,
          onTap: () {
            onMethodSelected(PaymentMethod.qrCode);
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => QRPaymentPage(
                  amount: amount,
                  goalName: goalName,
                  userName: userName,
                  userGroup: userGroup,
                ),
              ),
            );
          },
        ),

        // Bank Details Method
        PaymentMethodCard(
          method: PaymentMethod.bankDetails,
          isSelected: selectedMethod == PaymentMethod.bankDetails,
          onTap: () {
            onMethodSelected(PaymentMethod.bankDetails);
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => BankDetailsPage(
                  amount: amount,
                  goalName: goalName,
                  userName: userName,
                  userGroup: userGroup,
                ),
              ),
            );
          },
        ),

        // Kaspi Transfer Method
        PaymentMethodCard(
          method: PaymentMethod.kaspiTransfer,
          isSelected: selectedMethod == PaymentMethod.kaspiTransfer,
          onTap: () {
            onMethodSelected(PaymentMethod.kaspiTransfer);
            _showKaspiDialog(context);
          },
        ),
      ],
    );
  }

  void _showKaspiDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Перевод на Kaspi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Номер для перевода:'),
            const SizedBox(height: 8),
            // ignore: prefer_const_constructors
            SelectableText(
              PaymentConfig.kaspiNumber,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primarySkyBlue,
              ),
            ),
            const SizedBox(height: 16),
            Text('Сумма: ${amount.toStringAsFixed(0)} ₸'),
            const SizedBox(height: 16),
            Text(
              '1. Откройте приложение Kaspi.kz\n'
              '2. Перейдите в "Переводы"\n'
              '3. Введите номер: ${PaymentConfig.kaspiNumber}\n'
              '4. Укажите сумму: ${amount.toStringAsFixed(0)} ₸\n'
              '5. Подтвердите перевод',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PaymentConfirmationPage(
                    amount: amount,
                    goalName: goalName,
                    userName: userName,
                    userGroup: userGroup,
                  ),
                ),
              );
            },
            child: const Text('Я перевел(а)'),
          ),
        ],
      ),
    );
  }
}

