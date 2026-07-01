import 'package:flutter/material.dart';

import '../../data/datasources/virtual_wear_local_datasource.dart';
import '../../data/repositories/virtual_wear_repository_impl.dart';
import '../../domain/entities/virtual_clothing_entity.dart';
import '../../domain/usecases/get_virtual_clothes_usecase.dart';

class VirtualWearProvider extends ChangeNotifier {
  VirtualWearProvider({GetVirtualClothesUseCase? getVirtualClothesUseCase})
    : _getVirtualClothesUseCase =
          getVirtualClothesUseCase ??
          GetVirtualClothesUseCase(
            VirtualWearRepositoryImpl(VirtualWearLocalDatasource()),
          );

  final GetVirtualClothesUseCase _getVirtualClothesUseCase;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _showPoseOverlay = true;
  bool get showPoseOverlay => _showPoseOverlay;

  List<VirtualClothingEntity> _clothes = [];
  List<VirtualClothingEntity> get clothes => _clothes;

  VirtualClothingEntity? _selectedClothing;
  VirtualClothingEntity? get selectedClothing => _selectedClothing;

  Future<void> loadClothes() async {
    _isLoading = true;
    notifyListeners();

    _clothes = await _getVirtualClothesUseCase();
    for (final item in _clothes) {
      if (item.isSelected) {
        _selectedClothing = item;
        break;
      }
    }
    _selectedClothing ??= _clothes.isEmpty ? null : _clothes.first;

    _isLoading = false;
    notifyListeners();
  }

  void selectClothing(VirtualClothingEntity clothing) {
    _selectedClothing = clothing;
    _clothes = _clothes
        .map((item) => item.copyWith(isSelected: item.id == clothing.id))
        .toList();
    notifyListeners();
  }

  void togglePoseOverlay() {
    _showPoseOverlay = !_showPoseOverlay;
    notifyListeners();
  }
}
