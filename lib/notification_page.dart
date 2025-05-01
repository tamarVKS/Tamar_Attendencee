import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatefulWidget {
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<NotificationItem> notifications = [
    NotificationItem(
      id: '1',
      title: 'Leave Approval',
      content: 'Your leave request for June 15-17 has been approved!',
      time: DateTime.now().subtract(Duration(hours: 2)),
      isRead: false,
      type: NotificationType.approval,
    ),
    NotificationItem(
      id: '2',
      title: 'New Announcement',
      content: 'Company picnic scheduled for July 10th at Central Park',
      time: DateTime.now().subtract(Duration(days: 1)),
      isRead: true,
      type: NotificationType.announcement,
    ),
    NotificationItem(
      id: '3',
      title: 'Reminder',
      content: 'Don\'t forget to submit your timesheet by Friday',
      time: DateTime.now().subtract(Duration(days: 2)),
      isRead: true,
      type: NotificationType.reminder,
    ),
    NotificationItem(
      id: '4',
      title: 'System Update',
      content: 'New attendance system features available next week',
      time: DateTime.now().subtract(Duration(days: 3)),
      isRead: false,
      type: NotificationType.system,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.checklist_rounded, color: Colors.white),
            tooltip: 'Mark all as read',
            onPressed: _markAllAsRead,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            tooltip: 'Clear all',
            onPressed: _clearAllNotifications,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  _buildFilterChip('All', true),
                  const SizedBox(width: 8),
                  _buildFilterChip('Unread', false),
                  const SizedBox(width: 8),
                  _buildFilterChip('Important', false),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshNotifications,
                color: Color(0xFFFFD700),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return Dismissible(
                      key: Key(notification.id),
                      background: _buildDismissibleBackground(),
                      secondaryBackground: _buildDismissibleBackground(isDelete: true),
                      confirmDismiss: (direction) async {
                        if (direction == DismissDirection.endToStart) {
                          return await _showDeleteConfirmation(notification);
                        }
                        return false;
                      },
                      onDismissed: (direction) {
                        if (direction == DismissDirection.startToEnd) {
                          _markAsRead(notification);
                        }
                      },
                      child: GestureDetector(
                        onTap: () => _showNotificationDetails(notification),
                        child: NotificationCard(
                          notification: notification,
                          onAction: (action) => _handleNotificationAction(action, notification),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        // Implement filter logic
      },
      selectedColor: Color(0xFFFFD700),
      checkmarkColor: Colors.black,
      labelStyle: TextStyle(
        color: isSelected ? Colors.black : Colors.white,
      ),
      backgroundColor: Colors.transparent,
      shape: StadiumBorder(side: BorderSide(color: Colors.white54)),
    );
  }

  Widget _buildDismissibleBackground({bool isDelete = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: isDelete ? Colors.red[400] : Colors.green[400],
        borderRadius: BorderRadius.circular(20),
      ),
      alignment: isDelete ? Alignment.centerRight : Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Icon(
        isDelete ? Icons.delete : Icons.mark_email_read,
        color: Colors.white,
        size: 30,
      ),
    );
  }

  Future<bool> _showDeleteConfirmation(NotificationItem notification) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Notification'),
        content: Text('Are you sure you want to delete this notification?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                notifications.removeWhere((n) => n.id == notification.id);
              });
              Navigator.of(context).pop(true);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Notification deleted'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshNotifications() async {
    // Simulate network request
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      // In a real app, you would fetch new notifications here
    });
  }

  void _markAllAsRead() {
    setState(() {
      notifications.forEach((notification) {
        notification.isRead = true;
      });
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('All notifications marked as read'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _clearAllNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear All Notifications'),
        content: Text('Are you sure you want to clear all notifications?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                notifications.clear();
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('All notifications cleared'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: Text('Clear All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _markAsRead(NotificationItem notification) {
    setState(() {
      notification.isRead = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Marked as read'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showNotificationDetails(NotificationItem notification) {
    setState(() {
      notification.isRead = true;
    });
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Color(0xFF203A43),
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 60,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white54,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                _buildNotificationIcon(notification.type),
                SizedBox(width: 15),
                Text(
                  notification.title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            Text(
              notification.content,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatTime(notification.time),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white54,
                  ),
                ),
                if (notification.type == NotificationType.approval)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // Navigate to leave details
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFFD700),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'View Leave',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _handleNotificationAction(NotificationAction action, NotificationItem notification) {
    switch (action) {
      case NotificationAction.markRead:
        _markAsRead(notification);
        break;
      case NotificationAction.delete:
        setState(() {
          notifications.removeWhere((n) => n.id == notification.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Notification deleted'),
            backgroundColor: Colors.red,
          ),
        );
        break;
      case NotificationAction.archive:
      // Implement archive logic
        break;
    }
  }

  Widget _buildNotificationIcon(NotificationType type) {
    Color color;
    IconData icon;

    switch (type) {
      case NotificationType.approval:
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case NotificationType.announcement:
        color = Colors.blue;
        icon = Icons.announcement;
        break;
      case NotificationType.reminder:
        color = Colors.orange;
        icon = Icons.notifications_active;
        break;
      case NotificationType.system:
        color = Colors.purple;
        icon = Icons.settings;
        break;
    }

    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM d, y').format(time);
    }
  }
}

class NotificationCard extends StatelessWidget {
  final NotificationItem notification;
  final Function(NotificationAction) onAction;

  const NotificationCard({
    required this.notification,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Card(
        elevation: 8,
        color: notification.isRead ? Colors.grey[800] : Color(0xFF2C5364),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  _buildNotificationIcon(notification.type),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          notification.content,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white70,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (!notification.isRead)
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Color(0xFFFFD700),
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatTime(notification.time),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white54,
                    ),
                  ),
                  PopupMenuButton<NotificationAction>(
                    icon: Icon(Icons.more_vert, color: Colors.white54),
                    onSelected: onAction,
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: NotificationAction.markRead,
                        child: Row(
                          children: [
                            Icon(Icons.mark_email_read, color: Colors.green),
                            SizedBox(width: 8),
                            Text('Mark as read'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: NotificationAction.delete,
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: NotificationAction.archive,
                        child: Row(
                          children: [
                            Icon(Icons.archive, color: Colors.blue),
                            SizedBox(width: 8),
                            Text('Archive'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(NotificationType type) {
    Color color;
    IconData icon;

    switch (type) {
      case NotificationType.approval:
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case NotificationType.announcement:
        color = Colors.blue;
        icon = Icons.announcement;
        break;
      case NotificationType.reminder:
        color = Colors.orange;
        icon = Icons.notifications_active;
        break;
      case NotificationType.system:
        color = Colors.purple;
        icon = Icons.settings;
        break;
    }

    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM d').format(time);
    }
  }
}

class NotificationItem {
  final String id;
  final String title;
  final String content;
  final DateTime time;
  bool isRead;
  final NotificationType type;

  NotificationItem({
    required this.id,
    required this.title,
    required this.content,
    required this.time,
    required this.isRead,
    required this.type,
  });
}

enum NotificationType {
  approval,
  announcement,
  reminder,
  system,
}

enum NotificationAction {
  markRead,
  delete,
  archive,
}