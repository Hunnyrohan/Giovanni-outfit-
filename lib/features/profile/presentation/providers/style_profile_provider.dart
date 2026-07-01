import 'package:flutter/foundation.dart';

import '../../data/datasources/profile_local_datasource.dart';
import '../../domain/entities/last_outfit_entity.dart';
import '../../domain/entities/profile_collection_entity.dart';
import '../../domain/entities/style_profile_entity.dart';

class StyleProfileProvider extends ChangeNotifier {
  StyleProfileProvider({ProfileLocalDatasource? datasource})
    : _datasource = datasource ?? const ProfileLocalDatasource() {
    load();
  }

  final ProfileLocalDatasource _datasource;
  late StyleProfileEntity profile;
  List<LastOutfitEntity> lastOutfits = const [];
  List<ProfileCollectionEntity> collections = const [];
  bool isLoading = true;

  void load() {
    profile = _datasource.getProfile();
    lastOutfits = _datasource.getLastOutfits();
    collections = _datasource.getCollections();
    isLoading = false;
  }
}
