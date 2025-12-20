import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/config/payment_config.dart';
import '../../../../core/theme/app_theme.dart';
import 'payment_confirmation_page.dart';

/// Page displaying bank details for manual transfer.
class BankDetailsPage extends StatelessWidget {
  final double amount;
  final String? goalName;
  final String userName;
  final String userGroup;

  const BankDetailsPage({
    super.key,
    required this.amount,
    this.goalName,
    required this.userName,
    required this.userGroup,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Реквизиты для перевода'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacing24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Amount Card
            Container(
              padding: const EdgeInsets.all(AppTheme.spacing24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primarySkyBlue,
                    AppTheme.primarySkyBlue.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.account_balance_wallet,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: AppTheme.spacing16),
                  Text(
                    'Сумма к переводу',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing8),
                  Text(
                    '${amount.toStringAsFixed(0)} ₸',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.spacing24),

            // Bank Details Card
            Container(
              padding: const EdgeInsets.all(AppTheme.spacing20),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                border: Border.all(
                  color: AppTheme.primarySkyBlue.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppTheme.primarySkyBlue),
                      const SizedBox(width: AppTheme.spacing8),
                      Text(
                        'Реквизиты получателя',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.titleLarge?.color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacing20),
                  _buildDetailField(
                    context,
                    'Получатель',
                    PaymentConfig.recipientName,
                    Icons.person,
                  ),
                  if (PaymentConfig.accountNumber != null)
                    _buildDetailField(
                      context,
                      'IBAN',
                      PaymentConfig.accountNumber!,
                      Icons.credit_card,
                      isCopyable: true,
                    ),
                  if (PaymentConfig.bankName != null)
                    _buildDetailField(
                      context,
                      'Банк',
                      PaymentConfig.bankName!,
                      Icons.account_balance,
                    ),
                  // Phone numbers
                  _buildDetailField(
                    context,
                    'Kaspi номер',
                    PaymentConfig.kaspiNumber,
                    Icons.phone_android,
                    isCopyable: true,
                  ),
                  _buildDetailField(
                    context,
                    'Halyk номер',
                    PaymentConfig.halykNumber,
                    Icons.phone_android,
                    isCopyable: true,
                  ),
                  if (PaymentConfig.bin != null && PaymentConfig.bin!.isNotEmpty)
                    _buildDetailField(
                      context,
                      'БИН',
                      PaymentConfig.bin!,
                      Icons.badge,
                    ),
                  _buildDetailField(
                    context,
                    'Назначение платежа',
                    'Пожертвование на развитие колледжа',
                    Icons.description,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.spacing24),

            // Instructions
            Container(
              padding: const EdgeInsets.all(AppTheme.spacing16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.help_outline, color: Colors.blue.shade700),
                      const SizedBox(width: AppTheme.spacing8),
                      Text(
                        'Инструкция:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacing12),
                  Text(
                    '1. Скопируйте реквизиты выше\n'
                    '2. Откройте приложение вашего банка\n'
                    '3. Создайте перевод на указанные реквизиты\n'
                    '4. Укажите сумму: ${amount.toStringAsFixed(0)} ₸\n'
                    '5. После перевода вернитесь и подтвердите оплату',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.blue.shade900,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.spacing24),

            // Confirm Payment Button
            ElevatedButton(
              onPressed: () {
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
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
              ),
              child: const Text(
                'Я перевел(а) деньги',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailField(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    bool isCopyable = false,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppTheme.primarySkyBlue),
              const SizedBox(width: AppTheme.spacing8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.textTheme.bodySmall?.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing4),
          Container(
            padding: const EdgeInsets.all(AppTheme.spacing12),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
                if (isCopyable)
                  IconButton(
                    icon: const Icon(Icons.copy, size: 18),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: value));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('$label скопирован в буфер обмена'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    tooltip: 'Скопировать',
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

