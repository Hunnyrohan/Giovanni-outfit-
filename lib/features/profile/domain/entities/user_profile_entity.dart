class UserProfileEntity {
  const UserProfileEntity({
    required this.id,
    required this.fullName,
    required this.email,
    this.gender,
    this.profileImage,
    this.bio,
    this.phoneNumber,
    this.dateOfBirth,
    this.isEmailVerified = false,
  });

  final String id;
  final String fullName;
  final String email;
  final String? gender;
  final String? profileImage;
  final String? bio;
  final String? phoneNumber;
  final DateTime? dateOfBirth;
  final bool isEmailVerified;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfileEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          fullName == other.fullName &&
          email == other.email &&
          gender == other.gender &&
          profileImage == other.profileImage &&
          bio == other.bio &&
          phoneNumber == other.phoneNumber &&
          dateOfBirth == other.dateOfBirth &&
          isEmailVerified == other.isEmailVerified;

  @override
  int get hashCode => Object.hash(
    id,
    fullName,
    email,
    gender,
    profileImage,
    bio,
    phoneNumber,
    dateOfBirth,
    isEmailVerified,
  );
}
