import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/skeleton_card.dart';
import '../../../donation/presentation/pages/donation_page.dart';
import '../../../expenses/presentation/pages/expenses_page.dart';
import '../../../journal/presentation/pages/journal_page.dart';
import '../../../home/presentation/widgets/promo_carousel.dart';
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

class _GoalsPageState extends ConsumerState<GoalsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _fabAnimationController;

  @override
  void initState() {
    super.initState();
    // Initialize FAB animation controller
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    // Load goals when page opens
    Future.microtask(() => ref.read(goalsProvider.notifier).loadGoals());
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
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
          _AnimatedRefreshButton(
            isLoading: state.isLoading,
            onPressed: () => ref.read(goalsProvider.notifier).refresh(),
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
              onRefresh: () async {
                // Add slight delay for better UX
                await Future.delayed(const Duration(milliseconds: 300));
                await ref.read(goalsProvider.notifier).refresh();
              },
              color: AppTheme.primarySkyBlue,
              backgroundColor: Colors.white,
              strokeWidth: 3,
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

                  // Total amount card with animation
                  SliverToBoxAdapter(
                    child: _AnimatedTotalAmountCard(
                      totalAmount: state.totalCollected,
                      totalTargetAmount: state.goals.isEmpty
                          ? null
                          : state.goals.fold<double>(
                              0.0,
                              (sum, goal) => sum + goal.targetAmount,
                            ),
                      key: ValueKey(state.totalCollected),
                    ),
                  ),

                  // Promo Carousel
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppTheme.spacing16,
                        AppTheme.spacing20,
                        AppTheme.spacing16,
                        0,
                      ),
                      child: PromoCarousel(
                        height: 160, // Reduced from default 180 to save space
                        items: [
                          const PromoItem(
                            title: 'Помогаем вместе!',
                            subtitle: 'Каждое пожертвование делает наш колледж лучше',
                            icon: Icons.volunteer_activism,
                          ),
                          const PromoItem(
                            title: 'Прозрачность',
                            subtitle: 'Все расходы отображаются в реальном времени',
                            icon: Icons.visibility,
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.accentBlue,
                                AppTheme.primarySkyBlue,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          if (state.goals.isNotEmpty)
                            PromoItem(
                              title: '${state.goals.length} активных целей',
                              subtitle: 'Выберите цель и помогите прямо сейчас',
                              icon: Icons.flag,
                              gradient: LinearGradient(
                                colors: [
                                  Colors.orange.shade400,
                                  Colors.deepOrange.shade600,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                        ],
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
                      hasScrollBody: false,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacing16,
                          vertical: AppTheme.spacing24,
                        ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
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
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return _AnimatedGoalCard(
                            goal: state.goals[index],
                            index: index,
                            key: ValueKey('${state.goals[index].name}_${state.goals[index].hashCode}_$index'),
                            onTap: () async {
                              // Navigate to donation page with selected goal
                              final result = await Navigator.of(context).push<bool>(
                                MaterialPageRoute(
                                  builder: (_) => DonationPage(
                                    userName: widget.userName,
                                    userGroup: widget.userGroup,
                                    selectedGoalName: state.goals[index].name,
                                  ),
                                ),
                              );

                              // Refresh if donation was successful
                              if (result == true && mounted) {
                                ref.read(goalsProvider.notifier).refresh();
                              }
                            },
                          );
                        },
                        childCount: state.goals.length,
                      ),
                    ),

                  // Bottom spacing (for FAB + BottomNavigationBar)
                  // FAB height ~56px + margin + BottomNavBar ~56px = ~120px minimum
                  // Added extra padding to prevent overflow
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 180),
                  ),
                ],
              ),
            ),
      floatingActionButton: _AnimatedFAB(
        animationController: _fabAnimationController,
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
      ),
    );
  }
}

