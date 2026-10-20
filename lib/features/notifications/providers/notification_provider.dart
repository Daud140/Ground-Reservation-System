import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/local_storage_service.dart';
import '../models/notification_model.dart';

/// Riverpod notifier managing notifications list with Hive persistence and live unread counting
class NotificationNotifier extends Notifier<List<NotificationModel>> {
  @override
  List<NotificationModel> build() {
    final rawList = LocalStorageService.instance.getRawNotifications();
    if (rawList.isNotEmpty) {
      return rawList.map((m) => NotificationModel.fromJson(m)).toList();
    }

    // Default Seed Notifications if fresh install / first run
    final seed = [
      NotificationModel(
        id: 'notif_1',
        title: 'Booking Confirmed! ⚽',
        body: 'Your slot at Islamabad Arena (Main Turf) is locked for 6:00 PM - 7:00 PM today.',
        type: NotificationType.bookingConfirmed,
        timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
        isRead: false,
        bookingId: 'GZ-789254',
      ),
      NotificationModel(
        id: 'notif_2',
        title: 'Match Day Reminder ⏰',
        body: 'Friendly match starts in 2 hours. Tap to view directions and ground amenities.',
        type: NotificationType.reminder,
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        isRead: false,
      ),
      NotificationModel(
        id: 'notif_3',
        title: 'Weekend 20% Off Promo 🎉',
        body: 'Use code TURF20 to get PKR 600 off any floodlit cricket turf booking this weekend.',
        type: NotificationType.offer,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
      ),
      NotificationModel(
        id: 'notif_4',
        title: 'New Venue Added in F-8 🌟',
        body: 'KickOff Arena F-8 is now live on GroundZero with FIFA-grade synthetic turf.',
        type: NotificationType.alert,
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        isRead: true,
      ),
    ];

    _persist(seed);
    return seed;
  }

  void _persist(List<NotificationModel> list) {
    LocalStorageService.instance.saveRawNotifications(
      list.map((n) => n.toJson()).toList(),
    );
  }

  void addNotification({
    required String title,
    required String body,
    required NotificationType type,
    String? bookingId,
  }) {
    final newNotif = NotificationModel(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      body: body,
      type: type,
      timestamp: DateTime.now(),
      isRead: false,
      bookingId: bookingId,
    );

    final updated = [newNotif, ...state];
    state = updated;
    _persist(updated);
  }

  void markAsRead(String id) {
    final updated = state.map((n) {
      if (n.id == id) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();
    state = updated;
    _persist(updated);
  }

  void markAllAsRead() {
    final updated = state.map((n) => n.copyWith(isRead: true)).toList();
    state = updated;
    _persist(updated);
  }

  void deleteNotification(String id) {
    final updated = state.where((n) => n.id != id).toList();
    state = updated;
    _persist(updated);
  }

  void clearAll() {
    state = [];
    _persist([]);
  }
}

final notificationsProvider =
    NotifierProvider<NotificationNotifier, List<NotificationModel>>(
      NotificationNotifier.new,
    );

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notifs = ref.watch(notificationsProvider);
  return notifs.where((n) => !n.isRead).length;
});
