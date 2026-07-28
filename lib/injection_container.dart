import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Core
import 'core/network/dio_client.dart';
import 'core/storage/token_storage.dart';
import 'core/theme/theme_provider.dart';

// Auth Features
import 'features/auth/data/datasources/auth_local_datasource.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/get_profile_usecase.dart';
import 'features/auth/domain/usecases/google_login_usecase.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/logout_usecase.dart';
import 'features/auth/domain/usecases/register_usecase.dart';
import 'features/auth/domain/usecases/update_profile_picture_usecase.dart';
import 'features/auth/domain/usecases/verify_two_factor_usecase.dart';
import 'features/auth/presentation/providers/auth_provider.dart';

// AI Stylist Features
import 'features/ai_stylist/data/datasources/ai_remote_datasource.dart';
import 'features/ai_stylist/data/repositories/ai_stylist_repository_impl.dart';
import 'features/ai_stylist/domain/repositories/ai_stylist_repository.dart';
import 'features/ai_stylist/domain/usecases/delete_all_conversations_usecase.dart';
import 'features/ai_stylist/domain/usecases/delete_conversation_usecase.dart';
import 'features/ai_stylist/domain/usecases/get_chat_detail_usecase.dart';
import 'features/ai_stylist/domain/usecases/get_chat_history_usecase.dart';
import 'features/ai_stylist/domain/usecases/send_chat_message_usecase.dart';
import 'features/ai_stylist/presentation/providers/ai_stylist_provider.dart';
import 'features/ai_stylist/presentation/providers/history_provider.dart';

// Virtual Wear Features
import 'features/virtual_wear/data/datasources/virtual_tryon_remote_datasource.dart';
import 'features/virtual_wear/data/repositories/virtual_tryon_repository_impl.dart';
import 'features/virtual_wear/domain/repositories/virtual_tryon_repository.dart';
import 'features/virtual_wear/domain/usecases/create_try_on_usecase.dart';
import 'features/virtual_wear/domain/usecases/delete_try_on_usecase.dart';
import 'features/virtual_wear/domain/usecases/get_try_on_history_usecase.dart';
import 'features/virtual_wear/domain/usecases/get_try_on_status_usecase.dart';
import 'features/virtual_wear/domain/usecases/save_try_on_usecase.dart';
import 'features/virtual_wear/presentation/providers/virtual_wear_provider.dart';

// Home Features
import 'features/home/data/datasources/home_local_datasource.dart';
import 'features/home/data/repositories/home_repository_impl.dart';
import 'features/home/domain/repositories/home_repository.dart';
import 'features/home/domain/usecases/get_recommended_outfits_usecase.dart';
import 'features/home/presentation/providers/home_provider.dart';

// Wardrobe Features
import 'features/wardrobe/data/datasources/wardrobe_local_datasource.dart';
import 'features/wardrobe/data/datasources/wardrobe_remote_datasource.dart';
import 'features/wardrobe/data/repositories/wardrobe_repository_impl.dart';
import 'features/wardrobe/domain/repositories/wardrobe_repository.dart';
import 'features/wardrobe/domain/usecases/get_wardrobe_items_usecase.dart';
import 'features/wardrobe/domain/usecases/get_saved_outfits_usecase.dart';
import 'features/wardrobe/domain/usecases/get_marketplace_items_usecase.dart';
import 'features/wardrobe/presentation/providers/wardrobe_provider.dart';

// Profile Features
import 'features/profile/data/datasources/profile_remote_datasource.dart';
import 'features/profile/data/repositories/profile_repository_impl.dart';
import 'features/profile/domain/repositories/profile_repository.dart';
import 'features/profile/domain/usecases/change_password_usecase.dart';
import 'features/profile/domain/usecases/delete_account_usecase.dart';
import 'features/profile/domain/usecases/delete_profile_avatar_usecase.dart';
import 'features/profile/domain/usecases/disable_two_factor_usecase.dart';
import 'features/profile/domain/usecases/enable_two_factor_usecase.dart';
import 'features/profile/domain/usecases/get_two_factor_status_usecase.dart';
import 'features/profile/domain/usecases/get_user_profile_usecase.dart';
import 'features/profile/domain/usecases/setup_two_factor_usecase.dart';
import 'features/profile/domain/usecases/update_user_profile_usecase.dart';
import 'features/profile/domain/usecases/upload_profile_avatar_usecase.dart';
import 'features/profile/presentation/providers/security_provider.dart';
import 'features/profile/presentation/providers/style_profile_provider.dart';

final sl = GetIt.instance; // sl stands for Service Locator

