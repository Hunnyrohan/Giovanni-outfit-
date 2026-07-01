class StyleProfileEntity {
  const StyleProfileEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarImage,
    required this.likesCount,
    required this.collectionCount,
  });

  final String id;
  final String name;
  final String email;
  final String avatarImage;
  final String likesCount;
  final int collectionCount;
}
