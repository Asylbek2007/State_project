/// Payment status enum.
enum PaymentStatus {
  pending('Ожидает подтверждения'),
  confirmed('Подтверждено'),
  rejected('Отклонено');

  final String label;
  const PaymentStatus(this.label);
}

/// Entity representing a donation.
class Donation {
  final String fullName;
  final String studyGroup;
  final double amount;
  final DateTime date;
  final String message;
  final String? goalName; // Название цели сбора (опционально)
  final String? transactionId; // Номер транзакции (опционально)
  final PaymentStatus? paymentStatus; // Статус оплаты (опционально)

  const Donation({
    required this.fullName,
    required this.studyGroup,
    required this.amount,
    required this.date,
    required this.message,
    this.goalName,
    this.transactionId,
    this.paymentStatus,
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
          goalName == other.goalName &&
          transactionId == other.transactionId &&
          paymentStatus == other.paymentStatus;

  @override
  int get hashCode =>
      fullName.hashCode ^
      studyGroup.hashCode ^
      amount.hashCode ^
      date.hashCode ^
      message.hashCode ^
      (goalName?.hashCode ?? 0) ^
      (transactionId?.hashCode ?? 0) ^
      (paymentStatus?.hashCode ?? 0);

  @override
  String toString() =>
      'Donation(fullName: $fullName, amount: $amount, date: $date)';
}
