class VirtualClothingEntity {
  const VirtualClothingEntity({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.category,
    required this.color,
    this.isSelected = false,
  });

  final String id;
  final String name;
  final String imagePath;
  final String category;
  final String color;
  final bool isSelected;

  VirtualClothingEntity copyWith({bool? isSelected}) {
    return VirtualClothingEntity(
      id: id,
      name: name,
      imagePath: imagePath,
      category: category,
      color: color,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
