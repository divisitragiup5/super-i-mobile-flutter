import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/notification_repository.dart';
import 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationRepository repository;

  NotificationCubit(this.repository) : super(NotificationInitial());

  Future<void> fetchUnreadCount() async {
    final countResult = await repository.getUnreadCount();
    final int count = countResult.fold((_) => 0, (c) => c);
    final currentState = state;
    if (currentState is NotificationLoaded) {
      emit(currentState.copyWith(unreadCount: count));
    } else {
      emit(NotificationLoaded(items: const [], unreadCount: count));
    }
  }

  Future<void> fetchNotifications({bool? isRead}) async {
    emit(NotificationLoading());

    final countResult = await repository.getUnreadCount();
    final int unreadCount = countResult.fold((_) => 0, (count) => count);

    final result = await repository.getNotifications(isRead: isRead);
    result.fold(
      (failure) => emit(NotificationError(failure.message)),
      (data) => emit(
        NotificationLoaded(
          items: data.items,
          nextCursor: data.nextCursor,
          unreadCount: unreadCount,
          currentFilter: isRead,
        ),
      ),
    );
  }

  Future<void> loadMore() async {
    final currentState = state;
    if (currentState is! NotificationLoaded ||
        currentState.nextCursor == null ||
        currentState.isLoadingMore) {
      return;
    }

    emit(currentState.copyWith(isLoadingMore: true));

    final result = await repository.getNotifications(
      cursor: currentState.nextCursor,
      isRead: currentState.currentFilter,
    );

    result.fold(
      (failure) => emit(currentState.copyWith(isLoadingMore: false)),
      (data) => emit(
        currentState.copyWith(
          items: [...currentState.items, ...data.items],
          nextCursor: data.nextCursor,
          isLoadingMore: false,
        ),
      ),
    );
  }

  Future<void> markAllAsRead() async {
    final result = await repository.markAllAsRead();
    result.fold(
      (_) {},
      (_) {
        final currentState = state;
        if (currentState is NotificationLoaded) {
          final updatedItems = currentState.items.map((item) {
            return item;
          }).toList();
          emit(currentState.copyWith(unreadCount: 0, items: updatedItems));
        }
        bool? filter;
        if (state is NotificationLoaded) {
          filter = (state as NotificationLoaded).currentFilter;
        }
        fetchNotifications(isRead: filter);
      },
    );
  }
}