Future<void> init() async {
  //! Features - Authentication

  // Providers / ViewModels
  sl.registerFactory(
    () => AuthProvider(
      loginUseCase: sl(),
      googleLoginUseCase: sl(),
      registerUseCase: sl(),
      getProfileUseCase: sl(),
      updateProfilePictureUseCase: sl(),
      logoutUseCase: sl(),
      verifyTwoFactorUseCase: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => GoogleLoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => GetProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfilePictureUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => VerifyTwoFactorUseCase(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );

  // Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(tokenStorage: sl(), sharedPreferences: sl()),
  );

  //! Features - AI Stylist

  // Providers
  sl.registerFactory(
    () => AiStylistProvider(
      sendChatMessageUseCase: sl(),
      getChatDetailUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => HistoryProvider(
      getChatHistoryUseCase: sl(),
      deleteConversationUseCase: sl(),
      deleteAllConversationsUseCase: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => SendChatMessageUseCase(sl()));
  sl.registerLazySingleton(() => GetChatHistoryUseCase(sl()));
  sl.registerLazySingleton(() => GetChatDetailUseCase(sl()));
  sl.registerLazySingleton(() => DeleteConversationUseCase(sl()));
  sl.registerLazySingleton(() => DeleteAllConversationsUseCase(sl()));

  // Repository
  sl.registerLazySingleton<AiStylistRepository>(
    () => AiStylistRepositoryImpl(remoteDataSource: sl()),
  );

  // Data Sources
  sl.registerLazySingleton<AiRemoteDataSource>(
    () => AiRemoteDataSourceImpl(sl()),
  );

  //! Features - Virtual Wear

  // Providers
  sl.registerFactory(
    () => VirtualWearProvider(
      createTryOnUseCase: sl(),
      getTryOnStatusUseCase: sl(),
      getTryOnHistoryUseCase: sl(),
      deleteTryOnUseCase: sl(),
      saveTryOnUseCase: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => CreateTryOnUseCase(sl()));
  sl.registerLazySingleton(() => GetTryOnStatusUseCase(sl()));
  sl.registerLazySingleton(() => GetTryOnHistoryUseCase(sl()));
  sl.registerLazySingleton(() => DeleteTryOnUseCase(sl()));
  sl.registerLazySingleton(() => SaveTryOnUseCase(sl()));

  // Repository
  sl.registerLazySingleton<VirtualTryOnRepository>(
    () => VirtualTryOnRepositoryImpl(remoteDataSource: sl()),
  );

  // Data Sources
  sl.registerLazySingleton<VirtualTryOnRemoteDataSource>(
    () => VirtualTryOnRemoteDataSourceImpl(sl()),
  );

  //! Features - Home

  // Providers
  sl.registerFactory(() => HomeProvider(getRecommendedOutfitsUseCase: sl()));

  // Use Cases
  sl.registerLazySingleton(() => GetRecommendedOutfitsUseCase(sl()));

  // Repository
  sl.registerLazySingleton<HomeRepository>(() => HomeRepositoryImpl(sl()));

  // Data Sources
  sl.registerLazySingleton(() => HomeLocalDataSource());

  //! Features - Wardrobe

  // Providers
  sl.registerFactory(
    () => WardrobeProvider(
      getWardrobeItemsUseCase: sl(),
      getSavedOutfitsUseCase: sl(),
      getMarketplaceItemsUseCase: sl(),
      repository: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetWardrobeItemsUseCase(sl()));
  sl.registerLazySingleton(() => GetSavedOutfitsUseCase(sl()));
  sl.registerLazySingleton(() => GetMarketplaceItemsUseCase(sl()));

  // Repository
  sl.registerLazySingleton<WardrobeRepository>(
    () => WardrobeRepositoryImpl(sl(), sl()),
  );

  // Data Sources
  sl.registerLazySingleton(() => WardrobeLocalDatasource());
  sl.registerLazySingleton<WardrobeRemoteDataSource>(
    () => WardrobeRemoteDataSourceImpl(sl()),
  );

  //! Features - Profile

  // Providers
  sl.registerFactory(
    () => StyleProfileProvider(
      getUserProfileUseCase: sl(),
      updateUserProfileUseCase: sl(),
      uploadProfileAvatarUseCase: sl(),
      deleteProfileAvatarUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => SecurityProvider(
      changePasswordUseCase: sl(),
      deleteAccountUseCase: sl(),
      getTwoFactorStatusUseCase: sl(),
      setupTwoFactorUseCase: sl(),
      enableTwoFactorUseCase: sl(),
      disableTwoFactorUseCase: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetUserProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateUserProfileUseCase(sl()));
  sl.registerLazySingleton(() => UploadProfileAvatarUseCase(sl()));
  sl.registerLazySingleton(() => DeleteProfileAvatarUseCase(sl()));
  sl.registerLazySingleton(() => ChangePasswordUseCase(sl()));
  sl.registerLazySingleton(() => DeleteAccountUseCase(sl()));
  sl.registerLazySingleton(() => GetTwoFactorStatusUseCase(sl()));
  sl.registerLazySingleton(() => SetupTwoFactorUseCase(sl()));
  sl.registerLazySingleton(() => EnableTwoFactorUseCase(sl()));
  sl.registerLazySingleton(() => DisableTwoFactorUseCase(sl()));

  // Repository
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(remoteDataSource: sl()),
  );

  // Data Sources
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(sl()),
  );

  //! Core / External Services

  // Local Token Storage (backed by platform secure storage)
  sl.registerLazySingleton(() => const FlutterSecureStorage());
  sl.registerLazySingleton(() => TokenStorage(sl()));

  // SharedPreferences (Initialized asynchronously, so must be registered as singleton)
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(sharedPreferences);

  // App theme (light/dark), persisted in SharedPreferences
  sl.registerLazySingleton(() => ThemeProvider(sl()));

  // Network Client
  sl.registerLazySingleton(() => Dio());
  sl.registerLazySingleton(() => DioClient(sl(), sl()));
}
