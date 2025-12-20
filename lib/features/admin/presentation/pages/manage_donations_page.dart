import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/errors/failures.dart';
import '../../../journal/presentation/providers/journal_provider.dart';
import '../../../goals/presentation/providers/goals_provider.dart';
import '../../../donation/domain/entities/donation.dart';
import '../providers/admin_providers.dart';

/// Manage Donations page - view and manage all donations.
class ManageDonationsPage extends ConsumerStatefulWidget {
  const ManageDonationsPage({super.key});

  @override
  ConsumerState<ManageDonationsPage> createState() => _ManageDonationsPageState();
}

class _ManageDonationsPageState extends ConsumerState<ManageDonationsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(journalProvider.notifier).loadDonations());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(journalProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundMilkWhite,
      appBar: AppBar(
        title: const Text('Управление пожертвованиями'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(journalProvider.notifier).refresh(),
          ),
        ],
      ),
      body: state.isLoading && state.donations.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => ref.read(journalProvider.notifier).refresh(),
              child: ListView(
                padding: const EdgeInsets.all(AppTheme.spacing16),
                children: [
                  // Stats summary
                  _buildStatsSummary(context, state),
                  const SizedBox(height: AppTheme.spacing24),

                  // Section header
                  const Text(
                    'Все пожертвования',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing16),

                  // Donations list
                  if (state.donations.isEmpty)
                    _buildEmptyState(context)
                  else
                    ...state.donations.map((donation) =>
                        _buildDonationManagementCard(context, donation)),
                ],
              ),
            ),
    );
  }

  Widget _buildStatsSummary(BuildContext context, state) {
    final currencyFormat = NumberFormat.currency(symbol: '₸', decimalDigits: 0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(
                  label: 'Всего',
                  value: state.totalCount.toString(),
                  icon: Icons.format_list_numbered,
                  color: AppTheme.primarySkyBlue,
                ),
                _StatItem(
                  label: 'Сумма',
                  value: currencyFormat.format(state.totalAmount),
                  icon: Icons.account_balance_wallet,
                  color: AppTheme.successGreen,
                ),
                _StatItem(
                  label: 'Средний',
                  value: currencyFormat.format(state.averageAmount),
                  icon: Icons.show_chart,
                  color: AppTheme.warningOrange,
                ),
              ],
            ),
          ],
        ),
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
              Icons.inbox_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: AppTheme.spacing16),
            const Text(
              'Нет пожертвований',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDonationManagementCard(BuildContext context, Donation donation) {
    final currencyFormat = NumberFormat.currency(symbol: '₸', decimalDigits: 0);
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');

    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacing12),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.all(AppTheme.spacing16),
        childrenPadding: const EdgeInsets.all(AppTheme.spacing16),
        leading: Container(
          padding: const EdgeInsets.all(AppTheme.spacing8),
          decoration: BoxDecoration(
            color: AppTheme.successGreen.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.volunteer_activism,
            color: AppTheme.successGreen,
            size: 20,
          ),
        ),
        title: Text(
          donation.fullName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${currencyFormat.format(donation.amount)} • ${dateFormat.format(donation.date)}',
              style: const TextStyle(fontSize: 12),
            ),
            if (donation.transactionId != null && donation.transactionId!.isNotEmpty)
              _buildStatusChip(donation.paymentStatus),
          ],
        ),
        children: [
          _buildDetailRow('Группа', donation.studyGroup),
          _buildDetailRow('Сумма', currencyFormat.format(donation.amount)),
          _buildDetailRow('Дата', dateFormat.format(donation.date)),
          if (donation.message.isNotEmpty)
            _buildDetailRow('Сообщение', donation.message),
          if (donation.transactionId != null && donation.transactionId!.isNotEmpty) ...[
            _buildDetailRow('Номер транзакции', donation.transactionId!),
            _buildDetailRow('Статус оплаты', _getStatusLabel(donation.paymentStatus)),
          ],
          const SizedBox(height: AppTheme.spacing16),

          // Payment Status Actions (if transaction exists)
          if (donation.transactionId != null && 
              donation.transactionId!.isNotEmpty &&
              donation.paymentStatus != PaymentStatus.confirmed)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _confirmPaymentStatus(
                      context, 
                      donation, 
                      PaymentStatus.confirmed,
                    ),
                    icon: const Icon(Icons.check_circle, size: 18),
                    label: const Text('Подтвердить'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.successGreen,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spacing8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmPaymentStatus(
                      context, 
                      donation, 
                      PaymentStatus.rejected,
                    ),
                    icon: const Icon(Icons.cancel, size: 18),
                    label: const Text('Отклонить'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.errorRed,
                      side: const BorderSide(color: AppTheme.errorRed),
                    ),
                  ),
                ),
              ],
            ),

          const SizedBox(height: AppTheme.spacing8),

          // Delete Action
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => _confirmDeleteDonation(context, donation),
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

  Future<void> _confirmDeleteDonation(BuildContext context, Donation donation) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить пожертвование?'),
        content: Text(
          'Вы уверены, что хотите удалить пожертвование от ${donation.fullName}?',
        ),
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
      if (!mounted) return;
      // ignore: use_build_context_synchronously
      final messenger = ScaffoldMessenger.of(context);
      try {
        final deleteDonationUseCase = ref.read(deleteDonationUseCaseProvider);
        await deleteDonationUseCase(
          fullName: donation.fullName,
          date: donation.date,
        );

        if (!mounted) return;
        messenger.showSnackBar(
          SnackBar(
            content: Text('✓ Пожертвование от ${donation.fullName} удалено'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
        ref.read(journalProvider.notifier).refresh();
      } on ValidationFailure catch (e) {
        if (!mounted) return;
        // ignore: use_build_context_synchronously
        messenger.showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      } on SheetsFailure catch (e) {
        if (!mounted) return;
        // ignore: use_build_context_synchronously
        messenger.showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        // ignore: use_build_context_synchronously
        messenger.showSnackBar(
          SnackBar(
            content: Text('Ошибка удаления: ${e.toString()}'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  Widget _buildStatusChip(PaymentStatus? status) {
    if (status == null) return const SizedBox.shrink();

    Color chipColor;
    String label;

    switch (status) {
      case PaymentStatus.pending:
        chipColor = Colors.orange;
        label = 'Ожидает';
        break;
      case PaymentStatus.confirmed:
        chipColor = AppTheme.successGreen;
        label = 'Подтверждено';
        break;
      case PaymentStatus.rejected:
        chipColor = AppTheme.errorRed;
        label = 'Отклонено';
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Chip(
        label: Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.white),
        ),
        backgroundColor: chipColor,
        padding: EdgeInsets.zero,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  String _getStatusLabel(PaymentStatus? status) {
    if (status == null) return 'Не указан';
    return status.label;
  }

  Future<void> _confirmPaymentStatus(
    BuildContext context,
    Donation donation,
    PaymentStatus newStatus,
  ) async {
    final statusText = newStatus == PaymentStatus.confirmed 
        ? 'подтвердить' 
        : 'отклонить';
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$statusText Пожертвование?'),
        content: Text(
          'Вы уверены, что хотите $statusText пожертвование от ${donation.fullName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: newStatus == PaymentStatus.confirmed 
                  ? AppTheme.successGreen 
                  : AppTheme.errorRed,
            ),
            child: Text(statusText == 'подтвердить' ? 'Подтвердить' : 'Отклонить'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      // ignore: use_build_context_synchronously
      final messenger = ScaffoldMessenger.of(context);
      try {
        final updateStatusUseCase = ref.read(updateDonationStatusUseCaseProvider);
        await updateStatusUseCase(
          fullName: donation.fullName,
          date: donation.date,
          status: newStatus.name,
        );

        if (!mounted) return;
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              '✓ Статус пожертвования обновлен: ${newStatus.label}',
            ),
            backgroundColor: AppTheme.successGreen,
          ),
        );
        
        // Refresh donations list and clear cache
        await ref.read(journalProvider.notifier).refresh();
        
        // Also refresh goals to update total collected
        ref.read(goalsProvider.notifier).refresh();
      } on ValidationFailure catch (e) {
        if (!mounted) return;
        messenger.showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      } on SheetsFailure catch (e) {
        if (!mounted) return;
        messenger.showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        messenger.showSnackBar(
          SnackBar(
            content: Text('Ошибка обновления: ${e.toString()}'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: AppTheme.spacing8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}

