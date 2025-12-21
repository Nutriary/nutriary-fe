import '../../domain/entities/notification.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.title,
    required super.body,
    required super.isRead,
    required super.createdAt,
    super.data,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    // Backend returns 'message' field, we split for title/body or use full message
    final message = json['message'] ?? '';

    return NotificationModel(
      id: json['id'],
      title: 'Thông báo', // Default title since backend only has message
      body: message,
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      data: json['data'],
    );
  }
}
