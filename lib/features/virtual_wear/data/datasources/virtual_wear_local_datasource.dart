import '../models/virtual_clothing_model.dart';

class VirtualWearLocalDatasource {
  Future<List<VirtualClothingModel>> getVirtualClothes() async {
    return const [
      VirtualClothingModel(
        id: 'cream-top',
        name: 'Cream Sleeveless Top',
        imagePath: 'assets/images/virtual_wear/top_cream.png',
        category: 'Top',
        color: 'Cream',
        isSelected: true,
      ),
      VirtualClothingModel(
        id: 'navy-top',
        name: 'Navy Crop Top',
        imagePath: 'assets/images/virtual_wear/top_black.png',
        category: 'Top',
        color: 'Navy',
      ),
    ];
  }
}