/// Animated Total Amount Card with fade and scale animation
class _AnimatedTotalAmountCard extends StatefulWidget {
  final double totalAmount;
  final double? totalTargetAmount;

  const _AnimatedTotalAmountCard({
    super.key,
    required this.totalAmount,
    this.totalTargetAmount,
  });

  @override
  State<_AnimatedTotalAmountCard> createState() =>
      _AnimatedTotalAmountCardState();
}

class _AnimatedTotalAmountCardState extends State<_AnimatedTotalAmountCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();
  }

  @override
  void didUpdateWidget(_AnimatedTotalAmountCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.totalAmount != widget.totalAmount) {
      // Animate when amount changes
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: TotalAmountCard(
            totalAmount: widget.totalAmount,
            totalTargetAmount: widget.totalTargetAmount,
          ),
        ),
      ),
    );
  }
}

/// Animated Goal Card with staggered animation
class _AnimatedGoalCard extends StatefulWidget {
  final dynamic goal;
  final int index;
  final VoidCallback? onTap;

  const _AnimatedGoalCard({
    super.key,
    required this.goal,
    required this.index,
    this.onTap,
  });

  @override
  State<_AnimatedGoalCard> createState() => _AnimatedGoalCardState();
}

class _AnimatedGoalCardState extends State<_AnimatedGoalCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Staggered delay based on index
    final delay = widget.index * 100.0;
    final startTime = delay / 600.0;

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(
          startTime.clamp(0.0, 1.0),
          (startTime + 0.6).clamp(0.0, 1.0),
          curve: Curves.easeOut,
        ),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(
          startTime.clamp(0.0, 1.0),
          (startTime + 0.6).clamp(0.0, 1.0),
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(
          startTime.clamp(0.0, 1.0),
          (startTime + 0.6).clamp(0.0, 1.0),
          curve: Curves.easeOutBack,
        ),
      ),
    );

    // Start animation after delay
    Future.delayed(Duration(milliseconds: delay.toInt()), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: GoalCard(
            goal: widget.goal,
            onTap: widget.onTap,
          ),
        ),
      ),
    );
  }
}

/// Animated Floating Action Button with pulse effect
class _AnimatedFAB extends StatelessWidget {
  final AnimationController animationController;
  final VoidCallback onPressed;

  const _AnimatedFAB({
    required this.animationController,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedBuilder(
        animation: animationController,
        builder: (context, child) {
          final baseScale = 1.0 + (animationController.value * 0.05);
          return TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: baseScale, end: baseScale),
            duration: const Duration(milliseconds: 200),
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primarySkyBlue.withValues(
                          alpha: 0.4 + (animationController.value * 0.25),
                        ),
                        blurRadius: 18 + (animationController.value * 12),
                        spreadRadius: 2 + (animationController.value * 3),
                      ),
                    ],
                  ),
                  child: FloatingActionButton.extended(
                    onPressed: onPressed,
                    icon: const Icon(Icons.volunteer_activism),
                    label: const Text('Помочь'),
                    backgroundColor: AppTheme.primarySkyBlue,
                  ),
                ),
              );
            },
            child: child,
          );
        },
      ),
    );
  }
}

/// Animated refresh button with rotation animation
class _AnimatedRefreshButton extends StatefulWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _AnimatedRefreshButton({
    required this.isLoading,
    required this.onPressed,
  });

  @override
  State<_AnimatedRefreshButton> createState() => _AnimatedRefreshButtonState();
}

class _AnimatedRefreshButtonState extends State<_AnimatedRefreshButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void didUpdateWidget(_AnimatedRefreshButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading && !oldWidget.isLoading) {
      _controller.repeat();
    } else if (!widget.isLoading && oldWidget.isLoading) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.rotate(
            angle: _controller.value * 2 * 3.14159,
            child: const Icon(Icons.refresh),
          );
        },
      ),
      onPressed: widget.onPressed,
      tooltip: 'Обновить',
    );
  }
}

