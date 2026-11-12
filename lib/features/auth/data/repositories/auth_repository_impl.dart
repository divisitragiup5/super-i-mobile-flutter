import 'dart:convert';

import 'package:fpdart/fpdart.dart';

import '../../../../core/constants/storage_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/storage/preferences_service.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final SecureStorageService secureStorage;
  final PreferencesService preferencesService;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.secureStorage,
    required this.preferencesService,
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
      // 2. Tembak API login
      final loginData = await remoteDataSource.login(
        nip: nip,
        password: password,
      );
      final accessToken = loginData['access_token']?.toString() ?? '';
      final refreshToken = loginData['refresh_token']?.toString();

      // 3. Simpan access_token dan refresh_token
      await secureStorage.saveAccessToken(accessToken);
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await secureStorage.saveRefreshToken(refreshToken);
      }

      // 4. Ambil profil lengkap petugas
      final userModel = await remoteDataSource.getUserProfile();

      // 5. Simpan cache profil user untuk keperluan offline di lapangan
      await preferencesService.setString(
        StorageConstants.userProfile,
        jsonEncode(userModel.toJson()),
      );

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
    final token = await secureStorage.getAccessToken();
    if (token == null || token.isEmpty) {
      await _clearSession();
      return const Left(
        AuthFailure(message: 'Sesi belum ada atau telah berakhir.'),
      );
    }

    final isConnected = await networkInfo.isConnected;
    if (isConnected) {
      try {
        final userModel = await remoteDataSource.getUserProfile();
        // Update cache offline dengan data terbaru
        await preferencesService.setString(
          StorageConstants.userProfile,
          jsonEncode(userModel.toJson()),
        );
        return Right(userModel);
      } on UnauthorizedException catch (e) {
        // Token hangus di server (401)
        await _clearSession();
        return Left(AuthFailure(message: e.message));
      } catch (e) {
        // Jika server error atau timeout, coba ambil dari cache offline
        final cached = _getCachedUser();
        if (cached != null) {
          return Right(cached);
        }
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      // Offline mode: Ambil dari cache lokal jika pernah login
      final cached = _getCachedUser();
      if (cached != null) {
        return Right(cached);
      }
      return const Left(
        NetworkFailure(
          message: 'Tidak ada koneksi internet dan sesi lokal belum tersedia.',
        ),
      );
    }
  }

  UserModel? _getCachedUser() {
    final raw = preferencesService.getString(StorageConstants.userProfile);
    if (raw != null && raw.isNotEmpty) {
      try {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        return UserModel.fromJson(map);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  Future<void> _clearSession() async {
    try {
      await secureStorage.deleteAccessToken();
      await secureStorage.deleteRefreshToken();
    } catch (_) {}
    try {
      await preferencesService.remove(StorageConstants.userProfile);
    } catch (_) {}
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _clearSession();
      return const Right(null);
    } catch (e) {
      return const Left(
        CacheFailure(message: 'Gagal membersihkan sesi login.'),
      );
    }
  }
}
