import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/route_names.dart';
import '../models/notification_model.dart';
import '../providers/notification_provider.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  int _selectedFilter = 0; // 0: All, 1: Unread

  String _formatTimestamp(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays}d ago';
  }

  IconData _getIconForType(NotificationType type) {
    switch (type) {
      case NotificationType.bookingConfirmed:
        return Icons.check_circle_rounded;
      case NotificationType.bookingCancelled:
        return Icons.cancel_rounded;
      case NotificationType.reminder:
        return Icons.alarm_rounded;
      case NotificationType.offer:
        return Icons.local_offer_rounded;
      case NotificationType.alert:
        return Icons.campaign_rounded;
    }
  }

  Color _getColorForType(NotificationType type) {
    switch (type) {
      case NotificationType.bookingConfirmed:
        return AppColors.emerald;
      case NotificationType.bookingCancelled:
        return AppColors.error;
      case NotificationType.reminder:
        return const Color(0xFFF59E0B); // Amber
      case NotificationType.offer:
        return const Color(0xFF8B5CF6); // Purple
      case NotificationType.alert:
        return const Color(0xFF3B82F6); // Blue
    }
  }

  @override
  Widget build(BuildContext context) {
    final allNotifs = ref.watch(notificationsProvider);
    final unreadCount = ref.watch(unreadNotificationsCountProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final displayedNotifs = _selectedFilter == 1
        ? allNotifs.where((n) => !n.isRead).toList()
        : allNotifs;

    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = isDark
        ? const Color(0xFF1E293B)
        : Theme.of(context).cardColor;
    final textColor = isDark ? Colors.white : AppColors.navy;
    final subtextColor = isDark
        ? const Color(0xFF94A3B8)
        : AppColors.textSecondaryLight;
    final borderColor = isDark
        ? const Color(0xFF334155)
        : AppColors.borderLight;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: textColor,
            size: 20,
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.customerRoot);
            }
          },
        ),
        title: Text(
          'Notifications',
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          if (unreadCount > 0)
            TextButton.icon(
              icon: const Icon(Icons.done_all_rounded, size: 16),
              label: const Text('Mark all read'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.emerald,
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              onPressed: () {
                ref.read(notificationsProvider.notifier).markAllAsRead();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All notifications marked as read'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs (All / Unread)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'All (${allNotifs.length})',
                  index: 0,
                  isDark: isDark,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Unread ($unreadCount)',
                  index: 1,
                  isDark: isDark,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Notifications List
          Expanded(
            child: displayedNotifs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E293B)
                                : AppColors.surfaceSecondaryLight,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.notifications_off_outlined,
                            size: 38,
                            color: subtextColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _selectedFilter == 1
                              ? 'No unread notifications'
                              : 'No notifications yet',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'You\'re completely caught up!',
                          style: TextStyle(fontSize: 13, color: subtextColor),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: displayedNotifs.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final notif = displayedNotifs[index];
                      final typeColor = _getColorForType(notif.type);

                      return Dismissible(
                        key: ValueKey(notif.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.delete_outline_rounded,
                            color: AppColors.error,
                          ),
                        ),
                        onDismissed: (_) {
                          ref
                              .read(notificationsProvider.notifier)
                              .deleteNotification(notif.id);
                        },
                        child: InkWell(
                          onTap: () {
                            ref
                                .read(notificationsProvider.notifier)
                                .markAsRead(notif.id);
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: notif.isRead
                                  ? cardColor
                                  : (isDark
                                        ? const Color(0xFF162534)
                                        : const Color(0xFFF0FDF4)),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: notif.isRead
                                    ? borderColor
                                    : AppColors.emerald.withValues(alpha: 0.4),
                                width: notif.isRead ? 1 : 1.5,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Icon
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: typeColor.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    _getIconForType(notif.type),
                                    color: typeColor,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // Texts
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              notif.title,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: notif.isRead
                                                    ? FontWeight.w600
                                                    : FontWeight.w800,
                                                color: textColor,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            _formatTimestamp(notif.timestamp),
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: subtextColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        notif.body,
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          height: 1.35,
                                          color: notif.isRead
                                              ? subtextColor
                                              : (isDark
                                                    ? Colors.white70
                                                    : AppColors.navy),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                if (!notif.isRead) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: AppColors.emerald,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required int index,
    required bool isDark,
  }) {
    final isSelected = _selectedFilter == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.emerald
              : (isDark
                    ? const Color(0xFF1E293B)
                    : AppColors.surfaceSecondaryLight),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.white70 : AppColors.navy),
          ),
        ),
      ),
    );
  }
}
