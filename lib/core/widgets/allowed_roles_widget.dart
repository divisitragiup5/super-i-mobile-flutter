import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';

/// Widget yang hanya menampilkan anaknya (child) jika user yang login memiliki salah satu role yang diizinkan.
class AllowedRolesWidget extends StatelessWidget {
  final List<String> allowedRoles;
  final Widget child;

  const AllowedRolesWidget({
    super.key,
    required this.allowedRoles,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          final isAllowed = allowedRoles.any(
            (role) => state.user.roles.contains(role),
          );

          if (isAllowed) return child;
        }
        return const SizedBox.shrink(); // Sembunyikan total jika tidak berhak
      },
    );
  }
}
