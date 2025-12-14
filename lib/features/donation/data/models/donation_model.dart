import '../../domain/entities/donation.dart';

/// Data model for Donation entity.
class DonationModel extends Donation {
  const DonationModel({
    required super.fullName,
    required super.studyGroup,
    required super.amount,
    required super.date,
    required super.message,
    super.goalName,
  });

  /// Create DonationModel from domain entity.
  factory DonationModel.fromEntity(Donation donation) {
    return DonationModel(
      fullName: donation.fullName,
      studyGroup: donation.studyGroup,
      amount: donation.amount,
      date: donation.date,
      message: donation.message,
      goalName: donation.goalName,
    );
  }

  /// Create DonationModel from Google Sheets row.
  ///
  /// Expected row format:
  /// [Full Name, Study Group, Amount, Date, Message, Goal Name]
  /// Goal Name is optional (for backward compatibility)
  factory DonationModel.fromSheetRow(List<dynamic> row) {
    return DonationModel(
      fullName: row.isNotEmpty ? row[0].toString() : '',
      studyGroup: row.length > 1 ? row[1].toString() : '',
      amount: row.length > 2 ? _parseDouble(row[2]) : 0.0,
      date: row.length > 3 ? DateTime.parse(row[3].toString()) : DateTime.now(),
      message: row.length > 4 ? row[4].toString() : '',
      goalName: row.length > 5 && row[5] != null && row[5].toString().isNotEmpty
          ? row[5].toString()
          : null,
    );
  }

  /// Convert to Google Sheets row.
  List<dynamic> toSheetRow() {
    return [
      fullName,
      studyGroup,
      amount,
      date.toIso8601String(),
      message,
      goalName ?? '', // Goal Name (6th column)
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
      'fullName': fullName,
      'studyGroup': studyGroup,
      'amount': amount,
      'date': date.toIso8601String(),
      'message': message,
      'goalName': goalName,
    };
  }

  /// Create from map (JSON deserialization).
  factory DonationModel.fromMap(Map<String, dynamic> map) {
    return DonationModel(
      fullName: map['fullName'] as String,
      studyGroup: map['studyGroup'] as String,
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
      message: map['message'] as String? ?? '',
      goalName: map['goalName'] as String?,
    );
  }
}

