import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/donation_provider.dart';
import '../widgets/donation_form.dart';
import '../../../goals/presentation/providers/goals_provider.dart';

/// Page for making donations.
class DonationPage extends ConsumerStatefulWidget {
  final String userName;
  final String userGroup;

  const DonationPage({
    super.key,
    required this.userName,
    required this.userGroup,
  });

  @override
  ConsumerState<DonationPage> createState() => _DonationPageState();
}

class _DonationPageState extends ConsumerState<DonationPage> {
  @override
  void initState() {
    super.initState();
    // Reset state when entering page
    Future.microtask(() {
      ref.read(donationProvider.notifier).reset();
      // Загружаем цели, если они еще не загружены
      final goalsState = ref.read(goalsProvider);
      if (goalsState.goals.isEmpty && !goalsState.isLoading) {
        ref.read(goalsProvider.notifier).loadGoals();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(donationProvider);
    final goalsState = ref.watch(goalsProvider);
    final theme = Theme.of(context);

    // Listen for successful donation
    ref.listen<DonationState>(donationProvider, (previous, next) {
      if (next.donation != null && previous?.donation == null) {
        _showSuccessDialog(context, next.donation!.amount);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Помочь'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Icon(
                  Icons.volunteer_activism,
                  size: 64,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Сделать пожертвование',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Ваша помощь очень важна для нас!',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Error message
                if (state.error != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade700),
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

                // Donation Form
                DonationForm(
                  userName: widget.userName,
                  userGroup: widget.userGroup,
                  goals: goalsState.goals,
                  isLoading: state.isLoading,
                  onSubmit: (amount, message, goalName) {
                    ref.read(donationProvider.notifier).makeDonation(
                          fullName: widget.userName,
                          studyGroup: widget.userGroup,
                          amount: amount,
                          message: message,
                          goalName: goalName,
                        );
                  },
                ),

                const SizedBox(height: 24),

                // Info text
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Все средства используются на развитие колледжа и помощь студентам',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, double amount) {
    final currencyFormat = NumberFormat.currency(symbol: '₸', decimalDigits: 0);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 64,
        ),
        title: const Text('Спасибо!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Ваше пожертвование ${currencyFormat.format(amount)} успешно зарегистрировано.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Благодарим за вашу помощь! 💙',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(); // Close dialog
              Navigator.of(context).pop(true); // Return to main page with success flag
            },
            child: const Text('Вернуться'),
          ),
        ],
      ),
    );
  }
}

