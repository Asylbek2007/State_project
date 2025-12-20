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
    super.transactionId,
    super.paymentStatus,
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
      transactionId: donation.transactionId,
      paymentStatus: donation.paymentStatus,
    );
  }

  /// Create DonationModel from Google Sheets row.
  ///
  /// Expected row format:
  /// [Full Name, Study Group, Amount, Date, Message, Goal Name, Transaction ID, Payment Status]
  /// Goal Name, Transaction ID, Payment Status are optional (for backward compatibility)
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
      transactionId: row.length > 6 && row[6] != null && row[6].toString().isNotEmpty
          ? row[6].toString()
          : null,
      paymentStatus: row.length > 7 && row[7] != null && row[7].toString().isNotEmpty
          ? _parsePaymentStatus(row[7].toString())
          : null,
    );
  }
  
  /// Parse payment status from string.
  static PaymentStatus? _parsePaymentStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'ожидает подтверждения':
        return PaymentStatus.pending;
      case 'confirmed':
      case 'подтверждено':
        return PaymentStatus.confirmed;
      case 'rejected':
      case 'отклонено':
        return PaymentStatus.rejected;
      default:
        return null;
    }
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
      transactionId ?? '', // Transaction ID (7th column)
      paymentStatus?.name ?? '', // Payment Status (8th column)
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
      'transactionId': transactionId,
      'paymentStatus': paymentStatus?.name,
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
      transactionId: map['transactionId'] as String?,
      paymentStatus: map['paymentStatus'] != null
          ? _parsePaymentStatus(map['paymentStatus'] as String)
          : null,
    );
  }
}

