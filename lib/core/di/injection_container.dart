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

import '../services/notification_service.dart';
import '../services/permission_service.dart';

import '../../features/absen/data/datasources/absen_remote_data_source.dart';
import '../../features/absen/data/repositories/absen_repository_impl.dart';
import '../../features/absen/domain/repositories/absen_repository.dart';
import '../../features/absen/presentation/cubit/absen_info_cubit.dart';

import '../../features/absen/presentation/cubit/absen_submit_cubit.dart';
import '../../features/ubah_password/data/datasources/ubah_password_remote_data_source.dart';
import '../../features/ubah_password/data/repositories/ubah_password_repository_impl.dart';
import '../../features/ubah_password/domain/repositories/ubah_password_repository.dart';
import '../../features/ubah_password/presentation/cubit/ubah_password_cubit.dart';
import '../../features/notification/data/datasources/notification_remote_data_source.dart';
import '../../features/notification/data/repositories/notification_repository_impl.dart';
import '../../features/notification/domain/repositories/notification_repository.dart';
import '../../features/notification/presentation/cubit/notification_cubit.dart';
import '../../features/riwayat_absen/data/datasources/riwayat_absen_remote_data_source.dart';
import '../../features/riwayat_absen/data/repositories/riwayat_absen_repository_impl.dart';
import '../../features/riwayat_absen/domain/repositories/riwayat_absen_repository.dart';
import '../../features/riwayat_absen/presentation/cubit/riwayat_absen_cubit.dart';
import '../../features/data_shift/data/datasources/data_shift_remote_data_source.dart';
import '../../features/data_shift/data/repositories/data_shift_repository_impl.dart';
import '../../features/data_shift/domain/repositories/data_shift_repository.dart';
import '../../features/data_shift/presentation/cubit/data_shift_cubit.dart';
import '../../features/history_penilaian/data/datasources/history_penilaian_remote_data_source.dart';
import '../../features/history_penilaian/data/repositories/history_penilaian_repository_impl.dart';
import '../../features/history_penilaian/domain/repositories/history_penilaian_repository.dart';
import '../../features/history_penilaian/presentation/cubit/history_penilaian_cubit.dart';
import '../../features/line_walker/data/datasources/line_walker_remote_data_source.dart';
import '../../features/line_walker/data/repositories/line_walker_repository_impl.dart';
import '../../features/line_walker/domain/repositories/line_walker_repository.dart';
import '../../features/line_walker/presentation/cubit/waterpass_cubit.dart';
import '../../features/line_walker/presentation/cubit/pembumian_cubit.dart';
import '../../features/line_walker/presentation/cubit/ppl_cubit.dart';
import '../../features/line_walker/presentation/cubit/ketenagakerjaan_cubit.dart';
import '../../features/line_walker/presentation/cubit/kegiatan_sosial_cubit.dart';

import '../../features/distribusi/data/datasources/sutm_remote_data_source.dart';
import '../../features/distribusi/data/repositories/sutm_repository_impl.dart';
import '../../features/distribusi/domain/repositories/sutm_repository.dart';
import '../../features/distribusi/presentation/cubit/wo_inspeksi_cubit.dart';
import '../../features/distribusi/presentation/cubit/inspeksi_form_cubit.dart';
import '../../features/distribusi/presentation/cubit/validasi_inspeksi_cubit.dart';
import '../../features/distribusi/presentation/cubit/wo_pemeliharaan_cubit.dart';
import '../../features/distribusi/presentation/cubit/pemeliharaan_form_cubit.dart';
import '../../features/distribusi/presentation/cubit/yantek_cubit.dart';

