import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../data/datasources/profile_local_datasource.dart';
import '../../domain/entities/last_outfit_entity.dart';
import '../../domain/entities/profile_collection_entity.dart';
import '../../domain/entities/style_profile_entity.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/usecases/delete_profile_avatar_usecase.dart';
import '../../domain/usecases/get_user_profile_usecase.dart';
import '../../domain/usecases/update_user_profile_usecase.dart';
import '../../domain/usecases/upload_profile_avatar_usecase.dart';

/// Drives the Style Profile screen. Identity fields (name, email, avatar)
/// come from the backend `/profile` API. `lastOutfits` and `collections`
/// still come from [ProfileLocalDatasource] because the Wardrobe/Collections
/// features are not wired to the backend yet — see the project audit.
class StyleProfileProvider extends ChangeNotifier {
  StyleProfileProvider({
    required GetUserProfileUseCase getUserProfileUseCase,
    required UpdateUserProfileUseCase updateUserProfileUseCase,
    required UploadProfileAvatarUseCase uploadProfileAvatarUseCase,
    required DeleteProfileAvatarUseCase deleteProfileAvatarUseCase,
    ProfileLocalDatasource? localDatasource,
  }) : _getUserProfileUseCase = getUserProfileUseCase,
       _updateUserProfileUseCase = updateUserProfileUseCase,
       _uploadProfileAvatarUseCase = uploadProfileAvatarUseCase,
       _deleteProfileAvatarUseCase = deleteProfileAvatarUseCase,
       _localDatasource = localDatasource ?? const ProfileLocalDatasource() {
    load();
  }

  final GetUserProfileUseCase _getUserProfileUseCase;
  final UpdateUserProfileUseCase _updateUserProfileUseCase;
  final UploadProfileAvatarUseCase _uploadProfileAvatarUseCase;
  final DeleteProfileAvatarUseCase _deleteProfileAvatarUseCase;
  final ProfileLocalDatasource _localDatasource;

  UserProfileEntity? _userProfile;

  /// The raw backend identity (bio, phone, gender, date of birth...), used
  /// by the Personal details screen to prefill its form.
  UserProfileEntity? get userProfile => _userProfile;

  List<LastOutfitEntity> lastOutfits = const [];
  List<ProfileCollectionEntity> collections = const [];

  bool isLoading = true;
  bool isSaving = false;
  String? errorMessage;

  /// Merges the real backend identity with the local, not-yet-backed stats
  /// (likes/collection counters) so existing widgets keep working unchanged.
  StyleProfileEntity get profile {
    final localMock = _localDatasource.getProfile();

    if (_userProfile == null) {
      return localMock;
    }

    return StyleProfileEntity(
      id: _userProfile!.id,
      name: _userProfile!.fullName,
      email: _userProfile!.email,
      avatarImage: _userProfile!.profileImage ?? localMock.avatarImage,
      likesCount: localMock.likesCount,
      collectionCount: localMock.collectionCount,
    );
  }

  /// Fetches the profile from the backend. Called on provider creation and
  /// can be called again to pull-to-refresh the screen.
  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    lastOutfits = _localDatasource.getLastOutfits();
    collections = _localDatasource.getCollections();

    final result = await _getUserProfileUseCase();
    result.fold(
      (failure) {
        errorMessage = failure.message;
      },
      (userProfile) {
        _userProfile = userProfile;
        errorMessage = null;
      },
    );

    isLoading = false;
    notifyListeners();
  }

  /// Re-fetches the profile from the backend (alias kept for callers that
  /// want an explicit "refresh" action distinct from the initial load).
  Future<void> refreshProfile() => load();

  Future<bool> updateProfile({
    String? fullName,
    String? bio,
    String? gender,
    String? phoneNumber,
    DateTime? dateOfBirth,
  }) async {
    isSaving = true;
    errorMessage = null;
    notifyListeners();

    final result = await _updateUserProfileUseCase(
      fullName: fullName,
      bio: bio,
      gender: gender,
      phoneNumber: phoneNumber,
      dateOfBirth: dateOfBirth,
    );

    return result.fold(
      (failure) {
        errorMessage = failure.message;
        isSaving = false;
        notifyListeners();
        return false;
      },
      (userProfile) {
        _userProfile = userProfile;
        errorMessage = null;
        isSaving = false;
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> uploadAvatar(File imageFile) async {
    isSaving = true;
    errorMessage = null;
    notifyListeners();

    final result = await _uploadProfileAvatarUseCase(imageFile);

    return result.fold(
      (failure) {
        errorMessage = failure.message;
        isSaving = false;
        notifyListeners();
        return false;
      },
      (userProfile) {
        _userProfile = userProfile;
        errorMessage = null;
        isSaving = false;
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> deleteAvatar() async {
    isSaving = true;
    errorMessage = null;
    notifyListeners();

    final result = await _deleteProfileAvatarUseCase();

    return result.fold(
      (failure) {
        errorMessage = failure.message;
        isSaving = false;
        notifyListeners();
        return false;
      },
      (userProfile) {
        _userProfile = userProfile;
        errorMessage = null;
        isSaving = false;
        notifyListeners();
        return true;
      },
    );
  }
}
