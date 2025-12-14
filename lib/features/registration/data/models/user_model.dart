import '../../domain/entities/user.dart';

/// Data model for User entity.
///
/// Handles serialization/deserialization for data layer.
class UserModel extends User {
  const UserModel({
    required super.fullName,
    required super.surname,
    required super.studyGroup,
    required super.registrationDate,
  });

  /// Create UserModel from domain entity.
  factory UserModel.fromEntity(User user) {
    return UserModel(
      fullName: user.fullName,
      surname: user.surname,
      studyGroup: user.studyGroup,
      registrationDate: user.registrationDate,
    );
  }

  /// Create UserModel from raw data (e.g., from Google Sheets).
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      fullName: map['fullName'] as String,
      surname: map['surname'] as String? ?? '',
      studyGroup: map['studyGroup'] as String,
      registrationDate: map['registrationDate'] != null
          ? DateTime.parse(map['registrationDate'] as String)
          : DateTime.now(),
    );
  }

  /// Create UserModel from Google Sheets row.
  /// Expected format: [fullName, surname, studyGroup, registrationDate]
  factory UserModel.fromSheetRow(List<dynamic> row) {
    return UserModel(
      fullName: row[0].toString(),
      surname: row.length > 1 ? row[1].toString() : '',
      studyGroup: row.length > 2 ? row[2].toString() : '',
      registrationDate: row.length > 3 && row[3].toString().isNotEmpty
          ? DateTime.parse(row[3].toString())
          : DateTime.now(),
    );
  }

  /// Convert to map for serialization.
  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'surname': surname,
      'studyGroup': studyGroup,
      'registrationDate': registrationDate.toIso8601String(),
    };
  }

  /// Convert to list for Google Sheets row.
  /// Format: [fullName, surname, studyGroup, registrationDate]
  List<dynamic> toSheetRow() {
    return [
      fullName,
      surname,
      studyGroup,
      registrationDate.toIso8601String(),
    ];
  }
}

