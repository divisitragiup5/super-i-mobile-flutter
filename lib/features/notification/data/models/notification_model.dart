class NotificationItemModel {
  final int id;
  final String type;
  final String title;
  final String message;
  final Map<String, dynamic>? data;
  final bool isRead;
  final String? readAt;
  final DateTime createdAt;

  const NotificationItemModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    this.data,
    required this.isRead,
    this.readAt,
    required this.createdAt,
  });

  factory NotificationItemModel.fromJson(Map<String, dynamic> json) {
    return NotificationItemModel(
      id: json['id'] as int? ?? 0,
      type: json['type'] as String? ?? 'GENERAL',
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      data: json['data'] is Map<String, dynamic>
          ? json['data'] as Map<String, dynamic>
          : null,
      isRead: json['isRead'] as bool? ?? false,
      readAt: json['readAt'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class NotificationListModel {
  final List<NotificationItemModel> items;
  final int? nextCursor;

  const NotificationListModel({
    required this.items,
    this.nextCursor,
  });

  factory NotificationListModel.fromJson(Map<String, dynamic> json) {
    final rawList = json['items'] as List<dynamic>? ?? [];
    return NotificationListModel(
      items: rawList
          .map((item) =>
              NotificationItemModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      nextCursor: json['nextCursor'] as int?,
    );
  }
}
