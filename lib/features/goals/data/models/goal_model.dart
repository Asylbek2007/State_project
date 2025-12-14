import '../../domain/entities/goal.dart';

/// Data model for Goal entity.
///
/// Handles serialization/deserialization for data layer.
class GoalModel extends Goal {
  const GoalModel({
    required super.name,
    required super.targetAmount,
    required super.currentAmount,
    required super.deadline,
    required super.description,
  });

  /// Create GoalModel from domain entity.
  factory GoalModel.fromEntity(Goal goal) {
    return GoalModel(
      name: goal.name,
      targetAmount: goal.targetAmount,
      currentAmount: goal.currentAmount,
      deadline: goal.deadline,
      description: goal.description,
    );
  }

  /// Create GoalModel from Google Sheets row.
  ///
  /// Expected row format:
  /// [Goal Name, Target Amount, Current Amount, Deadline, Description]
  factory GoalModel.fromSheetRow(List<dynamic> row) {
    return GoalModel(
      name: row.isNotEmpty ? row[0].toString() : '',
      targetAmount: row.length > 1 ? _parseDouble(row[1]) : 0.0,
      currentAmount: row.length > 2 ? _parseDouble(row[2]) : 0.0,
      deadline: row.length > 3 ? DateTime.parse(row[3].toString()) : DateTime.now(),
      description: row.length > 4 ? row[4].toString() : '',
    );
  }

  /// Convert to Google Sheets row.
  List<dynamic> toSheetRow() {
    return [
      name,
      targetAmount,
      currentAmount,
      deadline.toIso8601String(),
      description,
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
      'name': name,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'deadline': deadline.toIso8601String(),
      'description': description,
    };
  }

  /// Create from map (JSON deserialization).
  factory GoalModel.fromMap(Map<String, dynamic> map) {
    return GoalModel(
      name: map['name'] as String,
      targetAmount: (map['targetAmount'] as num).toDouble(),
      currentAmount: (map['currentAmount'] as num).toDouble(),
      deadline: DateTime.parse(map['deadline'] as String),
      description: map['description'] as String,
    );
  }
}

