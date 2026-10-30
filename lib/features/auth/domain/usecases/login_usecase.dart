import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call(LoginParams params) async {
    return await repository.login(nip: params.nip, password: params.password);
  }
}

/// Parameter yang dibutuhkan untuk login
class LoginParams extends Equatable {
  final String nip;
  final String password;

  const LoginParams({required this.nip, required this.password});

  @override
  List<Object?> get props => [nip, password];
}
