import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

/// Kontrak repository autentikasi.
/// Semua method mengembalikan Either`<`Failure, SuccessData`>` agar penanganan error eksplisit.
abstract class AuthRepository {
  /// Melakukan login ke server dengan NIP dan Password,
  /// lalu menyimpan token ke SecureStorage dan mengembalikan data User.
  Future<Either<Failure, UserEntity>> login({
    required String nip,
    required String password,
  });

  /// Mengambil profil user yang sedang login dari /data/user/me
  Future<Either<Failure, UserEntity>> getCurrentUser();

  /// Menghapus sesi login (token di storage)
  Future<Either<Failure, void>> logout();
}