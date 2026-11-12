import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/storage/local_database.dart';
import '../../../line_walker/domain/repositories/line_walker_repository.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final LogoutUseCase logoutUseCase;
  final LineWalkerRepository? lineWalkerRepository;

  AuthBloc({
    required this.loginUseCase,
    required this.getCurrentUserUseCase,
    required this.logoutUseCase,
    this.lineWalkerRepository,
  }) : super(AuthInitial()) {
    // Daftarkan handler untuk masing-masing event
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  /// Handler ketika tombol login ditekan
  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await loginUseCase(
      LoginParams(nip: event.nip, password: event.password),
    );

    // .fold() dari fpdart membedah hasil Either:
    // (kiri = failure, kanan = user)
    await result.fold(
      (failure) async => emit(AuthFailureState(failure.message)),
      (user) async {
        // Bersihkan cache API lama agar data segar milik user ini yang dimuat
        await LocalDatabase.instance.clearApiCache();
        emit(AuthAuthenticated(user));
        // Prefetch seluruh tower/objek Line Walker di background hanya untuk user Line Walker
        if (user.canAccessLineWalkerTower) {
          unawaited(lineWalkerRepository?.prefetchTowers() ?? Future.value());
        }
      },
    );
  }

  /// Handler pengecekan sesi aktif (misal saat splash screen)
  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await getCurrentUserUseCase();

    result.fold(
      (failure) => emit(AuthUnauthenticated()),
      (user) {
        emit(AuthAuthenticated(user));
        // Prefetch seluruh tower/objek Line Walker di background hanya untuk user Line Walker
        if (user.canAccessLineWalkerTower) {
          unawaited(lineWalkerRepository?.prefetchTowers() ?? Future.value());
        }
      },
    );
  }

  /// Handler logout
  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    await logoutUseCase();
    // Bersihkan seluruh cache API saat user logout
    await LocalDatabase.instance.clearApiCache();
    emit(AuthUnauthenticated());
  }
}
