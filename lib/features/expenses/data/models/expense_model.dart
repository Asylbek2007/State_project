import '../../domain/entities/expense.dart';

/// Data model for Expense entity.
class ExpenseModel extends Expense {
  const ExpenseModel({
    required super.date,
    required super.category,
    required super.amount,
    required super.description,
    required super.receipt,
  });

  /// Create ExpenseModel from domain entity.
  factory ExpenseModel.fromEntity(Expense expense) {
    return ExpenseModel(
      date: expense.date,
      category: expense.category,
      amount: expense.amount,
      description: expense.description,
      receipt: expense.receipt,
    );
  }

  /// Create ExpenseModel from Google Sheets row.
  ///
  /// Expected row format:
  /// [Date, Category, Amount, Description, Receipt]
  factory ExpenseModel.fromSheetRow(List<dynamic> row) {
    return ExpenseModel(
      date: row.isNotEmpty ? DateTime.parse(row[0].toString()) : DateTime.now(),
      category: row.length > 1 ? row[1].toString() : '',
      amount: row.length > 2 ? _parseDouble(row[2]) : 0.0,
      description: row.length > 3 ? row[3].toString() : '',
      receipt: row.length > 4 ? row[4].toString() : '',
    );
  }

  /// Convert to Google Sheets row.
  List<dynamic> toSheetRow() {
    return [
      date.toIso8601String(),
      category,
      amount,
      description,
      receipt,
    ];
  }

  /// Helper to parse double from dynamic value.
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  /// Convert to map for JSON serialization.
  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'category': category,
      'amount': amount,
      'description': description,
      'receipt': receipt,
    };
  }

  /// Create from map (JSON deserialization).
  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      date: DateTime.parse(map['date'] as String),
      category: map['category'] as String,
      amount: (map['amount'] as num).toDouble(),
      description: map['description'] as String,
      receipt: map['receipt'] as String? ?? '',
    );
  }
}
