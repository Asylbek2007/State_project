import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/skeleton_card.dart';
import '../providers/journal_provider.dart';
import '../widgets/donation_card.dart';
import '../widgets/journal_stats_card.dart';

/// Journal page showing all donations history.
class JournalPage extends ConsumerStatefulWidget {
  const JournalPage({super.key});

  @override
  ConsumerState<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends ConsumerState<JournalPage> {
  @override
  void initState() {
    super.initState();
    // Load donations when page opens
    Future.microtask(() => ref.read(journalProvider.notifier).loadDonations());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(journalProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Журнал пожертвований'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(journalProvider.notifier).refresh(),
            tooltip: 'Обновить',
          ),
        ],
      ),
      body: state.isLoading && state.donations.isEmpty
          ? CustomScrollView(
              slivers: [
                // Skeleton for stats card
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: SkeletonCard(height: 120),
                  ),
                ),
                // Skeleton for section header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.history,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'История',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Skeleton for donations list
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => const SkeletonDonationCard(),
                    childCount: 5,
                  ),
                ),
              ],
            )
          : RefreshIndicator(
              onRefresh: () => ref.read(journalProvider.notifier).refresh(),
              child: CustomScrollView(
                slivers: [
                  // Error message
                  if (state.error != null)
                    SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline,
                                color: Colors.red.shade700),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                state.error!,
                                style: TextStyle(color: Colors.red.shade700),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Statistics card
                  if (state.donations.isNotEmpty)
                    SliverToBoxAdapter(
                      child: JournalStatsCard(
                        totalCount: state.totalCount,
                        totalAmount: state.totalAmount,
                        averageAmount: state.averageAmount,
                        topDonor: state.topDonor,
                      ),
                    ),

                  // Section header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.history,
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'История (${state.totalCount})',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Donations list
                  if (state.donations.isEmpty && !state.isLoading)
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
                            const SizedBox(height: 16),
                            Text(
                              'Пока нет пожертвований',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'История будет отображаться здесь',
                              style: theme.textTheme.bodyMedium?.copyWith(
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
                          return DonationCard(
                              donation: state.donations[index]);
                        },
                        childCount: state.donations.length,
                      ),
                    ),

                  // Bottom spacing
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 20),
                  ),
                ],
              ),
            ),
    );
  }
}

