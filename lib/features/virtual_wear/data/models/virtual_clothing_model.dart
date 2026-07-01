import '../../domain/entities/virtual_clothing_entity.dart';

class VirtualClothingModel extends VirtualClothingEntity {
  const VirtualClothingModel({
    required super.id,
    required super.name,
    required super.imagePath,
    required super.category,
    required super.color,
    super.isSelected,
  });
}
