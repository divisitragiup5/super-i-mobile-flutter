import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _nipController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nipController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    final nip = _nipController.text.trim();
    final password = _passwordController.text;

    if (nip.isEmpty || password.isEmpty) {
      AppSnackbar.showWarning(context, 'NIP dan Password tidak boleh kosong!');
      return;
    }

    // Tutup keyboard saat tombol ditekan
    FocusScope.of(context).unfocus();

    context.read<AuthBloc>().add(
      AuthLoginRequested(nip: nip, password: password),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailureState) {
            AppSnackbar.showError(context, state.message);
          } else if (state is AuthAuthenticated) {
            AppSnackbar.showSuccess(
              context,
              'Selamat bertugas, ${state.user.namaLengkap}!',
            );
            context.go(AppRoutes.home);
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SafeArea(
            bottom: false,
            child: Column(
              children: [
                // ─────────────────────────────────────────────────────────────
                // BAGIAN ATAS: LOGO GAMA DENGAN BACKGROUND TEAL PRIMARY
                // ─────────────────────────────────────────────────────────────
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0),
                      child: Image.asset(
                        'assets/images/splash-icon-light.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                              Icons.bolt,
                              size: 90,
                              color: Colors.white,
                            ),
                      ),
                    ),
                  ),
                ),

                // ─────────────────────────────────────────────────────────────
                // BAGIAN BAWAH: WHITE CARD BOTTOM SHEET (ROUNDED TOP 3XL)
                // ─────────────────────────────────────────────────────────────
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 16,
                        offset: Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                      left: 24,
                      right: 24,
                      top: 24,
                      // Otomatis memberi ruang saat keyboard Android terbuka
                      bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header Judul
                        const Text(
                          'Masuk untuk Bertugas',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Divider(color: AppColors.border, height: 1),
                        const SizedBox(height: 24),

                        // Input NIP
                        AppTextField(
                          label: 'NIP',
                          hint: 'Masukkan NIP',
                          controller: _nipController,
                          // keyboardType: TextInputType.number,
                          prefixIcon: const Icon(
                            Icons.badge_outlined,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Input Password
                        AppTextField(
                          label: 'Password',
                          hint: 'Masukkan password',
                          controller: _passwordController,
                          isPassword: true,
                          prefixIcon: const Icon(
                            Icons.lock_outline,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Tombol Masuk
                        AppButton(
                          text: 'Masuk',
                          isLoading: isLoading,
                          onPressed: _onLoginPressed,
                        ),
                        const SizedBox(height: 16),

                        // Versi Aplikasi (Persis project lama)
                        const Text(
                          'GAMA v5.3.0',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDisabled,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