import '../../features/opgi/data/datasources/opgi_remote_data_source.dart';
import '../../features/opgi/data/repositories/opgi_repository_impl.dart';
import '../../features/opgi/domain/repositories/opgi_repository.dart';
import '../../features/opgi/presentation/cubit/gardu_induk_cubit.dart';
import '../../features/opgi/presentation/cubit/opgi_realisasi_cubit.dart';
import '../../features/opgi/presentation/cubit/opgi_manuver_cubit.dart';
import '../../features/opgi/presentation/cubit/opgi_anomali_cubit.dart';
import '../../features/opgi/presentation/cubit/opgi_il1_cubit.dart';

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
      preferencesService: sl<PreferencesService>(),
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

  sl.registerLazySingleton<PermissionService>(() => PermissionService());
  sl.registerLazySingleton<NotificationService>(() => NotificationService());

  // ─────────────────────────────────────────────────────────────
  // 6. FEATURES: ABSENSI (PRESENSI LAPANGAN)
  // ─────────────────────────────────────────────────────────────
  sl.registerLazySingleton<AbsenRemoteDataSource>(
    () => AbsenRemoteDataSourceImpl(dioClient: sl<DioClient>()),
  );

  sl.registerLazySingleton<AbsenRepository>(
    () => AbsenRepositoryImpl(remoteDataSource: sl<AbsenRemoteDataSource>()),
  );

  sl.registerFactory<AbsenInfoCubit>(
    () => AbsenInfoCubit(
      repository: sl<AbsenRepository>(),
      permissionService: sl<PermissionService>(),
    ),
  );

  sl.registerFactory(
    () => AbsenSubmitCubit(repository: sl(), notificationService: sl()),
  );

  // ─────────────────────────────────────────────────────────────
  // 7. FEATURES: UBAH PASSWORD
  // ─────────────────────────────────────────────────────────────
  sl.registerLazySingleton<UbahPasswordRemoteDataSource>(
    () => UbahPasswordRemoteDataSourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<UbahPasswordRepository>(
    () => UbahPasswordRepositoryImpl(sl<UbahPasswordRemoteDataSource>()),
  );
  sl.registerFactory<UbahPasswordCubit>(
    () => UbahPasswordCubit(sl<UbahPasswordRepository>()),
  );

  // ─────────────────────────────────────────────────────────────
  // 8. FEATURES: NOTIFIKASI
  // ─────────────────────────────────────────────────────────────
  sl.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(sl<NotificationRemoteDataSource>()),
  );
  sl.registerFactory<NotificationCubit>(
    () => NotificationCubit(sl<NotificationRepository>()),
  );

  // ─── Riwayat Absen ───
  sl.registerLazySingleton<RiwayatAbsenRemoteDataSource>(
    () => RiwayatAbsenRemoteDataSourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<RiwayatAbsenRepository>(
    () => RiwayatAbsenRepositoryImpl(sl<RiwayatAbsenRemoteDataSource>()),
  );
  sl.registerFactory<RiwayatAbsenCubit>(
    () => RiwayatAbsenCubit(sl<RiwayatAbsenRepository>()),
  );
  sl.registerFactory<UploadDokumenCubit>(
    () => UploadDokumenCubit(sl<RiwayatAbsenRepository>()),
  );

  // ─── Data Shift ───
  sl.registerLazySingleton<DataShiftRemoteDataSource>(
    () => DataShiftRemoteDataSourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<DataShiftRepository>(
    () => DataShiftRepositoryImpl(sl<DataShiftRemoteDataSource>()),
  );
  sl.registerFactory<DataShiftCubit>(
    () => DataShiftCubit(sl<DataShiftRepository>()),
  );

  // ─── History Penilaian ───
  sl.registerLazySingleton<HistoryPenilaianRemoteDataSource>(
    () => HistoryPenilaianRemoteDataSourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<HistoryPenilaianRepository>(
    () => HistoryPenilaianRepositoryImpl(sl<HistoryPenilaianRemoteDataSource>()),
  );
  sl.registerFactory<HistoryPenilaianCubit>(
    () => HistoryPenilaianCubit(sl<HistoryPenilaianRepository>()),
  );
  sl.registerFactory<DetailHistoryPenilaianCubit>(
    () => DetailHistoryPenilaianCubit(sl<HistoryPenilaianRepository>()),
  );

  // ─── Line Walker ───
  sl.registerLazySingleton<LineWalkerRemoteDataSource>(
    () => LineWalkerRemoteDataSourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<LineWalkerRepository>(
    () => LineWalkerRepositoryImpl(sl<LineWalkerRemoteDataSource>()),
  );
  sl.registerFactory<WaterpassCubit>(
    () => WaterpassCubit(sl<LineWalkerRepository>()),
  );
  sl.registerFactory<PembumianCubit>(
    () => PembumianCubit(sl<LineWalkerRepository>()),
  );
  sl.registerFactory<PplCubit>(
    () => PplCubit(sl<LineWalkerRepository>()),
  );
  sl.registerFactory<KetenagakerjaanCubit>(
    () => KetenagakerjaanCubit(sl<LineWalkerRepository>()),
  );
  sl.registerFactory<KegiatanSosialCubit>(
    () => KegiatanSosialCubit(sl<LineWalkerRepository>()),
  );

  // ─────────────────────────────────────────────────────────────
  // 10. FEATURES: DISTRIBUSI SUTM
  // ─────────────────────────────────────────────────────────────
  sl.registerLazySingleton<SutmRemoteDataSource>(
    () => SutmRemoteDataSourceImpl(apiClient: sl<DioClient>()),
  );
  sl.registerLazySingleton<SutmRepository>(
    () => SutmRepositoryImpl(remoteDataSource: sl<SutmRemoteDataSource>()),
  );

  sl.registerFactory<WoInspeksiCubit>(
    () => WoInspeksiCubit(repository: sl<SutmRepository>()),
  );
  sl.registerFactory<InspeksiFormCubit>(
    () => InspeksiFormCubit(repository: sl<SutmRepository>()),
  );
  sl.registerFactory<ValidasiInspeksiCubit>(
    () => ValidasiInspeksiCubit(repository: sl<SutmRepository>()),
  );
  sl.registerFactory<WoPemeliharaanCubit>(
    () => WoPemeliharaanCubit(repository: sl<SutmRepository>()),
  );
  sl.registerFactory<PemeliharaanFormCubit>(
    () => PemeliharaanFormCubit(repository: sl<SutmRepository>()),
  );
  sl.registerFactory<YantekCubit>(
    () => YantekCubit(repository: sl<SutmRepository>()),
  );

  // ─────────────────────────────────────────────────────────────
  // 11. FEATURES: OPGI 20kV
  // ─────────────────────────────────────────────────────────────
  sl.registerLazySingleton<OpgiRemoteDataSource>(
    () => OpgiRemoteDataSourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<OpgiRepository>(
    () => OpgiRepositoryImpl(sl<OpgiRemoteDataSource>()),
  );

  sl.registerFactory<GarduIndukCubit>(
    () => GarduIndukCubit(sl<OpgiRepository>()),
  );
  sl.registerFactory<OpgiRealisasiCubit>(
    () => OpgiRealisasiCubit(sl<OpgiRepository>()),
  );
  sl.registerFactory<OpgiManuverCubit>(
    () => OpgiManuverCubit(sl<OpgiRepository>()),
  );
  sl.registerFactory<OpgiAnomaliCubit>(
    () => OpgiAnomaliCubit(sl<OpgiRepository>()),
  );
  sl.registerFactory<OpgiIl1Cubit>(
    () => OpgiIl1Cubit(sl<OpgiRepository>()),
  );
}
