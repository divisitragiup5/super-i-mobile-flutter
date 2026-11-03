import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Future<int> getUnreadCount();

  Future<NotificationListModel> getNotifications({
    int? cursor,
    bool? isRead,
  });

  Future<bool> markAllAsRead();
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final DioClient dioClient;

  NotificationRemoteDataSourceImpl(this.dioClient);

  @override
  Future<int> getUnreadCount() async {
    try {
      final response = await dioClient.dio.get('/notification/unread-count');
      final data = response.data;
      if (data != null && data['data'] != null && data['data']['count'] != null) {
        return data['data']['count'] as int;
      }
      return 0;
    } on DioException catch (e) {
      throw dioClient.handleError(e);
    }
  }

  @override
  Future<NotificationListModel> getNotifications({
    int? cursor,
    bool? isRead,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (cursor != null) queryParams['cursor'] = cursor;
      if (isRead != null) queryParams['isRead'] = isRead;

      final response = await dioClient.dio.get(
        '/notification',
        queryParameters: queryParams,
      );

      final data = response.data;
      if (data != null && data['data'] != null) {
        return NotificationListModel.fromJson(
          data['data'] as Map<String, dynamic>,
        );
      }
      return const NotificationListModel(items: []);
    } on DioException catch (e) {
      throw dioClient.handleError(e);
    }
  }

  @override
  Future<bool> markAllAsRead() async {
    try {
      final response = await dioClient.dio.patch('/notification/read-all');
      final data = response.data;
      return data != null && data['success'] == true;
    } on DioException catch (e) {
      throw dioClient.handleError(e);
    }
  }
}
