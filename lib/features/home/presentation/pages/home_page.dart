import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/role_constants.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/allowed_roles_widget.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../../core/di/injection_container.dart';
import '../cubit/sutm_inspeksi_score_cubit.dart';
import '../cubit/sutm_pemeliharaan_score_cubit.dart';
import '../models/menu_item_model.dart';
import '../widgets/home_header.dart';
import '../widgets/menu_card.dart';
import '../widgets/summaries/line_walker_performance_card.dart';
import '../widgets/summaries/offline_drafts_card.dart';
import '../widgets/summaries/opgi_score_summary_card.dart';
import '../widgets/summaries/ppl_summary_card.dart';
import '../widgets/summaries/sutm_inspeksi_score_card.dart';
import '../widgets/summaries/sutm_pemeliharaan_score_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Konfirmasi Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              context.read<AuthBloc>().add(AuthLogoutRequested());
            },
            child: const Text(
              'Keluar',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<SutmInspeksiScoreCubit>()..fetchScore(),
        ),
        BlocProvider(
          create: (_) => sl<SutmPemeliharaanScoreCubit>()..fetchScore(),
        ),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            context.go(AppRoutes.login);
          }
        },
        child: Scaffold(
          body: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is! AuthAuthenticated) {
                return const Center(child: CircularProgressIndicator());
              }

              final user = state.user;

              // Filter menu sesuai roles user
              final allowedMenus = MenuItemModel.allMenus.where((menu) {
                return menu.allowedRoles.any((role) => user.roles.contains(role));
              }).toList();

              return Stack(
                children: [
                  // 1. Wallpaper background.jpg
                  Positioned.fill(
                    child: Image.asset(
                      'assets/images/background.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(color: AppColors.backgroundLight),
                    ),
                  ),

                  // 2. Konten Scrollable Dashboard
                  Column(
                    children: [
                      // Header Melengkung
                      HomeHeader(
                        user: user,
                        onLogout: () => _showLogoutDialog(context),
                      ),

                      // Area Scroll
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async {
                            context.read<AuthBloc>().add(AuthCheckRequested());
                            context.read<SutmInspeksiScoreCubit>().fetchScore();
                            context.read<SutmPemeliharaanScoreCubit>().fetchScore();
                          },
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ─── 1. KINERJA LINE WALKER (ARSAKHA) ───
                                const AllowedRolesWidget(
                                  allowedRoles: [
                                    AppRoles.petugasLineWalker,
                                    AppRoles.koordinatorLineWalker,
                                  ],
                                  child: LineWalkerPerformanceCard(),
                                ),

                                // ─── 2. KINERJA OPGI 20KV (3 GAUGE) ───
                                const AllowedRolesWidget(
                                  allowedRoles: [
                                    AppRoles.operatorGi20kv,
                                    AppRoles.timHar20kv,
                                    AppRoles.timHarPromet20kv,
                                    AppRoles.k3Har20kv,
                                  ],
                                  child: OpgiScoreSummaryCard(),
                                ),

                                // ─── 3. MONITORING PPL ───
                                const AllowedRolesWidget(
                                  allowedRoles: [
                                    AppRoles.teamLeaderGi,
                                    AppRoles.viewerPlnUit,
                                    AppRoles.viewerPlnUpt,
                                    AppRoles.viewerPlnUltg,
                                  ],
                                  child: PplSummaryCard(),
                                ),

                                // ─── 4. KINERJA INSPEKSI SUTM ───
                                const AllowedRolesWidget(
                                  allowedRoles: [AppRoles.petugasInspeksiSutm],
                                  child: SutmInspeksiScoreCard(),
                                ),

                                // ─── 5. KINERJA PEMELIHARAAN SUTM ───
                                const AllowedRolesWidget(
                                  allowedRoles: [
                                    AppRoles.petugasPemeliharaanSutm,
                                  ],
                                  child: SutmPemeliharaanScoreCard(),
                                ),

                              // ─── 6. MENU OPERASIONAL DINAMIS ───
                              const Text(
                                'Menu Operasional',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black54,
                                      blurRadius: 4,
                                      offset: Offset(0, 1),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),

                              allowedMenus.isEmpty
                                  ? Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.9),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          'Tidak ada menu yang tersedia untuk hak akses Anda saat ini.',
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    )
                                  : GridView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 3,
                                            crossAxisSpacing: 12,
                                            mainAxisSpacing: 12,
                                            childAspectRatio: 1.0,
                                          ),
                                      itemCount: allowedMenus.length,
                                      itemBuilder: (context, index) {
                                        return MenuCard(
                                          item: allowedMenus[index],
                                        );
                                      },
                                    ),
                              const SizedBox(height: 24),

                              // ─── 7. DRAFT BELUM TERSIMPAN (HORIZONTAL DI BAWAH MENU) ───
                              const AllowedRolesWidget(
                                allowedRoles: [
                                  AppRoles.petugasLineWalker,
                                  AppRoles.koordinatorLineWalker,
                                ],
                                child: OfflineDraftsCard(),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    ),
  );
}
}
