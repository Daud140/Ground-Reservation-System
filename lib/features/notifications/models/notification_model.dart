enum NotificationType {
  bookingConfirmed,
  bookingCancelled,
  reminder,
  offer,
  alert;

  String get displayName {
    switch (this) {
      case NotificationType.bookingConfirmed:
        return 'Booking Confirmed';
      case NotificationType.bookingCancelled:
        return 'Booking Cancelled';
      case NotificationType.reminder:
        return 'Match Reminder';
      case NotificationType.offer:
        return 'Special Offer';
      case NotificationType.alert:
        return 'Venue Update';
    }
  }
}

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;
  final String? bookingId;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.bookingId,
  });

  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    DateTime? timestamp,
    bool? isRead,
    String? bookingId,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      bookingId: bookingId ?? this.bookingId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'bookingId': bookingId,
    };
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      type: NotificationType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => NotificationType.alert,
      ),
      timestamp:
          DateTime.tryParse(json['timestamp'] as String? ?? '') ??
          DateTime.now(),
      isRead: json['isRead'] as bool? ?? false,
      bookingId: json['bookingId'] as String?,
    );
  }
}
