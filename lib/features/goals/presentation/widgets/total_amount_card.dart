import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/hover_card.dart';

/// Widget displaying the total amount collected.
class TotalAmountCard extends StatefulWidget {
  final double totalAmount;
  final double? totalTargetAmount; // Общая сумма всех целей (опционально)

  const TotalAmountCard({
    super.key,
    required this.totalAmount,
    this.totalTargetAmount,
  });

  @override
  State<TotalAmountCard> createState() => _TotalAmountCardState();
}

class _TotalAmountCardState extends State<TotalAmountCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _amountController;
  late Animation<double> _amountAnimation;
  double _previousAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _previousAmount = widget.totalAmount;
    _amountController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _amountAnimation = Tween<double>(
      begin: _previousAmount,
      end: widget.totalAmount,
    ).animate(
      CurvedAnimation(
        parent: _amountController,
        curve: Curves.easeOutCubic,
      ),
    );

    _amountController.forward();
  }

  @override
  void didUpdateWidget(TotalAmountCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.totalAmount != widget.totalAmount) {
      _previousAmount = oldWidget.totalAmount;
      _amountAnimation = Tween<double>(
        begin: _previousAmount,
        end: widget.totalAmount,
      ).animate(
        CurvedAnimation(
          parent: _amountController,
          curve: Curves.easeOutCubic,
        ),
      );
      _amountController.reset();
      _amountController.forward();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '₸', decimalDigits: 0);

    return HoverCard(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      borderRadius: BorderRadius.circular(20),
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primary.withValues(alpha: 0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Всего собрано',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      AnimatedBuilder(
                        animation: _amountAnimation,
                        builder: (context, child) {
                          return Text(
                            currencyFormat.format(_amountAnimation.value),
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          );
                        },
                      ),
                      // Процент от общей цели (если указана)
                      if (widget.totalTargetAmount != null &&
                          widget.totalTargetAmount! > 0) ...[
                        const SizedBox(height: 4),
                        AnimatedBuilder(
                          animation: _amountAnimation,
                          builder: (context, child) {
                            final percentage = ((_amountAnimation.value /
                                        widget.totalTargetAmount!) *
                                    100)
                                .toStringAsFixed(1);
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.trending_up,
                                  size: 16,
                                  color:
                                      Colors.white.withValues(alpha: 0.9),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '$percentage% от цели',
                                  style:
                                      theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.white
                                        .withValues(alpha: 0.9),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Информация о прогрессе и донорах
            Row(
              children: [
                // Процент и сумма осталось (если есть общая цель)
                if (widget.totalTargetAmount != null &&
                    widget.totalTargetAmount! > 0) ...[
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Осталось',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color:
                                  Colors.white.withValues(alpha: 0.9),
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 2),
                          AnimatedBuilder(
                            animation: _amountAnimation,
                            builder: (context, child) {
                              final remaining =
                                  widget.totalTargetAmount! -
                                      _amountAnimation.value;
                              final percentage = ((1.0 -
                                          (_amountAnimation.value /
                                              widget.totalTargetAmount!)) *
                                      100)
                                  .toStringAsFixed(1);
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    currencyFormat.format(remaining),
                                    style: theme
                                        .textTheme.bodyMedium
                                        ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '($percentage%)',
                                    style: theme
                                        .textTheme.bodySmall
                                        ?.copyWith(
                                      color: Colors.white
                                          .withValues(alpha: 0.9),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                // Благодарность донорам
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.people,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Спасибо всем донорам!',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

