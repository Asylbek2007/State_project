import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/skeleton_card.dart';
import '../../../../core/widgets/skeleton_list.dart';
import '../../../journal/presentation/providers/journal_provider.dart';
import '../../../donation/domain/entities/donation.dart';

/// Community page - "Impact Wall"
///
/// Shows:
/// - Recent donations with messages
/// - Top donors leaderboard
/// - Achievement badges
/// - Community stats
class CommunityPage extends ConsumerStatefulWidget {
  const CommunityPage({super.key});

  @override
  ConsumerState<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends ConsumerState<CommunityPage> {
  @override
  void initState() {
    super.initState();
    // Load donations for community stats
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(journalProvider.notifier).loadDonations();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final journalState = ref.watch(journalProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Сообщество'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: journalState.isLoading && journalState.donations.isEmpty
          ? CustomScrollView(
              slivers: [
                // Hero section skeleton
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.all(AppTheme.spacing16),
                    padding: const EdgeInsets.all(AppTheme.spacing24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppTheme.primarySkyBlue,
                          AppTheme.accentBlue,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.people,
                          size: 48,
                          color: Colors.white,
                        ),
                        const SizedBox(height: AppTheme.spacing16),
                        Container(
                          height: 24,
                          width: 200,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacing8),
                        Container(
                          height: 16,
                          width: double.infinity * 0.8,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Stats skeleton
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: AppTheme.spacing24),
                    child: SkeletonCommunityStats(),
                  ),
                ),
                // Section header skeleton
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppTheme.spacing16,
                      AppTheme.spacing24,
                      AppTheme.spacing16,
                      AppTheme.spacing12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 20,
                          width: 150,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacing4),
                        Container(
                          height: 14,
                          width: 200,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Top donors skeleton
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => const SkeletonCard(height: 80),
                    childCount: 3,
                  ),
                ),
              ],
            )
          : RefreshIndicator(
              onRefresh: () async {
                await ref.read(journalProvider.notifier).refresh();
              },
              child: CustomScrollView(
                slivers: [
                  // Hero section
                  SliverToBoxAdapter(
                    child: _buildHeroSection(context),
                  ),

                  // Community Stats
                  SliverToBoxAdapter(
                    child: _buildStatsSection(context, journalState),
                  ),

                  // Top Donors Section
                  SliverToBoxAdapter(
                    child: _buildSectionHeader(
                      context,
                      '🏆 Топ доноры',
                      'Наши герои',
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _buildTopDonors(context, journalState),
                  ),

                  // Recent Impact Stories
                  SliverToBoxAdapter(
                    child: _buildSectionHeader(
                      context,
                      '💬 Истории помощи',
                      'Последние пожертвования с сообщениями',
                    ),
                  ),
                  _buildRecentStories(context, journalState),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: AppTheme.spacing24),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppTheme.spacing16),
      padding: const EdgeInsets.all(AppTheme.spacing24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppTheme.primarySkyBlue,
            AppTheme.accentBlue,
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
          const Icon(
            Icons.people,
            size: 48,
            color: Colors.white,
          ),
          const SizedBox(height: AppTheme.spacing16),
          const Text(
            'Вместе мы сила!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacing8),
          Text(
            'Благодарим каждого, кто помогает развитию нашего колледжа',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context, JournalState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
      child: Row(
        children: [
          Expanded(
            child: _CommunityStatCard(
              icon: Icons.volunteer_activism,
              value: state.totalCount.toString(),
              label: 'Пожертвований',
              color: AppTheme.successGreen,
            ),
          ),
          const SizedBox(width: AppTheme.spacing12),
          Expanded(
            child: _CommunityStatCard(
              icon: Icons.people,
              value: _getUniqueDonors(state).toString(),
              label: 'Доноров',
              color: AppTheme.primarySkyBlue,
            ),
          ),
          const SizedBox(width: AppTheme.spacing12),
          Expanded(
            child: _CommunityStatCard(
              icon: Icons.favorite,
              value: _getMessagesCount(state).toString(),
              label: 'Сообщений',
              color: AppTheme.warningOrange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spacing16,
        AppTheme.spacing24,
        AppTheme.spacing16,
        AppTheme.spacing12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.spacing4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopDonors(BuildContext context, JournalState state) {
    if (state.donations.isEmpty) {
      return _buildEmptyState('Пока нет донатов');
    }

    // Calculate top donors
    final donorTotals = <String, double>{};
    for (final donation in state.donations) {
      donorTotals[donation.fullName] =
          (donorTotals[donation.fullName] ?? 0) + donation.amount;
    }

    final sortedDonors = donorTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final top3 = sortedDonors.take(3).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
      child: Column(
        children: List.generate(top3.length, (index) {
          final entry = top3[index];
          return _TopDonorCard(
            rank: index + 1,
            name: entry.key,
            amount: entry.value,
          );
        }),
      ),
    );
  }

  Widget _buildRecentStories(BuildContext context, JournalState state) {
    final storiesWithMessages = state.donations
        .where((Donation donation) => donation.message.isNotEmpty)
        .take(5)
        .toList();

    if (storiesWithMessages.isEmpty) {
      return SliverToBoxAdapter(
        child: _buildEmptyState('Пока нет историй'),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final donation = storiesWithMessages[index];
          return _ImpactStoryCard(
            name: donation.fullName,
            message: donation.message,
            amount: donation.amount,
            date: donation.date,
          );
        },
        childCount: storiesWithMessages.length,
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing32),
        child: Column(
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: AppTheme.spacing16),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _getUniqueDonors(JournalState state) {
    final uniqueNames = state.donations
        .map((Donation d) => d.fullName)
        .toSet();
    return uniqueNames.length;
  }

  int _getMessagesCount(JournalState state) {
    return state.donations
        .where((Donation d) => d.message.isNotEmpty)
        .length;
  }
}

class _CommunityStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _CommunityStatCard({
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
          Icon(icon, color: color, size: 28),
          const SizedBox(height: AppTheme.spacing8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: AppTheme.spacing4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _TopDonorCard extends StatelessWidget {
  final int rank;
  final String name;
  final double amount;

  const _TopDonorCard({
    required this.rank,
    required this.name,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '₸', decimalDigits: 0);
    
    final medal = rank == 1
        ? '🥇'
        : rank == 2
            ? '🥈'
            : '🥉';

    final color = rank == 1
        ? const Color(0xFFFFD700) // Gold
        : rank == 2
            ? const Color(0xFFC0C0C0) // Silver
            : const Color(0xFFCD7F32); // Bronze

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacing12),
      padding: const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                medal,
                style: const TextStyle(fontSize: 28),
              ),
            ),
          ),
          const SizedBox(width: AppTheme.spacing16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppTheme.spacing4),
                Text(
                  currencyFormat.format(amount),
                  style: TextStyle(
                    fontSize: 14,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacing12,
              vertical: AppTheme.spacing8,
            ),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            child: Text(
              '#$rank',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImpactStoryCard extends StatelessWidget {
  final String name;
  final String message;
  final double amount;
  final DateTime date;

  const _ImpactStoryCard({
    required this.name,
    required this.message,
    required this.amount,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '₸', decimalDigits: 0);
    final dateFormat = DateFormat('dd MMM yyyy');

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing16,
        vertical: AppTheme.spacing8,
      ),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primarySkyBlue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  color: AppTheme.primarySkyBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppTheme.spacing12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      dateFormat.format(date),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacing12,
                  vertical: AppTheme.spacing8,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.successGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: Text(
                  currencyFormat.format(amount),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.successGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing12),
          Container(
            padding: const EdgeInsets.all(AppTheme.spacing12),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.format_quote,
                  size: 16,
                  color: AppTheme.primarySkyBlue,
                ),
                const SizedBox(width: AppTheme.spacing8),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textPrimary,
                      fontStyle: FontStyle.italic,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

