import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/config/payment_config.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/payment_qr_widget.dart';
import 'payment_confirmation_page.dart';

/// Page displaying QR code for payment.
class QRPaymentPage extends StatelessWidget {
  final double amount;
  final String? goalName;
  final String userName;
  final String userGroup;

  const QRPaymentPage({
    super.key,
    required this.amount,
    this.goalName,
    required this.userName,
    required this.userGroup,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Используем простой формат с номером телефона для Kaspi
    // Камера Kaspi распознает номер и предложит перевод
    final qrData = PaymentConfig.hasBankDetails
        ? PaymentConfig.generateBankQRData(amount) ??
            PaymentConfig.generateKaspiQR(amount)
        : PaymentConfig.generateKaspiQR(amount);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Оплата через QR-код'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacing24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // QR Code Widget
            PaymentQRWidget(
              amount: amount,
              qrData: qrData,
            ),

            const SizedBox(height: AppTheme.spacing24),

            // Instructions
            Container(
              padding: const EdgeInsets.all(AppTheme.spacing16),
              decoration: BoxDecoration(
                color: AppTheme.primarySkyBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: AppTheme.primarySkyBlue,
                        size: 20,
                      ),
                      const SizedBox(width: AppTheme.spacing8),
                      Text(
                        'Как оплатить:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.titleMedium?.color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacing16),
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacing12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle,
                            color: Colors.green.shade700, size: 20),
                        const SizedBox(width: AppTheme.spacing8),
                        Expanded(
                          child: Text(
                            'QR-код содержит номер телефона для перевода',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.green.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing16),
                  _buildStep('1', 'Откройте приложение Kaspi.kz'),
                  _buildStep('2',
                      'Нажмите на кнопку "Сканировать QR" в разделе "Переводы"'),
                  _buildStep('3', 'Наведите камеру на QR-код выше'),
                  _buildStep('4',
                      'Камера распознает номер телефона: ${PaymentConfig.kaspiNumber}'),
                  _buildStep(
                      '5', 'Введите сумму: ${amount.toStringAsFixed(0)} ₸'),
                  _buildStep('6', 'Проверьте данные и подтвердите перевод'),
                  _buildStep(
                      '7', 'После перевода вернитесь и подтвердите оплату'),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.spacing24),

            // Bank Details (only if available)
            if (PaymentConfig.hasBankDetails)
              _buildBankDetails(context)
            else
              _buildPhoneDetails(context),

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
                padding:
                    const EdgeInsets.symmetric(vertical: AppTheme.spacing16),
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

  Widget _buildStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacing12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: AppTheme.primarySkyBlue,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppTheme.spacing12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankDetails(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance,
                  size: 20, color: AppTheme.primarySkyBlue),
              const SizedBox(width: AppTheme.spacing8),
              Text(
                'Реквизиты получателя:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.titleMedium?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing12),
          _buildDetailRow('Получатель:', PaymentConfig.recipientName, context),
          if (PaymentConfig.accountNumber != null)
            _buildDetailRow(
                'Счет (IBAN):', PaymentConfig.accountNumber!, context),
          if (PaymentConfig.bankName != null)
            _buildDetailRow('Банк:', PaymentConfig.bankName!, context),
          _buildDetailRow('Kaspi номер:', PaymentConfig.kaspiNumber, context),
          _buildDetailRow('Halyk номер:', PaymentConfig.halykNumber, context),
          if (PaymentConfig.accountNumber != null) ...[
            const SizedBox(height: AppTheme.spacing8),
            ElevatedButton.icon(
              onPressed: () {
                Clipboard.setData(
                    ClipboardData(text: PaymentConfig.accountNumber!));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('IBAN скопирован в буфер обмена'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              icon: const Icon(Icons.copy, size: 16),
              label: const Text('Скопировать IBAN'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primarySkyBlue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacing8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: theme.textTheme.bodySmall?.color,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: theme.textTheme.bodyMedium?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneDetails(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.phone_android,
                  size: 20, color: AppTheme.primarySkyBlue),
              const SizedBox(width: AppTheme.spacing8),
              Text(
                'Номера для перевода:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.titleMedium?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing16),
          _buildPhoneRow('Kaspi', PaymentConfig.kaspiNumber, context),
          const SizedBox(height: AppTheme.spacing12),
          _buildPhoneRow('Halyk', PaymentConfig.halykNumber, context),
          const SizedBox(height: AppTheme.spacing12),
          Container(
            padding: const EdgeInsets.all(AppTheme.spacing12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.blue.shade700),
                const SizedBox(width: AppTheme.spacing8),
                Expanded(
                  child: Text(
                    'Откройте приложение Kaspi или Halyk, найдите "Перевод по номеру" и переведите на указанный номер',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneRow(
      String bankName, String phoneNumber, BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing12),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bankName,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  phoneNumber,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy, size: 18),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: phoneNumber));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Номер $bankName скопирован'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            tooltip: 'Скопировать',
          ),
        ],
      ),
    );
  }
}
