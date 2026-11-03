import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/ubah_password_repository.dart';
import 'ubah_password_state.dart';

class UbahPasswordCubit extends Cubit<UbahPasswordState> {
  final UbahPasswordRepository repository;

  UbahPasswordCubit(this.repository) : super(UbahPasswordInitial());

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    emit(UbahPasswordLoading());
    final result = await repository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );

    result.fold(
      (failure) => emit(UbahPasswordError(failure.message)),
      (message) => emit(UbahPasswordSuccess(message)),
    );
  }
}
