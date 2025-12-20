/// Entity representing a registered user.
class User {
  final String email;
  final String fullName;
  final String surname;
  final String studyGroup;
  final DateTime registrationDate;

  const User({
    required this.email,
    required this.fullName,
    required this.surname,
    required this.studyGroup,
    required this.registrationDate,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          email == other.email &&
          fullName == other.fullName &&
          surname == other.surname &&
          studyGroup == other.studyGroup &&
          registrationDate == other.registrationDate;

  @override
  int get hashCode =>
      email.hashCode ^
      fullName.hashCode ^
      surname.hashCode ^
      studyGroup.hashCode ^
      registrationDate.hashCode;

  @override
  String toString() =>
      'User(email: $email, fullName: $fullName, surname: $surname, studyGroup: $studyGroup, registrationDate: $registrationDate)';
}

