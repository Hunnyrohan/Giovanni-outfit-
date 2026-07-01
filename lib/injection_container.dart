import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Core
import 'core/network/dio_client.dart';
import 'core/storage/token_storage.dart';

// Auth Features
import 'features/auth/data/datasources/auth_local_datasource.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/get_profile_usecase.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/logout_usecase.dart';
import 'features/auth/domain/usecases/register_usecase.dart';
import 'features/auth/presentation/providers/auth_provider.dart';

// Home Features
import 'features/home/data/datasources/home_local_datasource.dart';
import 'features/home/data/repositories/home_repository_impl.dart';
import 'features/home/domain/repositories/home_repository.dart';
import 'features/home/domain/usecases/get_recommended_outfits_usecase.dart';
import 'features/home/presentation/providers/home_provider.dart';

// Wardrobe Features
import 'features/wardrobe/data/datasources/wardrobe_local_datasource.dart';
import 'features/wardrobe/data/repositories/wardrobe_repository_impl.dart';
import 'features/wardrobe/domain/repositories/wardrobe_repository.dart';
import 'features/wardrobe/domain/usecases/get_wardrobe_items_usecase.dart';
import 'features/wardrobe/domain/usecases/get_saved_outfits_usecase.dart';
import 'features/wardrobe/domain/usecases/get_marketplace_items_usecase.dart';
import 'features/wardrobe/presentation/providers/wardrobe_provider.dart';

final sl = GetIt.instance; // sl stands for Service Locator

Future<void> init() async {
  //! Features - Authentication

  // Providers / ViewModels
  sl.registerFactory(
    () => AuthProvider(
      loginUseCase: sl(),
      registerUseCase: sl(),
      getProfileUseCase: sl(),
      logoutUseCase: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => GetProfileUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));

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
    () => WardrobeRepositoryImpl(sl()),
  );

  // Data Sources
  sl.registerLazySingleton(() => WardrobeLocalDatasource());

  //! Core / External Services

  // Local Token Storage
  sl.registerLazySingleton(() => TokenStorage(sl()));

  // SharedPreferences (Initialized asynchronously, so must be registered as singleton)
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(sharedPreferences);

  // Network Client
  sl.registerLazySingleton(() => Dio());
  sl.registerLazySingleton(() => DioClient(sl(), sl()));
}
