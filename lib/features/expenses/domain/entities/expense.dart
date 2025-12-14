/// Entity representing an expense (college spending).
class Expense {
  final DateTime date;
  final String category;
  final double amount;
  final String description;
  final String receipt;

  const Expense({
    required this.date,
    required this.category,
    required this.amount,
    required this.description,
    required this.receipt,
  });

  /// Check if receipt URL is available
  bool get hasReceipt => receipt.isNotEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Expense &&
          runtimeType == other.runtimeType &&
          date == other.date &&
          category == other.category &&
          amount == other.amount &&
          description == other.description &&
          receipt == other.receipt;

  @override
  int get hashCode =>
      date.hashCode ^
      category.hashCode ^
      amount.hashCode ^
      description.hashCode ^
      receipt.hashCode;

  @override
  String toString() =>
      'Expense(date: $date, category: $category, amount: $amount)';
}
