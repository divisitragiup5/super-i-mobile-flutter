import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/absen/presentation/pages/absen_page.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/main/presentation/pages/main_scaffold.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/absen/presentation/pages/absen_processing_page.dart';
import '../../features/absen/domain/entities/absen_location_entity.dart';
import '../../features/ubah_password/presentation/pages/ubah_password_page.dart';
import '../../features/notification/presentation/pages/notification_page.dart';
import '../../features/riwayat_absen/data/models/riwayat_absen_model.dart';
import '../../features/riwayat_absen/presentation/pages/riwayat_absen_detail_page.dart';
import '../../features/riwayat_absen/presentation/pages/riwayat_absen_page.dart';
import '../../features/riwayat_absen/presentation/pages/riwayat_absen_update_page.dart';
import '../../features/data_shift/presentation/pages/data_shift_page.dart';
import '../../features/history_penilaian/data/models/history_penilaian_model.dart';
import '../../features/history_penilaian/presentation/pages/detail_history_penilaian_page.dart';
import '../../features/history_penilaian/presentation/pages/history_penilaian_page.dart';
import '../di/injection_container.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/line_walker/data/models/ketenagakerjaan_model.dart';
import '../../features/line_walker/data/models/waterpass_model.dart';
import '../../features/line_walker/presentation/cubit/kegiatan_sosial_cubit.dart';
import '../../features/line_walker/presentation/cubit/ketenagakerjaan_cubit.dart';
import '../../features/line_walker/presentation/cubit/pembumian_cubit.dart';
import '../../features/line_walker/presentation/cubit/ppl_cubit.dart';
import '../../features/line_walker/presentation/cubit/waterpass_cubit.dart';
import '../../features/line_walker/presentation/pages/kegiatan_sosial_form_page.dart';
import '../../features/line_walker/presentation/pages/ketenagakerjaan_detail_page.dart';
import '../../features/line_walker/presentation/pages/ketenagakerjaan_page.dart';
import '../../features/line_walker/presentation/pages/pembumian_form_page.dart';
import '../../features/line_walker/presentation/pages/ppl_form_page.dart';
import '../../features/line_walker/presentation/pages/riwayat_kegiatan_sosial_detail_page.dart';
import '../../features/line_walker/presentation/pages/riwayat_kegiatan_sosial_list_page.dart';
import '../../features/line_walker/presentation/pages/riwayat_kegiatan_sosial_page.dart';
import '../../features/line_walker/presentation/pages/riwayat_pembumian_detail_page.dart';
import '../../features/line_walker/presentation/pages/riwayat_pembumian_page.dart';
import '../../features/line_walker/presentation/pages/riwayat_ppl_detail_page.dart';
import '../../features/line_walker/presentation/pages/riwayat_ppl_list_page.dart';
import '../../features/line_walker/presentation/pages/riwayat_ppl_page.dart';
import '../../features/line_walker/presentation/pages/riwayat_waterpass_detail_page.dart';
import '../../features/line_walker/presentation/pages/summary_ketenagakerjaan_page.dart';
import '../../features/line_walker/presentation/pages/summary_pembumian_page.dart';
import '../../features/line_walker/presentation/pages/summary_riwayat_ppl_page.dart';
import '../../features/line_walker/presentation/pages/update_kegiatan_sosial_page.dart';
import '../../features/line_walker/presentation/pages/update_ppl_page.dart';
import '../../features/line_walker/presentation/pages/waterpass_form_page.dart';

