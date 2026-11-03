import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/ubah_password_repository.dart';
import '../datasources/ubah_password_remote_data_source.dart';

class UbahPasswordRepositoryImpl implements UbahPasswordRepository {
  final UbahPasswordRemoteDataSource remoteDataSource;

  UbahPasswordRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, String>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final message = await remoteDataSource.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return Right(message);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
