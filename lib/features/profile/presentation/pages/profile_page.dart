import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/services/token_storage_service.dart';
import '../../../../core/services/admin_service.dart';
import '../../../splash/presentation/pages/splash_page.dart';
import '../../../admin/presentation/pages/admin_login_page.dart';
import '../../../journal/presentation/providers/journal_provider.dart';

/// Profile page showing user info and settings.
class ProfilePage extends ConsumerStatefulWidget {
  final String userName;
  final String userGroup;

  const ProfilePage({
    super.key,
    required this.userName,
    required this.userGroup,
  });

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final AdminService _adminService = AdminService();
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    final isAdmin = await _adminService.isAdmin();
    setState(() {
      _isAdmin = isAdmin;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Профиль'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: AppTheme.spacing24),

            // User Avatar and Info
            _buildUserHeader(context),

            const SizedBox(height: AppTheme.spacing32),

            // Stats Cards
            _buildStatsSection(context),

            const SizedBox(height: AppTheme.spacing24),

            // Settings Section
            _buildSettingsSection(context),

            const SizedBox(height: AppTheme.spacing24),

            // Logout Button
            _buildLogoutButton(context),

            const SizedBox(height: AppTheme.spacing40),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
      padding: const EdgeInsets.all(AppTheme.spacing24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primarySkyBlue,
            AppTheme.primarySkyBlue.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
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
      child: Column(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 3,
              ),
            ),
            child: const Icon(
              Icons.person,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppTheme.spacing16),

          // Name
          Text(
            widget.userName,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacing8),

          // Group Badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacing16,
              vertical: AppTheme.spacing8,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppTheme.radiusCircular),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.school,
                  size: 16,
                  color: Colors.white,
                ),
                const SizedBox(width: AppTheme.spacing8),
                Text(
                  widget.userGroup,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context) {
    final journalState = ref.watch(journalProvider);

    // Подсчитать количество пожертвований текущего пользователя
    final userDonationsCount = _getUserDonationsCount(journalState);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.volunteer_activism,
              label: 'Помощь',
              value: userDonationsCount.toString(),
              color: AppTheme.successGreen,
            ),
          ),
          const SizedBox(width: AppTheme.spacing12),
          const Expanded(
            child: _StatCard(
              icon: Icons.emoji_events,
              label: 'Достижения',
              value: '0',
              color: AppTheme.warningOrange,
            ),
          ),
        ],
      ),
    );
  }

  /// Подсчитать количество пожертвований текущего пользователя.
  int _getUserDonationsCount(JournalState journalState) {
    if (journalState.donations.isEmpty) return 0;

    // Сравниваем userName с fullName в пожертвованиях
    // При создании пожертвования userName сохраняется как fullName
    // Поэтому делаем точное сравнение (без учета регистра)
    final userNameLower = widget.userName.toLowerCase().trim();

    return journalState.donations.where((donation) {
      final donationNameLower = donation.fullName.toLowerCase().trim();
      // Точное совпадение или userName является началом fullName
      // (на случай если fullName содержит фамилию)
      return donationNameLower == userNameLower ||
          donationNameLower.startsWith(userNameLower) ||
          userNameLower.startsWith(donationNameLower);
    }).length;
  }

  Widget _buildSettingsSection(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
      decoration: BoxDecoration(
        color: theme.cardColor,
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
          // Admin Panel Access (always visible for easy access)
          _SettingsTile(
            icon: Icons.admin_panel_settings,
            title: 'Панель администратора',
            subtitle: _isAdmin
                ? 'Вы вошли как администратор'
                : 'Вход в панель управления',
            onTap: () {
              Navigator.of(context)
                  .push(
                    MaterialPageRoute(
                      builder: (_) => const AdminLoginPage(),
                    ),
                  )
                  .then((_) => _checkAdminStatus());
            },
          ),
          const Divider(height: 1, thickness: 1),
          _SettingsTile(
            icon: Icons.help_outline,
            title: 'Помощь и поддержка',
            onTap: () => _openTelegramSupport(context),
          ),
          const Divider(height: 1, thickness: 1),
          _ThemeToggleTile(),
          const Divider(height: 1, thickness: 1),
          _SettingsTile(
            icon: Icons.info_outline,
            title: 'О приложении',
            subtitle: 'Версия 1.0.0',
            onTap: () {
              _showAboutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
      child: OutlinedButton(
        onPressed: () => _handleLogout(context),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.errorRed,
          side: const BorderSide(color: AppTheme.errorRed, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, size: 20),
            SizedBox(width: AppTheme.spacing8),
            Text(
              'Выйти',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openTelegramSupport(BuildContext context) async {
    const telegramUsername = 'Aseke_001_07';

    // Пробуем открыть через Telegram app (tg://)
    final telegramUrl = Uri.parse('tg://resolve?domain=$telegramUsername');
    // Fallback на веб-версию Telegram
    final webUrl = Uri.parse('https://t.me/$telegramUsername');

    try {
      // Пробуем открыть через приложение Telegram
      if (await canLaunchUrl(telegramUrl)) {
        await launchUrl(telegramUrl, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(webUrl)) {
        // Если приложение не установлено, открываем веб-версию
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Не удалось открыть Telegram. Проверьте, установлен ли Telegram.'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка: $e'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выход'),
        content: const Text('Вы уверены, что хотите выйти?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.errorRed,
            ),
            child: const Text('Выйти'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      // Clear token storage
      final tokenService = TokenStorageService();
      await tokenService.clearAll();

      // Navigate to splash (will redirect to registration)
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const SplashPage()),
          (route) => false,
        );
      }
    }
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Donation',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 60,
        height: 60,
        decoration: const BoxDecoration(
          color: AppTheme.primarySkyBlue,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.volunteer_activism,
          size: 30,
          color: Colors.white,
        ),
      ),
      children: [
        const SizedBox(height: 16),
        const Text(
          'Мобильное приложение для сбора пожертвований на развитие колледжа.',
          style: TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 16),
        Text(
          '© 2024 Donation App. Все права защищены.',
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        color: theme.cardColor,
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
          Container(
            padding: const EdgeInsets.all(AppTheme.spacing12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: AppTheme.spacing12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: AppTheme.spacing4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget for theme toggle
class _ThemeToggleTile extends ConsumerWidget {
  const _ThemeToggleTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeModeState = ref.watch(themeModeProvider);
    final isDark = themeModeState.themeMode == ThemeMode.dark;

    return ListTile(
      leading: Icon(
        isDark ? Icons.dark_mode : Icons.light_mode,
        color: AppTheme.primarySkyBlue,
      ),
      title: const Text('Темная тема'),
      subtitle: Text(isDark ? 'Включена' : 'Выключена'),
      trailing: Switch(
        value: isDark,
        onChanged: (value) {
          ref.read(themeModeProvider.notifier).toggleTheme();
        },
        activeColor: AppTheme.primarySkyBlue,
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppTheme.primarySkyBlue,
        size: 24,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            )
          : null,
      trailing: trailing ??
          Icon(
            Icons.chevron_right,
            color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.5),
          ),
      onTap: trailing == null ? onTap : null,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing16,
        vertical: AppTheme.spacing8,
      ),
    );
  }
}
