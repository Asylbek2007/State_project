/// Entity representing a fundraising goal.
class Goal {
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime deadline;
  final String description;

  const Goal({
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.deadline,
    required this.description,
  });

  /// Calculate progress percentage (0.0 to 1.0)
  double get progress {
    if (targetAmount <= 0) return 0.0;
    final result = currentAmount / targetAmount;
    return result > 1.0 ? 1.0 : result;
  }

  /// Calculate remaining amount needed
  double get remainingAmount {
    final remaining = targetAmount - currentAmount;
    return remaining > 0 ? remaining : 0.0;
  }

  /// Check if goal is completed
  bool get isCompleted => currentAmount >= targetAmount;

  /// Calculate days remaining until deadline
  int get daysRemaining {
    final now = DateTime.now();
    final difference = deadline.difference(now);
    return difference.inDays;
  }

  /// Check if deadline has passed
  bool get isExpired => daysRemaining < 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Goal &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          targetAmount == other.targetAmount &&
          currentAmount == other.currentAmount &&
          deadline == other.deadline &&
          description == other.description;

  @override
  int get hashCode =>
      name.hashCode ^
      targetAmount.hashCode ^
      currentAmount.hashCode ^
      deadline.hashCode ^
      description.hashCode;

  @override
  String toString() =>
      'Goal(name: $name, target: $targetAmount, current: $currentAmount, deadline: $deadline)';
}

