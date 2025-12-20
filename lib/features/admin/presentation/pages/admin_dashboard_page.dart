import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../goals/presentation/providers/goals_provider.dart';
import '../../../journal/presentation/providers/journal_provider.dart';
import '../providers/admin_provider.dart';
import 'manage_goals_page.dart';
import 'manage_donations_page.dart';
import 'manage_users_page.dart';

/// Admin Dashboard - main admin panel.
class AdminDashboardPage extends ConsumerStatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  ConsumerState<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends ConsumerState<AdminDashboardPage> {
  @override
  void initState() {
    super.initState();
    // Load data for dashboard
    Future.microtask(() {
      ref.read(goalsProvider.notifier).loadGoals();
      ref.read(journalProvider.notifier).loadDonations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final goalsState = ref.watch(goalsProvider);
    final journalState = ref.watch(journalProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundMilkWhite,
      appBar: AppBar(
        title: const Text('Панель администратора'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              await Future.wait([
                ref.read(goalsProvider.notifier).refresh(),
                ref.read(journalProvider.notifier).refresh(),
              ]);
              if (mounted) {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('✓ Данные обновлены'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            tooltip: 'Обновить данные',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _handleLogout(context),
            tooltip: 'Выход из админ-панели',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            ref.read(goalsProvider.notifier).refresh(),
            ref.read(journalProvider.notifier).refresh(),
          ]);
        },
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.spacing16),
          children: [
            // Welcome header
            _buildWelcomeCard(context),
            const SizedBox(height: AppTheme.spacing24),

            // Quick stats
            _buildQuickStats(context, goalsState, journalState),
            const SizedBox(height: AppTheme.spacing24),

            // Management sections
            const Text(
              'Управление',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.spacing16),

            _buildManagementCard(
              context,
              icon: Icons.flag,
              title: 'Управление целями',
              subtitle: '${goalsState.goals.length} активных целей',
              color: AppTheme.primarySkyBlue,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ManageGoalsPage()),
                );
              },
            ),

            _buildManagementCard(
              context,
              icon: Icons.volunteer_activism,
              title: 'Управление пожертвованиями',
              subtitle: '${journalState.totalCount} записей',
              color: AppTheme.successGreen,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ManageDonationsPage()),
                );
              },
            ),

            _buildManagementCard(
              context,
              icon: Icons.people,
              title: 'Управление пользователями',
              subtitle: 'Просмотр и управление',
              color: AppTheme.warningOrange,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ManageUsersPage()),
                );
              },
            ),

            const SizedBox(height: AppTheme.spacing40),

            // Security warning
            _buildSecurityWarning(context),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppTheme.primarySkyBlue,
            AppTheme.primaryDark,
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primarySkyBlue.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.admin_panel_settings,
              size: 36,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: AppTheme.spacing16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Добро пожаловать!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing4),
                Text(
                  'Панель управления приложением',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context, goalsState, journalState) {
    final currencyFormat = NumberFormat.currency(symbol: '₸', decimalDigits: 0);

    return Row(
      children: [
        Expanded(
          child: _QuickStatCard(
            icon: Icons.account_balance_wallet,
            value: currencyFormat.format(goalsState.totalCollected),
            label: 'Всего собрано',
            color: AppTheme.successGreen,
          ),
        ),
        const SizedBox(width: AppTheme.spacing12),
        Expanded(
          child: _QuickStatCard(
            icon: Icons.people,
            value: journalState.totalCount.toString(),
            label: 'Пожертвований',
            color: AppTheme.primarySkyBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildManagementCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacing12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(AppTheme.spacing12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSecurityWarning(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber, color: Colors.red.shade700),
          const SizedBox(width: AppTheme.spacing12),
          Expanded(
            child: Text(
              '⚠️ Администраторские действия влияют на всех пользователей. Будьте внимательны!',
              style: TextStyle(
                fontSize: 12,
                color: Colors.red.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выход из админ-панели'),
        content: const Text('Вы уверены?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorRed),
            child: const Text('Выйти'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      // Сначала выйти из админ-панели
      await ref.read(adminAuthProvider.notifier).logout();
      
      if (!mounted) return;
      
      // Вернуться назад (к странице профиля)
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
    }
  }
}

class _QuickStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _QuickStatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: AppTheme.spacing8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppTheme.spacing4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

