import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/skeleton_card.dart';
import '../../../donation/presentation/pages/donation_page.dart';
import '../../../expenses/presentation/pages/expenses_page.dart';
import '../../../journal/presentation/pages/journal_page.dart';
import '../providers/goals_provider.dart';
import '../widgets/goal_card.dart';
import '../widgets/total_amount_card.dart';

/// Goals page (Main tab) showing fundraising goals and total collected.
///
/// This is the default landing tab in the app.
class GoalsPage extends ConsumerStatefulWidget {
  final String userName;
  final String userGroup;

  const GoalsPage({
    super.key,
    required this.userName,
    required this.userGroup,
  });

  @override
  ConsumerState<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends ConsumerState<GoalsPage> {
  @override
  void initState() {
    super.initState();
    // Load goals when page opens
    Future.microtask(() => ref.read(goalsProvider.notifier).loadGoals());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(goalsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Главная'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const JournalPage()),
              );
            },
            tooltip: 'Журнал',
          ),
          IconButton(
            icon: const Icon(Icons.receipt_long),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ExpensesPage()),
              );
            },
            tooltip: 'Расходы',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(goalsProvider.notifier).refresh(),
            tooltip: 'Обновить',
          ),
        ],
      ),
      body: state.isLoading && state.goals.isEmpty
          ? CustomScrollView(
              slivers: [
                // Skeleton for total amount card
                const SliverToBoxAdapter(
                  child: SkeletonTotalAmountCard(),
                ),
                // Skeleton for section header
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppTheme.spacing16,
                      AppTheme.spacing24,
                      AppTheme.spacing16,
                      AppTheme.spacing8,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.flag,
                          color: AppTheme.primarySkyBlue,
                        ),
                        SizedBox(width: AppTheme.spacing8),
                        Text(
                          'Цели сбора',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Skeleton for goals list
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => const SkeletonGoalCard(),
                    childCount: 3,
                  ),
                ),
              ],
            )
          : RefreshIndicator(
              onRefresh: () => ref.read(goalsProvider.notifier).refresh(),
              child: CustomScrollView(
                slivers: [
                  // Error message
                  if (state.error != null)
                    SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.all(AppTheme.spacing16),
                        padding: const EdgeInsets.all(AppTheme.spacing16),
                        decoration: BoxDecoration(
                          color: AppTheme.errorRed.withValues(alpha: 0.1),
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusMedium),
                          border: Border.all(
                            color: AppTheme.errorRed.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: AppTheme.errorRed,
                            ),
                            const SizedBox(width: AppTheme.spacing12),
                            Expanded(
                              child: Text(
                                state.error!,
                                style: const TextStyle(
                                  color: AppTheme.errorRed,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Total amount card
                  SliverToBoxAdapter(
                    child: TotalAmountCard(
                      totalAmount: state.totalCollected,
                      totalTargetAmount: state.goals.isEmpty
                          ? null
                          : state.goals.fold<double>(
                              0.0,
                              (sum, goal) => sum + goal.targetAmount,
                            ),
                    ),
                  ),

                  // Section header
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        AppTheme.spacing16,
                        AppTheme.spacing24,
                        AppTheme.spacing16,
                        AppTheme.spacing8,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.flag,
                            color: AppTheme.primarySkyBlue,
                          ),
                          SizedBox(width: AppTheme.spacing8),
                          Text(
                            'Цели сбора',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Goals list
                  if (state.goals.isEmpty && !state.isLoading)
                    SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: AppTheme.spacing16),
                            Text(
                              'Пока нет целей сбора',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: AppTheme.spacing8),
                            Text(
                              'Добавьте цели в Google Sheets',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return GoalCard(goal: state.goals[index]);
                        },
                        childCount: state.goals.length,
                      ),
                    ),

                  // Bottom spacing (for FAB)
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 80),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Navigate to donation page
          final result = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => DonationPage(
                userName: widget.userName,
                userGroup: widget.userGroup,
              ),
            ),
          );

          // Refresh if donation was successful
          if (result == true && mounted) {
            ref.read(goalsProvider.notifier).refresh();
          }
        },
        icon: const Icon(Icons.volunteer_activism),
        label: const Text('Помочь'),
        backgroundColor: AppTheme.primarySkyBlue,
      ),
    );
  }
}

