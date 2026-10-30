import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          context.go(AppRoutes.login);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Akun'), centerTitle: true),
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is! AuthAuthenticated) {
              return const Center(child: CircularProgressIndicator());
            }

            final user = state.user;

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

                // 2. Konten Profil
                SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  child: Column(
                    children: [
                      // Avatar Profil Bulat dengan Badge Kamera
                      Center(
                        child: Stack(
                          children: [
                            Container(
                              width: 110,
                              height: 110,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child:
                                    user.picture != null &&
                                        user.picture!.isNotEmpty
                                    ? Image.network(
                                        user.picture!,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                _buildAvatarFallback(
                                                  user.namaLengkap,
                                                ),
                                      )
                                    : _buildAvatarFallback(user.namaLengkap),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ─── KARTU 1: DATA PRIBADI ───
                      _buildSectionHeader('DATA PRIBADI'),
                      const SizedBox(height: 8),
                      Card(
                        color: Colors.white.withOpacity(0.92),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              _buildInfoRow('NIP', user.nip),
                              const Divider(height: 20),
                              _buildInfoRow('Nama Lengkap', user.namaLengkap),
                              if (user.noTelepon.isNotEmpty) ...[
                                const Divider(height: 20),
                                _buildInfoRow('No Telepon', user.noTelepon),
                              ],
                              const Divider(height: 20),
                              _buildInfoRow('Role', user.roles.join(', ')),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ─── KARTU 2: PENGATURAN ───
                      _buildSectionHeader('PENGATURAN'),
                      const SizedBox(height: 8),
                      Card(
                        color: Colors.white.withOpacity(0.92),
                        child: ListTile(
                          leading: const Icon(
                            Icons.lock_outline,
                            color: AppColors.primary,
                          ),
                          title: const Text(
                            'Ubah Password',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          trailing: const Icon(
                            Icons.chevron_right,
                            color: AppColors.textSecondary,
                          ),
                          onTap: () {
                            AppSnackbar.showInfo(
                              context,
                              'Halaman Ubah Password segera hadir.',
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Tombol Logout
                      AppButton(
                        text: 'Logout',
                        variant: ButtonVariant.danger,
                        icon: Icons.logout,
                        onPressed: () => _showLogoutDialog(context),
                      ),
                      const SizedBox(height: 16),

                      // Badge Versi Aplikasi (Persis Legacy)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'GAMA v5.3.0',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAvatarFallback(String name) {
    return Container(
      color: AppColors.primaryLight,
      alignment: Alignment.center,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'U',
        style: const TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 1.0,
          shadows: [
            Shadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 1)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
