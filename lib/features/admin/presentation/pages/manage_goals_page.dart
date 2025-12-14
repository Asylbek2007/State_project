import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/errors/failures.dart';
import '../../../goals/presentation/providers/goals_provider.dart';
import '../../../goals/domain/entities/goal.dart';
import '../widgets/create_goal_dialog.dart';
import '../widgets/edit_goal_dialog.dart';
import '../providers/admin_providers.dart';

/// Manage Goals page - CRUD operations for fundraising goals.
class ManageGoalsPage extends ConsumerStatefulWidget {
  const ManageGoalsPage({super.key});

  @override
  ConsumerState<ManageGoalsPage> createState() => _ManageGoalsPageState();
}

class _ManageGoalsPageState extends ConsumerState<ManageGoalsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(goalsProvider.notifier).loadGoals());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(goalsProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundMilkWhite,
      appBar: AppBar(
        title: const Text('Управление целями'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(goalsProvider.notifier).refresh(),
          ),
        ],
      ),
      body: state.isLoading && state.goals.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => ref.read(goalsProvider.notifier).refresh(),
              child: ListView(
                padding: const EdgeInsets.all(AppTheme.spacing16),
                children: [
                  // Info banner
                  _buildInfoBanner(context, state.goals.length),
                  const SizedBox(height: AppTheme.spacing16),

                  // Goals list
                  if (state.goals.isEmpty)
                    _buildEmptyState(context)
                  else
                    ...state.goals.map((goal) => _buildGoalManagementCard(
                          context,
                          goal,
                        )),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateGoalDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Создать цель'),
      ),
    );
  }

  Widget _buildInfoBanner(BuildContext context, int totalGoals) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        color: AppTheme.primarySkyBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: AppTheme.primarySkyBlue.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline,
            color: AppTheme.primarySkyBlue,
          ),
          const SizedBox(width: AppTheme.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Управление целями сбора',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryDark,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing4),
                Text(
                  'Всего целей: $totalGoals. Все изменения сохраняются в Google Sheets.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.primaryDark.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing40),
        child: Column(
          children: [
            Icon(
              Icons.flag_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: AppTheme.spacing16),
            const Text(
              'Нет активных целей',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: AppTheme.spacing8),
            Text(
              'Создайте первую цель сбора',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalManagementCard(BuildContext context, Goal goal) {
    final currencyFormat = NumberFormat.currency(symbol: '₸', decimalDigits: 0);
    final dateFormat = DateFormat('dd.MM.yyyy');

    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacing12),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.all(AppTheme.spacing16),
        childrenPadding: const EdgeInsets.all(AppTheme.spacing16),
        leading: Container(
          padding: const EdgeInsets.all(AppTheme.spacing8),
          decoration: BoxDecoration(
            color: AppTheme.primarySkyBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          ),
          child: Icon(
            goal.isCompleted ? Icons.check_circle : Icons.flag,
            color: goal.isCompleted ? AppTheme.successGreen : AppTheme.primarySkyBlue,
          ),
        ),
        title: Text(
          goal.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '${(goal.progress * 100).toStringAsFixed(0)}% выполнено • До ${dateFormat.format(goal.deadline)}',
          style: const TextStyle(fontSize: 12),
        ),
        children: [
          // Goal details
          _buildDetailRow('Цель', currencyFormat.format(goal.targetAmount)),
          _buildDetailRow('Собрано', currencyFormat.format(goal.currentAmount)),
          _buildDetailRow('Осталось', currencyFormat.format(goal.remainingAmount)),
          _buildDetailRow('Дедлайн', dateFormat.format(goal.deadline)),
          _buildDetailRow('Описание', goal.description),
          const SizedBox(height: AppTheme.spacing16),

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => _showEditGoalDialog(context, goal),
                icon: const Icon(Icons.edit),
                label: const Text('Редактировать'),
              ),
              const SizedBox(width: AppTheme.spacing8),
              TextButton.icon(
                onPressed: () => _confirmDeleteGoal(context, goal),
                icon: const Icon(Icons.delete),
                label: const Text('Удалить'),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.errorRed,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacing8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showCreateGoalDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const CreateGoalDialog(),
    );

    if (result == true && mounted) {
      ref.read(goalsProvider.notifier).refresh();
    }
  }

  Future<void> _showEditGoalDialog(BuildContext context, Goal goal) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => EditGoalDialog(goal: goal),
    );

    if (result == true && mounted) {
      ref.read(goalsProvider.notifier).refresh();
    }
  }

  Future<void> _confirmDeleteGoal(BuildContext context, Goal goal) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить цель?'),
        content: Text('Вы уверены, что хотите удалить цель "${goal.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorRed),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final deleteGoalUseCase = ref.read(deleteGoalUseCaseProvider);
        await deleteGoalUseCase(goal.name);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ Цель "${goal.name}" удалена'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
        ref.read(goalsProvider.notifier).refresh();
      } on ValidationFailure catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      } on SheetsFailure catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка удаления: ${e.toString()}'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }
}

