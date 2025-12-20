import '../../domain/entities/user.dart';

/// Data model for User entity.
///
/// Handles serialization/deserialization for data layer.
class UserModel extends User {
  const UserModel({
    required super.email,
    required super.fullName,
    required super.surname,
    required super.studyGroup,
    required super.registrationDate,
  });

  /// Create UserModel from domain entity.
  factory UserModel.fromEntity(User user) {
    return UserModel(
      email: user.email,
      fullName: user.fullName,
      surname: user.surname,
      studyGroup: user.studyGroup,
      registrationDate: user.registrationDate,
    );
  }

  /// Create UserModel from raw data (e.g., from Google Sheets).
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      email: map['email'] as String,
      fullName: map['fullName'] as String,
      surname: map['surname'] as String? ?? '',
      studyGroup: map['studyGroup'] as String,
      registrationDate: map['registrationDate'] != null
          ? DateTime.parse(map['registrationDate'] as String)
          : DateTime.now(),
    );
  }

  /// Create UserModel from Google Sheets row.
  /// Expected format: [email, passwordHash, fullName, surname, studyGroup, registrationDate]
  factory UserModel.fromSheetRow(List<dynamic> row) {
    return UserModel(
      email: row[0].toString(),
      fullName: row.length > 2 ? row[2].toString() : '',
      surname: row.length > 3 ? row[3].toString() : '',
      studyGroup: row.length > 4 ? row[4].toString() : '',
      registrationDate: row.length > 5 && row[5].toString().isNotEmpty
          ? DateTime.parse(row[5].toString())
          : DateTime.now(),
    );
  }

  /// Convert to map for serialization.
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'fullName': fullName,
      'surname': surname,
      'studyGroup': studyGroup,
      'registrationDate': registrationDate.toIso8601String(),
    };
  }

  /// Convert to list for Google Sheets row.
  /// Format: [email, passwordHash, fullName, surname, studyGroup, registrationDate]
  List<dynamic> toSheetRow(String passwordHash) {
    return [
      email,
      passwordHash,
      fullName,
      surname,
      studyGroup,
      registrationDate.toIso8601String(),
    ];
  }
}

