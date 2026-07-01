enum OutfitOccasion {
  casual,
  formal,
  business,
  sporty,
  party,
  date;

  String get displayName {
    switch (this) {
      case OutfitOccasion.casual:
        return 'Casual';
      case OutfitOccasion.formal:
        return 'Formal';
      case OutfitOccasion.business:
        return 'Business / Office';
      case OutfitOccasion.sporty:
        return 'Sporty';
      case OutfitOccasion.party:
        return 'Party & Nightlife';
      case OutfitOccasion.date:
        return 'Date Night';
    }
  }

  String get apiValue {
    return name;
  }
}
