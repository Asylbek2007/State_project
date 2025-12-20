import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/services/google_sheets_service.dart';
import '../../../../core/providers/google_sheets_provider.dart';
import '../providers/admin_providers.dart';

/// State for users list.
class UsersState {
  final List<UserInfo> users;
  final bool isLoading;
  final String? error;

  const UsersState({
    this.users = const [],
    this.isLoading = false,
    this.error,
  });

  UsersState copyWith({
    List<UserInfo>? users,
    bool? isLoading,
    String? error,
  }) {
    return UsersState(
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// User info model.
class UserInfo {
  final String fullName;
  final String surname;
  final String studyGroup;
  final DateTime registrationDate;
  final int rowIndex; // Google Sheets row number

  const UserInfo({
    required this.fullName,
    required this.surname,
    required this.studyGroup,
    required this.registrationDate,
    required this.rowIndex,
  });
}

/// Notifier for users management.
class UsersNotifier extends StateNotifier<UsersState> {
  final GoogleSheetsService sheetsService;

  UsersNotifier(this.sheetsService) : super(const UsersState());

  Future<void> loadUsers() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final rows = await sheetsService.readSheet(
        'Users',
        range: 'A2:D1000', // Skip header row, now includes: Full Name | Surname | Study Group | Registration Date
      );

      final users = <UserInfo>[];
      for (var i = 0; i < rows.length; i++) {
        final row = rows[i];
        if (row.length >= 3 && row[0].toString().isNotEmpty) {
          try {
            users.add(UserInfo(
              fullName: row[0].toString(),
              surname: row.length > 1 ? row[1].toString() : '',
              studyGroup: row.length > 2 ? row[2].toString() : '',
              registrationDate: row.length > 3 && row[3].toString().isNotEmpty
                  ? _parseDate(row[3].toString())
                  : DateTime.now(),
              rowIndex: i + 2, // +2 because sheets are 1-indexed and skip header
            ));
          } catch (e) {
            print('Error parsing user row $i: $e');
          }
        }
      }

      state = state.copyWith(isLoading: false, users: users);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() => loadUsers();

  DateTime _parseDate(String dateStr) {
    try {
      // Try DD.MM.YYYY format
      final parts = dateStr.split('.');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      }
      // Try ISO format
      return DateTime.parse(dateStr);
    } catch (e) {
      return DateTime.now();
    }
  }
}

/// Provider for users management.
final usersProvider = StateNotifierProvider<UsersNotifier, UsersState>((ref) {
  final sheetsService = ref.watch(googleSheetsServiceProvider);
  return UsersNotifier(sheetsService);
});

/// Manage Users page - view and manage registered users.
class ManageUsersPage extends ConsumerStatefulWidget {
  const ManageUsersPage({super.key});

  @override
  ConsumerState<ManageUsersPage> createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends ConsumerState<ManageUsersPage> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(usersProvider.notifier).loadUsers());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(usersProvider);
    final filteredUsers = _searchQuery.isEmpty
        ? state.users
        : state.users
            .where((u) =>
                u.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                u.studyGroup.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundMilkWhite,
      appBar: AppBar(
        title: const Text('Управление пользователями'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(usersProvider.notifier).refresh(),
          ),
        ],
      ),
      body: state.isLoading && state.users.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => ref.read(usersProvider.notifier).refresh(),
              child: Column(
                children: [
                  // Search bar
                  Padding(
                    padding: const EdgeInsets.all(AppTheme.spacing16),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Поиск по имени или группе...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                      ),
                      onChanged: (value) {
                        setState(() => _searchQuery = value);
                      },
                    ),
                  ),

                  // Stats banner
                  _buildStatsBanner(context, state.users.length, filteredUsers.length),

                  // Users list
                  Expanded(
                    child: filteredUsers.isEmpty
                        ? _buildEmptyState(context)
                        : ListView.builder(
                            padding: const EdgeInsets.all(AppTheme.spacing16),
                            itemCount: filteredUsers.length,
                            itemBuilder: (context, index) {
                              return _buildUserCard(context, filteredUsers[index]);
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatsBanner(BuildContext context, int total, int filtered) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
      padding: const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        color: AppTheme.primarySkyBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Row(
        children: [
          const Icon(Icons.people, color: AppTheme.primarySkyBlue),
          const SizedBox(width: AppTheme.spacing12),
          Expanded(
            child: Text(
              _searchQuery.isEmpty
                  ? 'Всего пользователей: $total'
                  : 'Найдено: $filtered из $total',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _searchQuery.isEmpty ? Icons.people_outline : Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: AppTheme.spacing16),
          Text(
            _searchQuery.isEmpty
                ? 'Нет зарегистрированных пользователей'
                : 'Пользователи не найдены',
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, UserInfo user) {
    final dateFormat = DateFormat('dd.MM.yyyy');

    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacing12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primarySkyBlue.withValues(alpha: 0.1),
          child: Text(
            user.fullName[0].toUpperCase(),
            style: const TextStyle(
              color: AppTheme.primarySkyBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          '${user.fullName} ${user.surname}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${user.studyGroup} • Рег.: ${dateFormat.format(user.registrationDate)}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            if (value == 'delete') {
              _confirmDeleteUser(context, user);
            } else if (value == 'info') {
              _showUserInfo(context, user);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'info',
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 20),
                  SizedBox(width: AppTheme.spacing8),
                  Text('Подробнее'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline, size: 20, color: AppTheme.errorRed),
                  SizedBox(width: AppTheme.spacing8),
                  Text('Удалить', style: TextStyle(color: AppTheme.errorRed)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showUserInfo(BuildContext context, UserInfo user) async {
    String formatDate(DateTime date) {
      try {
        return DateFormat('dd MMMM yyyy', 'ru').format(date);
      } catch (e) {
        return DateFormat('dd.MM.yyyy').format(date);
      }
    }
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${user.fullName} ${user.surname}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InfoRow(label: 'Имя', value: user.fullName),
            _InfoRow(label: 'Фамилия', value: user.surname),
            _InfoRow(label: 'Группа', value: user.studyGroup),
            _InfoRow(
              label: 'Дата регистрации',
              value: formatDate(user.registrationDate),
            ),
            _InfoRow(label: 'ID строки', value: user.rowIndex.toString()),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteUser(BuildContext context, UserInfo user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить пользователя?'),
        content: Text(
          'Вы уверены, что хотите удалить пользователя "${user.fullName} ${user.surname}"? Это действие нельзя отменить.',
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
      // ignore: use_build_context_synchronously
      final messenger = ScaffoldMessenger.of(context);
      try {
        final deleteUserUseCase = ref.read(deleteUserUseCaseProvider);
        await deleteUserUseCase(user.fullName);

        if (!mounted) return;
        messenger.showSnackBar(
          SnackBar(
            content: Text('✓ Пользователь "${user.fullName} ${user.surname}" удален'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
        ref.read(usersProvider.notifier).refresh();
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
            content: Text('Ошибка удаления: ${e.toString()}'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacing12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

