class UserEntity {
  final String id;
  final String name;
  final String email;
  final String? profilePicture;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.profilePicture,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          email == other.email &&
          profilePicture == other.profilePicture;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ email.hashCode ^ profilePicture.hashCode;
}
