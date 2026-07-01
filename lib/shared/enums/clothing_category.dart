enum ClothingCategory {
  tops,
  bottoms,
  shoes,
  outerwear,
  accessories,
  dresses;

  String get displayName {
    switch (this) {
      case ClothingCategory.tops:
        return 'Tops';
      case ClothingCategory.bottoms:
        return 'Bottoms';
      case ClothingCategory.shoes:
        return 'Shoes';
      case ClothingCategory.outerwear:
        return 'Outerwear';
      case ClothingCategory.accessories:
        return 'Accessories';
      case ClothingCategory.dresses:
        return 'Dresses';
    }
  }

  String get apiValue {
    return name;
  }
}
