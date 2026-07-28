import '../../domain/entities/last_outfit_entity.dart';
import '../../domain/entities/profile_collection_entity.dart';
import '../../domain/entities/style_profile_entity.dart';

class ProfileLocalDatasource {
  const ProfileLocalDatasource();

  StyleProfileEntity getProfile() => const StyleProfileEntity(
    id: 'profile-1',
    name: 'Georgia Smith',
    email: 'geosmith009@gmail.com',
    avatarImage:
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=500&q=90',
    likesCount: '1.2K',
    collectionCount: 6,
  );

  List<LastOutfitEntity> getLastOutfits() => const [
    LastOutfitEntity(id: '1', title: 'Monday uniform', emoji: '\u{1F9DC}\u{200D}\u{2640}\u{FE0F}'),
    LastOutfitEntity(id: '2', title: 'Monday uniform', emoji: '\u{1F9DC}\u{200D}\u{2640}\u{FE0F}'),
    LastOutfitEntity(id: '3', title: 'Casual outing', emoji: '\u{1F455}'),
    LastOutfitEntity(id: '4', title: 'Coffee date', emoji: '\u{1F496}'),
  ];

  List<ProfileCollectionEntity> getCollections() => const [
    ProfileCollectionEntity(
      id: 'collection-1',
      title: 'White t-shirt',
      imageUrl:
          'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?auto=format&fit=crop&w=500&q=85',
      price: 2100,
      rating: 4.5,
      category: 'T-shirts',
      isFavorite: false,
    ),
    ProfileCollectionEntity(
      id: 'collection-2',
      title: 'White dress shirt',
      imageUrl:
          'https://images.unsplash.com/photo-1603252109303-2751441dd157?auto=format&fit=crop&w=500&q=85',
      price: 2100,
      rating: 4.5,
      category: 'Shirts',
      isFavorite: false,
    ),
    ProfileCollectionEntity(
      id: 'collection-3',
      title: 'White shirt & tie',
      imageUrl:
          'https://images.unsplash.com/photo-1598033129183-c4f50c736f10?auto=format&fit=crop&w=500&q=85',
      price: 2400,
      rating: 4.7,
      category: 'Shirts',
      isFavorite: true,
    ),
  ];
}
