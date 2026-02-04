import 'package:flutter/material.dart';
import '../services/notification_service.dart';

/// Badge widget that displays unread notification count
class NotificationBadge extends StatelessWidget {
  final String userId;
  final Widget child;
  
  const NotificationBadge({
    super.key,
    required this.userId,
    required this.child,
  });
  
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: NotificationService.instance.getUnreadCount(userId),
      builder: (context, snapshot) {
        final unreadCount = snapshot.data ?? 0;
        
        if (unreadCount == 0) {
          return child;
        }
        
        return Badge(
          label: Text(
            unreadCount > 99 ? '99+' : unreadCount.toString(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.red,
          child: child,
        );
      },
    );
  }
}
