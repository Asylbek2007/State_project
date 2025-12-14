/// Entity representing a donation.
class Donation {
  final String fullName;
  final String studyGroup;
  final double amount;
  final DateTime date;
  final String message;
  final String? goalName; // Название цели сбора (опционально)

  const Donation({
    required this.fullName,
    required this.studyGroup,
    required this.amount,
    required this.date,
    required this.message,
    this.goalName,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Donation &&
          runtimeType == other.runtimeType &&
          fullName == other.fullName &&
          studyGroup == other.studyGroup &&
          amount == other.amount &&
          date == other.date &&
          message == other.message &&
          goalName == other.goalName;

  @override
  int get hashCode =>
      fullName.hashCode ^
      studyGroup.hashCode ^
      amount.hashCode ^
      date.hashCode ^
      message.hashCode ^
      (goalName?.hashCode ?? 0);

  @override
  String toString() =>
      'Donation(fullName: $fullName, amount: $amount, date: $date)';
}
