import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../donation/presentation/providers/donation_provider.dart';

/// Page for confirming payment after transfer.
class PaymentConfirmationPage extends ConsumerStatefulWidget {
  final double amount;
  final String? goalName;
  final String userName;
  final String userGroup;

  const PaymentConfirmationPage({
    super.key,
    required this.amount,
    this.goalName,
    required this.userName,
    required this.userGroup,
  });

  @override
  ConsumerState<PaymentConfirmationPage> createState() =>
      _PaymentConfirmationPageState();
}

class _PaymentConfirmationPageState extends ConsumerState<PaymentConfirmationPage> {
  final _transactionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _transactionController.dispose();
    super.dispose();
  }

  void _submitConfirmation() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Save donation with transaction ID
      await ref.read(donationProvider.notifier).makeDonation(
        fullName: widget.userName,
        studyGroup: widget.userGroup,
        amount: widget.amount,
        message: 'Пожертвование через QR-код',
        goalName: widget.goalName,
        transactionId: _transactionController.text.trim(),
      );

      // Listen for success
      ref.listen<DonationState>(donationProvider, (previous, next) {
        if (next.donation != null && previous?.donation == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✓ Пожертвование зарегистрировано! Администратор проверит оплату.'),
                backgroundColor: AppTheme.successGreen,
                duration: Duration(seconds: 3),
              ),
            );

            // Navigate back to main page
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        } else if (next.error != null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Ошибка: ${next.error}'),
                backgroundColor: AppTheme.errorRed,
              ),
            );
            setState(() {
              _isSubmitting = false;
            });
          }
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Подтверждение оплаты'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacing24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Success Icon
              Container(
                padding: const EdgeInsets.all(AppTheme.spacing24),
                decoration: BoxDecoration(
                  color: AppTheme.successGreen.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  color: AppTheme.successGreen,
                  size: 64,
                ),
              ),

              const SizedBox(height: AppTheme.spacing24),

              // Title
              Text(
                'Подтвердите оплату',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppTheme.spacing8),

              Text(
                'После перевода введите номер транзакции из истории операций',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodySmall?.color,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppTheme.spacing32),

              // Amount Card
              Container(
                padding: const EdgeInsets.all(AppTheme.spacing16),
                decoration: BoxDecoration(
                  color: AppTheme.primarySkyBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Сумма перевода:',
                      style: TextStyle(
                        fontSize: 16,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    Text(
                      '${widget.amount.toStringAsFixed(0)} ₸',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primarySkyBlue,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppTheme.spacing24),

              // Transaction ID Input
              TextFormField(
                controller: _transactionController,
                enabled: !_isSubmitting,
                decoration: InputDecoration(
                  labelText: 'Номер транзакции *',
                  hintText: 'Например: 1234567890',
                  helperText: 'Найдите в истории переводов вашего банка',
                  prefixIcon: const Icon(Icons.receipt_long),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Введите номер транзакции';
                  }
                  if (value.trim().length < 5) {
                    return 'Номер транзакции слишком короткий';
                  }
                  return null;
                },
              ),

              const SizedBox(height: AppTheme.spacing24),

              // Info Box
              Container(
                padding: const EdgeInsets.all(AppTheme.spacing16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange.shade700),
                    const SizedBox(width: AppTheme.spacing12),
                    Expanded(
                      child: Text(
                        'Важно: Пожертвование будет зарегистрировано после проверки администратором. Обычно это занимает 1-2 рабочих дня.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange.shade900,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppTheme.spacing32),

              // Submit Button
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitConfirmation,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Подтвердить оплату',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

