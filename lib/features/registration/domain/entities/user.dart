/// Entity representing a registered user.
class User {
  final String fullName;
  final String surname;
  final String studyGroup;
  final DateTime registrationDate;

  const User({
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
          fullName == other.fullName &&
          surname == other.surname &&
          studyGroup == other.studyGroup &&
          registrationDate == other.registrationDate;

  @override
  int get hashCode =>
      fullName.hashCode ^ surname.hashCode ^ studyGroup.hashCode ^ registrationDate.hashCode;

  @override
  String toString() =>
      'User(fullName: $fullName, surname: $surname, studyGroup: $studyGroup, registrationDate: $registrationDate)';
}

