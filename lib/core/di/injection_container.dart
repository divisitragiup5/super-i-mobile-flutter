import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_event.dart';
import '../../features/home/data/datasources/home_summary_remote_data_source.dart';
import '../../features/home/data/repositories/home_summary_repository_impl.dart';
import '../../features/home/domain/repositories/home_summary_repository.dart';
import '../../features/home/presentation/cubit/sutm_inspeksi_score_cubit.dart';
import '../../features/home/presentation/cubit/sutm_pemeliharaan_score_cubit.dart';
import '../network/dio_client.dart';
import '../network/network_info.dart';
import '../storage/local_database.dart';
import '../storage/preferences_service.dart';
import '../storage/secure_storage_service.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ─────────────────────────────────────────────────────────────
  // 1. EXTERNAL LIBRARIES
  // ─────────────────────────────────────────────────────────────
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );

  sl.registerLazySingleton<Connectivity>(() => Connectivity());
  sl.registerLazySingleton<Dio>(() => Dio());

  // ─────────────────────────────────────────────────────────────
  // 2. CORE STORAGE SERVICES
  // ─────────────────────────────────────────────────────────────
  sl.registerLazySingleton<PreferencesService>(
    () => PreferencesService(sl<SharedPreferences>()),
  );

  sl.registerLazySingleton<SecureStorageService>(
    () => SecureStorageService(sl<FlutterSecureStorage>()),
  );

  sl.registerLazySingleton<LocalDatabase>(() => LocalDatabase());

  // ─────────────────────────────────────────────────────────────
  // 3. CORE NETWORK SERVICES
  // ─────────────────────────────────────────────────────────────
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(sl<Connectivity>()),
  );

  sl.registerLazySingleton<DioClient>(
    () => DioClient(
      dio: sl<Dio>(),
      secureStorage: sl<FlutterSecureStorage>(),
      onUnauthorized: () {
        // Otomatis bersihkan sesi jika server merespon 401
        sl<AuthBloc>().add(AuthLogoutRequested());
      },
    ),
  );

  // ─────────────────────────────────────────────────────────────
  // 4. FEATURES: AUTHENTICATION
  // ─────────────────────────────────────────────────────────────

  // Data Source
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl<DioClient>()),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl<AuthRemoteDataSource>(),
      secureStorage: sl<SecureStorageService>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  // UseCases
  sl.registerLazySingleton(() => LoginUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => LogoutUseCase(sl<AuthRepository>()));

  // Bloc (Menggunakan LazySingleton agar status profil user yang login tetap tersimpan di memori aplikasi)
  sl.registerLazySingleton<AuthBloc>(
    () => AuthBloc(
      loginUseCase: sl<LoginUseCase>(),
      getCurrentUserUseCase: sl<GetCurrentUserUseCase>(),
      logoutUseCase: sl<LogoutUseCase>(),
    ),
  );

  // ─────────────────────────────────────────────────────────────
  // 5. FEATURES: HOME SUMMARIES (SUTM INSPEKSI & PEMELIHARAAN)
  // ─────────────────────────────────────────────────────────────

  sl.registerLazySingleton<HomeSummaryRemoteDataSource>(
    () => HomeSummaryRemoteDataSourceImpl(dioClient: sl<DioClient>()),
  );

  sl.registerLazySingleton<HomeSummaryRepository>(
    () => HomeSummaryRepositoryImpl(
      remoteDataSource: sl<HomeSummaryRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  sl.registerFactory<SutmInspeksiScoreCubit>(
    () => SutmInspeksiScoreCubit(repository: sl<HomeSummaryRepository>()),
  );

  sl.registerFactory<SutmPemeliharaanScoreCubit>(
    () => SutmPemeliharaanScoreCubit(repository: sl<HomeSummaryRepository>()),
  );
}