// SUTM
import '../../features/distribusi/presentation/cubit/wo_inspeksi_cubit.dart';
import '../../features/distribusi/presentation/cubit/inspeksi_form_cubit.dart';
import '../../features/distribusi/presentation/cubit/validasi_inspeksi_cubit.dart';
import '../../features/distribusi/presentation/cubit/wo_pemeliharaan_cubit.dart';
import '../../features/distribusi/presentation/cubit/pemeliharaan_form_cubit.dart';
import '../../features/distribusi/presentation/cubit/yantek_cubit.dart';
import '../../features/distribusi/presentation/pages/workorder_inspeksi_page.dart';
import '../../features/distribusi/presentation/pages/detail_workorder_today_page.dart';
import '../../features/distribusi/presentation/pages/detail_workorder_page.dart';
import '../../features/distribusi/presentation/pages/rute_inspeksi_page.dart';
import '../../features/distribusi/presentation/pages/detail_sutm_page.dart';
import '../../features/distribusi/presentation/pages/validasi_inspeksi_page.dart';
import '../../features/distribusi/presentation/pages/validasi_detail_workorder_page.dart';
import '../../features/distribusi/presentation/pages/riwayat_inspeksi_page.dart';
import '../../features/distribusi/presentation/pages/workorder_pemeliharaan_page.dart';
import '../../features/distribusi/presentation/pages/detail_workorder_pemeliharaan_today_page.dart';
import '../../features/distribusi/presentation/pages/detail_workorder_pemeliharaan_page.dart';
import '../../features/distribusi/presentation/pages/rute_pemeliharaan_page.dart';
import '../../features/distribusi/presentation/pages/inspeksi_pemeliharaan_form_page.dart';
import '../../features/distribusi/presentation/pages/validasi_pemeliharaan_page.dart';
import '../../features/distribusi/presentation/pages/riwayat_pemeliharaan_page.dart';
import '../../features/distribusi/presentation/pages/inspeksi_yantek_page.dart';
import '../../features/distribusi/presentation/pages/inspeksi_yantek_form_page.dart';
import '../../features/distribusi/presentation/pages/riwayat_penilaian_inspeksi_page.dart';
import '../../features/distribusi/presentation/pages/riwayat_penilaian_har_page.dart';
import '../../features/distribusi/data/models/sutm_workorder_model.dart';

// OPGI
import '../../features/opgi/presentation/cubit/gardu_induk_cubit.dart';
import '../../features/opgi/presentation/cubit/opgi_realisasi_cubit.dart';
import '../../features/opgi/presentation/cubit/opgi_manuver_cubit.dart';
import '../../features/opgi/presentation/cubit/opgi_anomali_cubit.dart';
import '../../features/opgi/presentation/cubit/opgi_il1_cubit.dart';
import '../../features/opgi/presentation/pages/gardu_induk_hub_page.dart';
import '../../features/opgi/presentation/pages/input_realisasi_hub_page.dart';
import '../../features/opgi/presentation/pages/beban_trafo_page.dart';
import '../../features/opgi/presentation/pages/input_beban_trafo_page.dart';
import '../../features/opgi/presentation/pages/beban_penyulang_page.dart';
import '../../features/opgi/presentation/pages/input_beban_penyulang_page.dart';
import '../../features/opgi/presentation/pages/update_urutan_penyulang_page.dart';
import '../../features/opgi/presentation/pages/kwh_harian_page.dart';
import '../../features/opgi/presentation/pages/input_kwh_harian_page.dart';
import '../../features/opgi/presentation/pages/tegangan_trafo_page.dart';
import '../../features/opgi/presentation/pages/input_tegangan_trafo_page.dart';
import '../../features/opgi/presentation/pages/manuver_page.dart';
import '../../features/opgi/presentation/pages/input_manuver_page.dart';
import '../../features/opgi/presentation/pages/anomali_gi_page.dart';
import '../../features/opgi/presentation/pages/input_anomali_gi_page.dart';
import '../../features/opgi/presentation/pages/input_kondisi_anomali_gi_page.dart';
import '../../features/opgi/presentation/pages/il1_hub_page.dart';
import '../../features/opgi/presentation/pages/il1_kubikel_page.dart';
import '../../features/opgi/presentation/pages/input_il1_kubikel_page.dart';
import '../../features/opgi/presentation/pages/il1_trafo_ps_page.dart';
import '../../features/opgi/presentation/pages/input_il1_trafo_ps_page.dart';
import '../../features/opgi/presentation/pages/il1_sipil_page.dart';
import '../../features/opgi/presentation/pages/input_il1_sipil_page.dart';

