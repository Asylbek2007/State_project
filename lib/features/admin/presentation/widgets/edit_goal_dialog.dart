import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/errors/failures.dart';
import '../../../goals/domain/entities/goal.dart';
import '../providers/admin_providers.dart';

/// Dialog for editing an existing goal.
class EditGoalDialog extends ConsumerStatefulWidget {
  final Goal goal;

  const EditGoalDialog({
    super.key,
    required this.goal,
  });

  @override
  ConsumerState<EditGoalDialog> createState() => _EditGoalDialogState();
}

class _EditGoalDialogState extends ConsumerState<EditGoalDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _targetController;
  late final TextEditingController _currentController;
  late final TextEditingController _descriptionController;
  late DateTime _selectedDeadline;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.goal.name);
    _targetController = TextEditingController(
      text: widget.goal.targetAmount.toStringAsFixed(0),
    );
    _currentController = TextEditingController(
      text: widget.goal.currentAmount.toStringAsFixed(0),
    );
    _descriptionController = TextEditingController(text: widget.goal.description);
    _selectedDeadline = widget.goal.deadline;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    _currentController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    try {
      final updateGoalUseCase = ref.read(updateGoalUseCaseProvider);
      final targetAmount = double.parse(_targetController.text);
      final currentAmount = double.parse(_currentController.text);

      await updateGoalUseCase(
        originalName: widget.goal.name,
        name: _nameController.text.trim(),
        targetAmount: targetAmount,
        currentAmount: currentAmount,
        deadline: _selectedDeadline,
        description: _descriptionController.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pop(true);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ Цель обновлена'),
              backgroundColor: AppTheme.successGreen,
            ),
          );
        }
      }
    } on ValidationFailure catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: AppTheme.errorRed,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } on SheetsFailure catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: AppTheme.errorRed,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: ${e.toString()}'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  Future<String> _formatDate(DateTime date) async {
    try {
      return DateFormat('dd MMMM yyyy', 'ru').format(date);
    } catch (e) {
      // Fallback to default format if locale not initialized
      return DateFormat('dd.MM.yyyy').format(date);
    }
  }

  Future<void> _selectDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() => _selectedDeadline = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Редактировать цель'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                enabled: !_isLoading,
                decoration: const InputDecoration(
                  labelText: 'Название *',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Введите название' : null,
              ),
              const SizedBox(height: AppTheme.spacing16),
              
              TextFormField(
                controller: _targetController,
                enabled: !_isLoading,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Целевая сумма *',
                  prefixIcon: Icon(Icons.flag),
                  suffixText: '₸',
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Введите сумму';
                  final amount = double.tryParse(v);
                  if (amount == null || amount <= 0) return 'Сумма > 0';
                  return null;
                },
              ),
              const SizedBox(height: AppTheme.spacing16),

              TextFormField(
                controller: _currentController,
                enabled: !_isLoading,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Текущая сумма *',
                  prefixIcon: Icon(Icons.account_balance_wallet),
                  suffixText: '₸',
                  helperText: 'Обновите вручную или оставьте автоподсчет',
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Введите сумму';
                  final amount = double.tryParse(v);
                  if (amount == null || amount < 0) return 'Сумма >= 0';
                  return null;
                },
              ),
              const SizedBox(height: AppTheme.spacing16),

              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today, color: AppTheme.primarySkyBlue),
                title: const Text('Дедлайн', style: TextStyle(fontSize: 14)),
                subtitle: FutureBuilder<String>(
                  future: _formatDate(_selectedDeadline),
                  builder: (context, snapshot) {
                    return Text(
                      snapshot.data ?? DateFormat('dd.MM.yyyy').format(_selectedDeadline),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    );
                  },
                ),
                trailing: TextButton(
                  onPressed: _isLoading ? null : _selectDeadline,
                  child: const Text('Изменить'),
                ),
              ),
              const SizedBox(height: AppTheme.spacing16),

              TextFormField(
                controller: _descriptionController,
                enabled: !_isLoading,
                maxLines: 3,
                maxLength: 200,
                decoration: const InputDecoration(
                  labelText: 'Описание *',
                  prefixIcon: Icon(Icons.description),
                  alignLabelWithHint: true,
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Введите описание' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context, false),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleSave,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Сохранить'),
        ),
      ],
    );
  }
}

