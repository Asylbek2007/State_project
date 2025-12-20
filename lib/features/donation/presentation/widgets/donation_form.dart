import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../goals/domain/entities/goal.dart';
import '../../../payment/presentation/widgets/payment_method_selector.dart';
import '../../../payment/domain/entities/payment_method.dart';

/// Form widget for making a donation.
class DonationForm extends StatefulWidget {
  final String userName;
  final String userGroup;
  final List<Goal> goals;
  final void Function(double amount, String message, String? goalName) onSubmit;
  final bool isLoading;
  final String? preselectedGoalName;

  const DonationForm({
    super.key,
    required this.userName,
    required this.userGroup,
    required this.goals,
    required this.onSubmit,
    required this.isLoading,
    this.preselectedGoalName,
  });

  @override
  State<DonationForm> createState() => _DonationFormState();
}

class _DonationFormState extends State<DonationForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _messageController = TextEditingController();

  // Quick amount buttons
  final List<int> _quickAmounts = [1000, 2000, 5000, 10000];
  int? _selectedQuickAmount;
  String? _selectedGoalName; // Выбранная цель сбора
  PaymentMethod? _selectedPaymentMethod; // Выбранный метод оплаты

  @override
  void initState() {
    super.initState();
    // Устанавливаем предустановленную цель, если она передана
    if (widget.preselectedGoalName != null) {
      _selectedGoalName = widget.preselectedGoalName;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _selectQuickAmount(int amount) {
    setState(() {
      _selectedQuickAmount = amount;
      _amountController.text = amount.toString();
    });
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      final amount = double.parse(_amountController.text);
      final message = _messageController.text.trim();
      widget.onSubmit(amount, message, _selectedGoalName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // User info display
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Вы помогаете как:',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.userName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Группа: ${widget.userGroup}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Goal selection
          if (widget.goals.isNotEmpty) ...[
            Text(
              'Цель сбора:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonFormField<String>(
                value: _selectedGoalName,
                decoration: InputDecoration(
                  hintText: 'Выберите цель сбора',
                  prefixIcon: const Icon(Icons.flag),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                items: [
                  // Опция "Общий фонд" (без конкретной цели)
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('Общий фонд (без конкретной цели)'),
                  ),
                  // Список целей
                  ...widget.goals.map((goal) {
                    return DropdownMenuItem<String>(
                      value: goal.name,
                      child: Text(
                        goal.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }),
                ],
                onChanged: widget.isLoading
                    ? null
                    : (value) {
                        setState(() {
                          _selectedGoalName = value;
                        });
                      },
                validator: (value) {
                  // Цель не обязательна, но можно сделать обязательной
                  return null;
                },
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Quick amount buttons
          Text(
            'Быстрый выбор суммы:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _quickAmounts.map((amount) {
              final isSelected = _selectedQuickAmount == amount;
              return FilterChip(
                label: Text('$amount ₸'),
                selected: isSelected,
                onSelected: widget.isLoading
                    ? null
                    : (_) => _selectQuickAmount(amount),
                selectedColor: Colors.blue.shade100,
                checkmarkColor: Colors.blue.shade700,
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Amount input
          TextFormField(
            controller: _amountController,
            enabled: !widget.isLoading,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: InputDecoration(
              labelText: 'КЗ *',
              hintText: 'Введите сумму',
              prefixIcon: const Padding(
                padding: EdgeInsets.all(12.0),
                child: Text(
                  '₸',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              suffixText: '₸',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _selectedQuickAmount = null;
              });
            },
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Пожалуйста, введите сумму';
              }
              final amount = double.tryParse(value);
              if (amount == null || amount <= 0) {
                return 'Сумма должна быть больше нуля';
              }
              if (amount > 1000000) {
                return 'Сумма не может превышать 1,000,000 ₸';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          // Payment Method Selector (only show if amount is entered)
          if (_amountController.text.isNotEmpty &&
              double.tryParse(_amountController.text) != null &&
              double.parse(_amountController.text) > 0)
            PaymentMethodSelector(
              amount: double.parse(_amountController.text),
              selectedMethod: _selectedPaymentMethod,
              goalName: _selectedGoalName,
              userName: widget.userName,
              userGroup: widget.userGroup,
              onMethodSelected: (method) {
                setState(() {
                  _selectedPaymentMethod = method;
                });
              },
            ),

          const SizedBox(height: 20),

          // Message input
          TextFormField(
            controller: _messageController,
            enabled: !widget.isLoading,
            maxLines: 3,
            maxLength: 200,
            decoration: InputDecoration(
              labelText: 'Сообщение (необязательно)',
              hintText: 'Оставьте пожелание или комментарий',
              prefixIcon: const Icon(Icons.message),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 32),

          // Submit button
          ElevatedButton(
            onPressed: widget.isLoading ? null : _handleSubmit,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: widget.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Помочь',
                    style: TextStyle(fontSize: 16),
                  ),
          ),
        ],
      ),
    );
  }
}