import 'route_constants.dart';

/// Helper untuk menghubungkan Stream (Bloc) ke Listenable GoRouter
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: AppRoutes.splash,
    refreshListenable: GoRouterRefreshStream(sl<AuthBloc>().stream),
    debugLogDiagnostics: true,

    redirect: (BuildContext context, GoRouterState state) {
      final authState = sl<AuthBloc>().state;
      final bool isGoingToSplash = state.matchedLocation == AppRoutes.splash;
      final bool isGoingToLogin = state.matchedLocation == AppRoutes.login;

      // Izinkan SplashPage menampilkan animasinya
      if (isGoingToSplash) return null;

      if (authState is AuthAuthenticated) {
        if (isGoingToLogin) {
          return AppRoutes.home;
        }
        return null;
      }

      if (authState is AuthUnauthenticated || authState is AuthFailureState) {
        if (!isGoingToLogin) {
          return AppRoutes.login;
        }
        return null;
      }

      // Jika masih AuthInitial atau AuthLoading di luar splash, tahan route saat ini
      return null;
    },

    routes: [
      // 1. Splash Page
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),

      // 2. Login Page
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),

      // 3. Stateful Bottom Navigation Tabs (Home & Akun)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainScaffold(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Tab Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),

          // Branch 1: Tab Akun
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.akun,
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.absen,
        builder: (context, state) => const AbsenPage(),
      ),
      // Rute Pemrosesan Absensi (Liveness & Review)
      GoRoute(
        path: AppRoutes.absenProcessing,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return AbsenProcessingPage(
            type: extra['type'] as String? ?? 'MASUK',
            shiftData: extra['dataShift'] as Map<String, dynamic>?,
            absenLocation: extra['absenLocation'] as AbsenLocationEntity?,
          );
        },
      ),
      // Rute Ubah Password
      GoRoute(
        path: AppRoutes.ubahPassword,
        builder: (context, state) => const UbahPasswordPage(),
      ),
      // Rute Notifikasi
      GoRoute(
        path: AppRoutes.notification,
        builder: (context, state) => const NotificationPage(),
      ),
      // Rute Riwayat Absen
      GoRoute(
        path: AppRoutes.riwayatAbsen,
        builder: (context, state) => const RiwayatAbsenPage(),
      ),
      GoRoute(
        path: AppRoutes.riwayatAbsenDetail,
        builder: (context, state) {
          final item = state.extra as RiwayatAbsenItemModel;
          return RiwayatAbsenDetailPage(item: item);
        },
      ),
      GoRoute(
        path: AppRoutes.riwayatAbsenUpdate,
        builder: (context, state) {
          final item = state.extra as RiwayatAbsenItemModel;
          return RiwayatAbsenUpdatePage(item: item);
        },
      ),
      // Rute Data Shift
      GoRoute(
        path: AppRoutes.dataShift,
        builder: (context, state) => const DataShiftPage(),
      ),
      // Rute History Penilaian
      GoRoute(
        path: AppRoutes.historyPenilaian,
        builder: (context, state) => const HistoryPenilaianPage(),
      ),
      GoRoute(
        path: AppRoutes.detailHistoryPenilaian,
        builder: (context, state) {
          final item = state.extra as NilaiBulananItemModel;
          return DetailHistoryPenilaianPage(item: item);
        },
      ),

      // ─── Line Walker Routes ───
      // Waterpass
      GoRoute(
        path: AppRoutes.waterpass,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return BlocProvider<WaterpassCubit>(
            create: (_) => sl<WaterpassCubit>(),
            child: WaterpassFormPage(
              initialDraft: extra?['draft'] as Map<String, dynamic>?,
              draftId: extra?['draftId'] as int?,
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.riwayatWaterpassDetail,
        builder: (context, state) {
          final item = state.extra as WaterpassDetailModel;
          return RiwayatWaterpassDetailPage(item: item);
        },
      ),

      // Pembumian
      GoRoute(
        path: AppRoutes.pembumian,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return BlocProvider<PembumianCubit>(
            create: (_) => sl<PembumianCubit>(),
            child: PembumianFormPage(
              initialDraft: extra?['draft'] as Map<String, dynamic>?,
              draftId: extra?['draftId'] as int?,
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.summaryPembumian,
        builder: (context, state) => const SummaryPembumianPage(),
      ),
      GoRoute(
        path: AppRoutes.riwayatPembumian,
        builder: (context, state) => BlocProvider<PembumianCubit>(
          create: (_) => sl<PembumianCubit>(),
          child: const RiwayatPembumianPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.riwayatPembumianDetail,
        builder: (context, state) => RiwayatPembumianDetailPage(data: state.extra),
      ),

      // PPL
      GoRoute(
        path: AppRoutes.ppl,
        builder: (context, state) {
          final extra = state.extra;
          Map<String, dynamic>? initialData;
          int? draftId;
          if (extra is Map<String, dynamic>) {
            if (extra.containsKey('draft')) {
              initialData = extra['draft'] as Map<String, dynamic>?;
              draftId = extra['draftId'] as int?;
            } else if (extra.containsKey('item')) {
              initialData = extra['item'] as Map<String, dynamic>?;
              draftId = extra['draftId'] as int?;
            } else if (extra.containsKey('towerId') || extra.containsKey('namaPekerjaan') || extra.containsKey('id')) {
              initialData = extra;
            }
          }
          return BlocProvider<PplCubit>(
            create: (_) => sl<PplCubit>(),
            child: PplFormPage(
              initialDraft: initialData,
              draftId: draftId,
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.updatePpl,
        builder: (context, state) {
          final item = state.extra as Map<String, dynamic>;
          return BlocProvider<PplCubit>(
            create: (_) => sl<PplCubit>(),
            child: UpdatePPLPage(item: item),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.summaryRiwayatPpl,
        builder: (context, state) => BlocProvider<PplCubit>(
          create: (_) => sl<PplCubit>(),
          child: const SummaryRiwayatPPLPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.riwayatPpl,
        builder: (context, state) {
          final type = state.uri.queryParameters['type'];
          return BlocProvider<PplCubit>(
            create: (_) => sl<PplCubit>(),
            child: RiwayatPPLPage(type: type),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.riwayatPplList,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final identifier = state.uri.queryParameters['identifier'] ?? extra['identifier']?.toString() ?? '';
          return BlocProvider<PplCubit>(
            create: (_) => sl<PplCubit>(),
            child: RiwayatPPLListPage(
              identifier: identifier,
              namaPekerjaan: extra['namaPekerjaan']?.toString(),
              pihakPelaksana: extra['pihakPelaksana']?.toString(),
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.riwayatPplDetail,
        builder: (context, state) => RiwayatPPLDetailPage(data: state.extra),
      ),

      // Ketenagakerjaan
      GoRoute(
        path: AppRoutes.summaryKetenagakerjaan,
        builder: (context, state) => BlocProvider<KetenagakerjaanCubit>(
          create: (_) => sl<KetenagakerjaanCubit>(),
          child: const SummaryKetenagakerjaanPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.ketenagakerjaan,
        builder: (context, state) {
          final authState = sl<AuthBloc>().state;
          final currentUserId = authState is AuthAuthenticated ? authState.user.id : 0;
          final currentNama = authState is AuthAuthenticated ? authState.user.namaLengkap : null;

          final idParam = state.uri.queryParameters['id'];
          final parsedId = idParam != null ? int.tryParse(idParam) : null;
          final id = (parsedId != null && parsedId > 0) ? parsedId : currentUserId;
          final nama = state.uri.queryParameters['namaLengkap'] ?? currentNama;

          return BlocProvider<KetenagakerjaanCubit>(
            create: (_) => sl<KetenagakerjaanCubit>(),
            child: KetenagakerjaanPage(id: id, namaLengkap: nama),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.ketenagakerjaanDetail,
        builder: (context, state) {
          final item = state.extra as KetenagakerjaanItemModel;
          return KetenagakerjaanDetailPage(item: item);
        },
      ),

      // Kegiatan Sosial
      GoRoute(
        path: AppRoutes.kegiatanSosial,
        builder: (context, state) {
          final extra = state.extra;
          Map<String, dynamic>? initialData;
          int? draftId;
          if (extra is Map<String, dynamic>) {
            if (extra.containsKey('draft')) {
              initialData = extra['draft'] as Map<String, dynamic>?;
              draftId = extra['draftId'] as int?;
            } else if (extra.containsKey('item')) {
              initialData = extra['item'] as Map<String, dynamic>?;
              draftId = extra['draftId'] as int?;
            } else if (extra.containsKey('towerId') || extra.containsKey('jenisAktivitas') || extra.containsKey('id')) {
              initialData = extra;
            }
          }
          return BlocProvider<KegiatanSosialCubit>(
            create: (_) => sl<KegiatanSosialCubit>(),
            child: KegiatanSosialFormPage(
              initialDraft: initialData,
              draftId: draftId,
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.updateKegiatanSosial,
        builder: (context, state) {
          final item = state.extra as Map<String, dynamic>;
          return BlocProvider<KegiatanSosialCubit>(
            create: (_) => sl<KegiatanSosialCubit>(),
            child: UpdateKegiatanSosialPage(item: item),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.riwayatKegiatanSosial,
        builder: (context, state) => BlocProvider<KegiatanSosialCubit>(
          create: (_) => sl<KegiatanSosialCubit>(),
          child: const RiwayatKegiatanSosialPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.riwayatKegiatanSosialList,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final identifier = state.uri.queryParameters['identifier'] ?? extra['identifier']?.toString() ?? '';
          return BlocProvider<KegiatanSosialCubit>(
            create: (_) => sl<KegiatanSosialCubit>(),
            child: RiwayatKegiatanSosialListPage(identifier: identifier),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.riwayatKegiatanSosialDetail,
        builder: (context, state) => RiwayatKegiatanSosialDetailPage(data: state.extra),
      ),

      // ─────────────────────────────────────────────────────────────
      // DISTRIBUSI SUTM ROUTES
      // ─────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.workorderInspeksi,
        builder: (context, state) => BlocProvider<WoInspeksiCubit>(
          create: (_) => sl<WoInspeksiCubit>(),
          child: const WorkorderInspeksiPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.detailWorkorderToday,
        builder: (context, state) => DetailWorkorderTodayPage(
          workOrder: state.extra as SutmWorkOrderItem,
        ),
      ),
      GoRoute(
        path: AppRoutes.detailWorkorder,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return DetailWorkorderPage(
            workOrderId: extra['workOrderId']?.toString() ?? '',
          );
        },
      ),
      GoRoute(
        path: AppRoutes.ruteInspeksi,
        builder: (context, state) => BlocProvider<WoInspeksiCubit>(
          create: (_) => sl<WoInspeksiCubit>(),
          child: const RuteInspeksiPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.detailSutm,
        builder: (context, state) => BlocProvider<InspeksiFormCubit>(
          create: (_) => sl<InspeksiFormCubit>(),
          child: DetailSutmPage(params: state.extra as Map<String, dynamic>),
        ),
      ),
      GoRoute(
        path: AppRoutes.validasiInspeksi,
        builder: (context, state) => BlocProvider<ValidasiInspeksiCubit>(
          create: (_) => sl<ValidasiInspeksiCubit>(),
          child: const ValidasiInspeksiPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.validasiDetailWorkorder,
        builder: (context, state) => ValidasiDetailWorkorderPage(
          workOrder: state.extra as SutmWorkOrderItem,
        ),
      ),
      GoRoute(
        path: AppRoutes.riwayatInspeksi,
        builder: (context, state) => const RiwayatInspeksiPage(),
      ),

      // SUTM Pemeliharaan
      GoRoute(
        path: AppRoutes.workorderPemeliharaan,
        builder: (context, state) => BlocProvider<WoPemeliharaanCubit>(
          create: (_) => sl<WoPemeliharaanCubit>(),
          child: const WorkorderPemeliharaanPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.detailWorkorderPemeliharaanToday,
        builder: (context, state) => DetailWorkorderPemeliharaanTodayPage(
          workOrder: state.extra as SutmWorkOrderItem,
        ),
      ),
      GoRoute(
        path: AppRoutes.detailWorkorderPemeliharaan,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return DetailWorkorderPemeliharaanPage(
            workOrderId: extra['workOrderId']?.toString() ?? '',
          );
        },
      ),
      GoRoute(
        path: AppRoutes.rutePemeliharaan,
        builder: (context, state) => BlocProvider<WoPemeliharaanCubit>(
          create: (_) => sl<WoPemeliharaanCubit>(),
          child: const RutePemeliharaanPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.inspeksiPemeliharaanForm,
        builder: (context, state) => BlocProvider<PemeliharaanFormCubit>(
          create: (_) => sl<PemeliharaanFormCubit>(),
          child: InspeksiPemeliharaanFormPage(params: state.extra as Map<String, dynamic>),
        ),
      ),
      GoRoute(
        path: AppRoutes.validasiPemeliharaan,
        builder: (context, state) => const ValidasiPemeliharaanPage(),
      ),
      GoRoute(
        path: AppRoutes.riwayatPemeliharaan,
        builder: (context, state) => const RiwayatPemeliharaanPage(),
      ),

      // Yantek & Penilaian
      GoRoute(
        path: AppRoutes.inspeksiYantek,
        builder: (context, state) => BlocProvider<YantekCubit>(
          create: (_) => sl<YantekCubit>(),
          child: const InspeksiYantekPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.inspeksiYantekInspeksiForm,
        builder: (context, state) => BlocProvider<InspeksiFormCubit>(
          create: (_) => sl<InspeksiFormCubit>(),
          child: InspeksiYantekFormPage(params: state.extra as Map<String, dynamic>),
        ),
      ),
      GoRoute(
        path: AppRoutes.riwayatPenilaianInspeksi,
        builder: (context, state) => const RiwayatPenilaianInspeksiPage(),
      ),
      GoRoute(
        path: AppRoutes.riwayatPenilaianHar,
        builder: (context, state) => const RiwayatPenilaianHarPage(),
      ),

      // ─────────────────────────────────────────────────────────────
      // OPGI 20kV ROUTES
      // ─────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.garduInduk20kv,
        builder: (context, state) {
          final redirectPath = state.uri.queryParameters['redirectPath'] ??
              (state.extra as Map<String, dynamic>?)?['redirectPath'] as String?;
          return BlocProvider<GarduIndukCubit>(
            create: (_) => sl<GarduIndukCubit>(),
            child: GarduIndukHubPage(redirectPath: redirectPath),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.inputRealisasi,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return InputRealisasiHubPage(
            garduIndukId: extra['garduIndukId'] as int? ?? (extra['garduInduk'] as Map?)?['id'] as int? ?? 0,
            garduIndukNama: extra['garduIndukNama'] as String? ?? (extra['garduInduk'] as Map?)?['nama'] as String? ?? '-',
          );
        },
      ),
      GoRoute(
        path: AppRoutes.bebanTrafo,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return BlocProvider<OpgiRealisasiCubit>(
            create: (_) => sl<OpgiRealisasiCubit>(),
            child: BebanTrafoPage(
              garduIndukId: extra['garduIndukId'] as int? ?? 0,
              garduIndukNama: extra['garduIndukNama'] as String? ?? '-',
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.inputBebanTrafo,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return BlocProvider<OpgiRealisasiCubit>(
            create: (_) => sl<OpgiRealisasiCubit>(),
            child: InputBebanTrafoPage(
              garduIndukId: extra['garduIndukId'] as int? ?? 0,
              garduIndukNama: extra['garduIndukNama'] as String? ?? '-',
              date: extra['date'] as String? ?? '',
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.bebanPenyulang,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return BlocProvider<OpgiRealisasiCubit>(
            create: (_) => sl<OpgiRealisasiCubit>(),
            child: BebanPenyulangPage(
              garduIndukId: extra['garduIndukId'] as int? ?? 0,
              garduIndukNama: extra['garduIndukNama'] as String? ?? '-',
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.inputBebanPenyulang,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return BlocProvider<OpgiRealisasiCubit>(
            create: (_) => sl<OpgiRealisasiCubit>(),
            child: InputBebanPenyulangPage(
              garduIndukId: extra['garduIndukId'] as int? ?? 0,
              garduIndukNama: extra['garduIndukNama'] as String? ?? '-',
              date: extra['date'] as String? ?? '',
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.updateUrutanPenyulang,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return BlocProvider<OpgiRealisasiCubit>(
            create: (_) => sl<OpgiRealisasiCubit>(),
            child: UpdateUrutanPenyulangPage(
              garduIndukId: extra['garduIndukId'] as int? ?? 0,
              garduIndukNama: extra['garduIndukNama'] as String? ?? '-',
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.kwhHarian,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return BlocProvider<OpgiRealisasiCubit>(
            create: (_) => sl<OpgiRealisasiCubit>(),
            child: KwhHarianPage(
              garduIndukId: extra['garduIndukId'] as int? ?? 0,
              garduIndukNama: extra['garduIndukNama'] as String? ?? '-',
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.inputKwhHarian,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return BlocProvider<OpgiRealisasiCubit>(
            create: (_) => sl<OpgiRealisasiCubit>(),
            child: InputKwhHarianPage(
              garduIndukId: extra['garduIndukId'] as int? ?? 0,
              garduIndukNama: extra['garduIndukNama'] as String? ?? '-',
              date: extra['date'] as String? ?? '',
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.teganganTrafo,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return BlocProvider<OpgiRealisasiCubit>(
            create: (_) => sl<OpgiRealisasiCubit>(),
            child: TeganganTrafoPage(
              garduIndukId: extra['garduIndukId'] as int? ?? 0,
              garduIndukNama: extra['garduIndukNama'] as String? ?? '-',
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.inputTeganganTrafo,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return BlocProvider<OpgiRealisasiCubit>(
            create: (_) => sl<OpgiRealisasiCubit>(),
            child: InputTeganganTrafoPage(
              garduIndukId: extra['garduIndukId'] as int? ?? 0,
              garduIndukNama: extra['garduIndukNama'] as String? ?? '-',
              date: extra['date'] as String? ?? '',
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.manuver,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return BlocProvider<OpgiManuverCubit>(
            create: (_) => sl<OpgiManuverCubit>(),
            child: ManuverPage(
              garduIndukId: extra['garduIndukId'] as int? ?? (extra['garduInduk'] as Map?)?['id'] as int? ?? 0,
              garduIndukNama: extra['garduIndukNama'] as String? ?? (extra['garduInduk'] as Map?)?['nama'] as String? ?? '-',
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.inputManuver,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return BlocProvider<OpgiManuverCubit>(
            create: (_) => sl<OpgiManuverCubit>(),
            child: InputManuverPage(
              garduIndukId: extra['garduIndukId'] as int? ?? 0,
              garduIndukNama: extra['garduIndukNama'] as String? ?? '-',
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.anomaliGi,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return BlocProvider<OpgiAnomaliCubit>(
            create: (_) => sl<OpgiAnomaliCubit>(),
            child: AnomaliGiPage(
              garduIndukId: extra['garduIndukId'] as int? ?? (extra['garduInduk'] as Map?)?['id'] as int? ?? 0,
              garduIndukNama: extra['garduIndukNama'] as String? ?? (extra['garduInduk'] as Map?)?['nama'] as String? ?? '-',
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.inputAnomaliGi,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return BlocProvider<OpgiAnomaliCubit>(
            create: (_) => sl<OpgiAnomaliCubit>(),
            child: InputAnomaliGiPage(
              garduIndukId: extra['garduIndukId'] as int? ?? 0,
              garduIndukNama: extra['garduIndukNama'] as String? ?? '-',
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.inputKondisiAnomaliGi,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return BlocProvider<OpgiAnomaliCubit>(
            create: (_) => sl<OpgiAnomaliCubit>(),
            child: InputKondisiAnomaliGiPage(
              anomaliId: extra['anomaliId'] as int? ?? 0,
              assetNama: extra['assetNama'] as String? ?? '-',
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.il1,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return Il1HubPage(
            garduIndukId: extra['garduIndukId'] as int? ?? (extra['garduInduk'] as Map?)?['id'] as int? ?? 0,
            garduIndukNama: extra['garduIndukNama'] as String? ?? (extra['garduInduk'] as Map?)?['nama'] as String? ?? '-',
          );
        },
      ),
      GoRoute(
        path: AppRoutes.il1Kubikel,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return BlocProvider<OpgiIl1Cubit>(
            create: (_) => sl<OpgiIl1Cubit>(),
            child: Il1KubikelPage(
              garduIndukId: extra['garduIndukId'] as int? ?? 0,
              garduIndukNama: extra['garduIndukNama'] as String? ?? '-',
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.inputIl1Kubikel,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return BlocProvider<OpgiIl1Cubit>(
            create: (_) => sl<OpgiIl1Cubit>(),
            child: InputIl1KubikelPage(
              garduIndukId: extra['garduIndukId'] as int? ?? 0,
              garduIndukNama: extra['garduIndukNama'] as String? ?? '-',
              penyulangId: extra['penyulangId'] as int? ?? 0,
              penyulangNama: extra['penyulangNama'] as String? ?? '-',
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.il1TrafoPs,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return BlocProvider<OpgiIl1Cubit>(
            create: (_) => sl<OpgiIl1Cubit>(),
            child: Il1TrafoPsPage(
              garduIndukId: extra['garduIndukId'] as int? ?? 0,
              garduIndukNama: extra['garduIndukNama'] as String? ?? '-',
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.inputIl1TrafoPs,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return BlocProvider<OpgiIl1Cubit>(
            create: (_) => sl<OpgiIl1Cubit>(),
            child: InputIl1TrafoPsPage(
              garduIndukId: extra['garduIndukId'] as int? ?? 0,
              garduIndukNama: extra['garduIndukNama'] as String? ?? '-',
              trafoId: extra['trafoId'] as int? ?? 0,
              trafoNama: extra['trafoNama'] as String? ?? '-',
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.il1Sipil,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return BlocProvider<OpgiIl1Cubit>(
            create: (_) => sl<OpgiIl1Cubit>(),
            child: Il1SipilPage(
              garduIndukId: extra['garduIndukId'] as int? ?? 0,
              garduIndukNama: extra['garduIndukNama'] as String? ?? '-',
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.inputIl1Sipil,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return BlocProvider<OpgiIl1Cubit>(
            create: (_) => sl<OpgiIl1Cubit>(),
            child: InputIl1SipilPage(
              garduIndukId: extra['garduIndukId'] as int? ?? 0,
              garduIndukNama: extra['garduIndukNama'] as String? ?? '-',
              gedung: extra['gedung'] as String? ?? 'CELL',
              gedungNama: extra['gedungNama'] as String? ?? 'Gedung Kontrol',
            ),
          );
        },
      ),
    ],

    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Halaman tidak ditemukan: ${state.uri}')),
    ),
  );
}
