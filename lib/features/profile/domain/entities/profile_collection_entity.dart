class ProfileCollectionEntity {
  const ProfileCollectionEntity({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.rating,
    required this.category,
    required this.isFavorite,
  });

  final String id;
  final String title;
  final String imageUrl;
  final double price;
  final double rating;
  final String category;
  final bool isFavorite;
}
