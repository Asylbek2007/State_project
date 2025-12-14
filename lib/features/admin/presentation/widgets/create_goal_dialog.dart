import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/errors/failures.dart';
import '../providers/admin_providers.dart';

/// Dialog for creating a new goal.
class CreateGoalDialog extends ConsumerStatefulWidget {
  const CreateGoalDialog({super.key});

  @override
  ConsumerState<CreateGoalDialog> createState() => _CreateGoalDialogState();
}

class _CreateGoalDialogState extends ConsumerState<CreateGoalDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _targetController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedDeadline = DateTime.now().add(const Duration(days: 30));
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleCreate() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    try {
      final createGoalUseCase = ref.read(createGoalUseCaseProvider);
      final targetAmount = double.parse(_targetController.text);

      await createGoalUseCase(
        name: _nameController.text.trim(),
        targetAmount: targetAmount,
        deadline: _selectedDeadline,
        description: _descriptionController.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pop(true);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ Цель успешно создана'),
              backgroundColor: AppTheme.successGreen,
              duration: Duration(seconds: 2),
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
            duration: const Duration(seconds: 5),
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
      title: const Text('Создать новую цель'),
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
                  labelText: 'Название цели *',
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
                  prefixIcon: Icon(Icons.attach_money),
                  suffixText: '₸',
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Введите сумму';
                  final amount = double.tryParse(v);
                  if (amount == null || amount <= 0) {
                    return 'Сумма должна быть > 0';
                  }
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
          onPressed: _isLoading ? null : _handleCreate,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Создать'),
        ),
      ],
    );
  }
}

