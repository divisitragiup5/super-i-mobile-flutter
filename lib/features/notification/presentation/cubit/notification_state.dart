import 'package:equatable/equatable.dart';
import '../../data/models/notification_model.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<NotificationItemModel> items;
  final int? nextCursor;
  final int unreadCount;
  final bool? currentFilter; // null = semua, false = belum dibaca
  final bool isLoadingMore;

  const NotificationLoaded({
    required this.items,
    this.nextCursor,
    required this.unreadCount,
    this.currentFilter,
    this.isLoadingMore = false,
  });

  NotificationLoaded copyWith({
    List<NotificationItemModel>? items,
    int? nextCursor,
    int? unreadCount,
    bool? currentFilter,
    bool? isLoadingMore,
  }) {
    return NotificationLoaded(
      items: items ?? this.items,
      nextCursor: nextCursor,
      unreadCount: unreadCount ?? this.unreadCount,
      currentFilter: currentFilter ?? this.currentFilter,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [items, nextCursor, unreadCount, currentFilter, isLoadingMore];
}

class NotificationError extends NotificationState {
  final String message;

  const NotificationError(this.message);

  @override
  List<Object?> get props => [message];
}
