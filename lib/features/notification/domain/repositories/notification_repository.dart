import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../../data/models/notification_model.dart';

abstract class NotificationRepository {
  Future<Either<Failure, int>> getUnreadCount();

  Future<Either<Failure, NotificationListModel>> getNotifications({
    int? cursor,
    bool? isRead,
  });

  Future<Either<Failure, bool>> markAllAsRead();
}
