import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:interest_book/Provider/notification_provider.dart';
import 'package:interest_book/Utils/app_colors.dart';
import 'package:interest_book/Model/NotificationModel.dart';
import 'package:interest_book/Reminders/reminders_page.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, notificationProvider, child) {
              if (notificationProvider.hasUnreadNotifications) {
                return TextButton(
                  onPressed: () {
                    notificationProvider.markAllAsRead();
                  },
                  child: const Text(
                    'Mark All Read',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          IconButton(
            onPressed: () {
              context.read<NotificationProvider>().refreshNotifications();
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, notificationProvider, child) {
          if (notificationProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          if (notificationProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    notificationProvider.error!,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      notificationProvider.clearError();
                      notificationProvider.loadNotifications();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (notificationProvider.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No notifications yet',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Set up reminders to get notified',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const RemindersPage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add_alert),
                    label: const Text('Set Reminders'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => notificationProvider.refreshNotifications(),
            color: AppColors.primary,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notificationProvider.notifications.length,
              itemBuilder: (context, index) {
                final notification = notificationProvider.notifications[index];
                return _buildNotificationCard(notification, notificationProvider);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification, NotificationProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: notification.isRead ? 1 : 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: notification.isRead 
              ? Colors.transparent 
              : notification.isUrgent 
                  ? Colors.red.withOpacity(0.3)
                  : notification.isHighPriority
                      ? AppColors.primary.withOpacity(0.3)
                      : Colors.transparent,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          if (!notification.isRead) {
            provider.markAsRead(notification.notificationId);
          }
          _handleNotificationTap(notification);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (!notification.isRead)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: notification.isUrgent 
                            ? Colors.red 
                            : notification.isHighPriority
                                ? AppColors.primary
                                : Colors.blue,
                        shape: BoxShape.circle,
                      ),
                    ),
                  if (!notification.isRead) const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      notification.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w600,
                        color: notification.isRead ? Colors.grey[700] : Colors.black87,
                      ),
                    ),
                  ),
                  _buildPriorityBadge(notification),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                notification.message,
                style: TextStyle(
                  fontSize: 14,
                  color: notification.isRead ? Colors.grey[600] : Colors.grey[700],
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildNotificationTypeChip(notification),
                  const Spacer(),
                  Text(
                    notification.timeAgo,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
              if (notification.isActionRequired) ...[
                const SizedBox(height: 12),
                _buildActionButtons(notification),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(NotificationModel notification) {
    if (notification.priority == 'low') return const SizedBox.shrink();

    Color color;
    String text;
    
    switch (notification.priority) {
      case 'urgent':
        color = Colors.red;
        text = 'URGENT';
        break;
      case 'high':
        color = Colors.orange;
        text = 'HIGH';
        break;
      case 'medium':
        color = Colors.blue;
        text = 'MED';
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildNotificationTypeChip(NotificationModel notification) {
    IconData icon;
    Color color;
    String label;

    switch (notification.notificationType) {
      case 'payment_due':
        icon = Icons.payment;
        color = Colors.red;
        label = 'Payment Due';
        break;
      case 'reminder':
        icon = Icons.alarm;
        color = AppColors.primary;
        label = 'Reminder';
        break;
      case 'system':
        icon = Icons.info;
        color = Colors.blue;
        label = 'System';
        break;
      default:
        icon = Icons.notifications;
        color = Colors.grey;
        label = 'Notification';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(NotificationModel notification) {
    return Row(
      children: [
        if (notification.actionType == 'call_customer' && notification.custPhn != null) ...[
          ElevatedButton.icon(
            onPressed: () => _callCustomer(notification.custPhn!),
            icon: const Icon(Icons.phone, size: 16),
            label: const Text('Call'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const SizedBox(width: 8),
        ],
        if (notification.actionType == 'view_loan') ...[
          OutlinedButton.icon(
            onPressed: () => _viewLoan(notification),
            icon: const Icon(Icons.visibility, size: 16),
            label: const Text('View Loan'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ],
    );
  }

  void _handleNotificationTap(NotificationModel notification) {
    // Handle different notification types
    switch (notification.notificationType) {
      case 'reminder':
        if (notification.reminderId != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const RemindersPage(),
            ),
          );
        }
        break;
      case 'payment_due':
        if (notification.custPhn != null) {
          _callCustomer(notification.custPhn!);
        }
        break;
      default:
        // Default action or show details
        break;
    }
  }

  void _callCustomer(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not launch phone dialer'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _viewLoan(NotificationModel notification) {
    // TODO: Navigate to loan detail page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Loan view functionality coming soon'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}
