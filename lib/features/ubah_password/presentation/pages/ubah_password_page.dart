import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../cubit/ubah_password_cubit.dart';
import '../cubit/ubah_password_state.dart';

class UbahPasswordPage extends StatefulWidget {
  const UbahPasswordPage({super.key});

  @override
  State<UbahPasswordPage> createState() => _UbahPasswordPageState();
}

class _UbahPasswordPageState extends State<UbahPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  void _onSubmit(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<UbahPasswordCubit>().changePassword(
            currentPassword: _currentPasswordController.text.trim(),
            newPassword: _newPasswordController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<UbahPasswordCubit>(),
      child: BlocConsumer<UbahPasswordCubit, UbahPasswordState>(
        listener: (context, state) {
          if (state is UbahPasswordSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
            Navigator.pop(context);
          } else if (state is UbahPasswordError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.danger,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is UbahPasswordLoading;

          return Scaffold(
            appBar: AppBar(
              title: const Text('Ubah Password'),
              centerTitle: true,
            ),
            body: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/background.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.backgroundLight,
                    ),
                  ),
                ),
                SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(10),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Password Sekarang',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _currentPasswordController,
                                obscureText: _obscureCurrent,
                                decoration: InputDecoration(
                                  hintText: 'Masukkan password sekarang',
                                  filled: true,
                                  fillColor: const Color(0xFFF8FAFC),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFCBD5E1),
                                    ),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureCurrent
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () => setState(
                                      () => _obscureCurrent = !_obscureCurrent,
                                    ),
                                  ),
                                ),
                                validator: (val) {
                                  if (val == null || val.isEmpty) {
                                    return 'Password sekarang wajib diisi';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Password Baru',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _newPasswordController,
                                obscureText: _obscureNew,
                                decoration: InputDecoration(
                                  hintText: 'Masukkan password baru',
                                  filled: true,
                                  fillColor: const Color(0xFFF8FAFC),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFCBD5E1),
                                    ),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureNew
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () => setState(
                                      () => _obscureNew = !_obscureNew,
                                    ),
                                  ),
                                ),
                                validator: (val) {
                                  if (val == null || val.isEmpty) {
                                    return 'Password baru wajib diisi';
                                  }
                                  if (val.length < 8) {
                                    return 'Password baru minimal 8 karakter';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        AppButton(
                          text: 'Ubah Password',
                          isLoading: isLoading,
                          onPressed: () => _onSubmit(context),
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
