import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final SecureStorageService secureStorage;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.secureStorage,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, UserEntity>> login({
    required String nip,
    required String password,
  }) async {
    // 1. Cek koneksi internet sebelum mengirim request
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      // 2. Tembak API login untuk mendapatkan access_token
      final token = await remoteDataSource.login(nip: nip, password: password);

      // 3. Simpan token ke brankas Keystore Android
      await secureStorage.saveAccessToken(token);

      // 4. Ambil profil lengkap petugas
      final userModel = await remoteDataSource.getUserProfile();

      return Right(userModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Terjadi kesalahan: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final userModel = await remoteDataSource.getUserProfile();
      return Right(userModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on UnauthorizedException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await secureStorage.deleteAccessToken();
      return const Right(null);
    } catch (e) {
      return const Left(
        CacheFailure(message: 'Gagal membersihkan sesi login.'),
      );
    }
  }
}
