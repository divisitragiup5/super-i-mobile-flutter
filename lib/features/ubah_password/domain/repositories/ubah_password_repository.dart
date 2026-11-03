import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';

abstract class UbahPasswordRepository {
  Future<Either<Failure, String>> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}
