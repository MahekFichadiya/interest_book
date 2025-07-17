class NotificationModel {
  final String notificationId;
  final String? custId;
  final String? custName;
  final String? custPhn;
  final String? loanId;
  final String? loanAmount;
  final String? loanType;
  final String? reminderId;
  final String? reminderTitle;
  final String notificationType;
  final String title;
  final String message;
  final bool isRead;
  final bool isActionRequired;
  final String actionType;
  final Map<String, dynamic>? actionData;
  final String priority;
  final String? scheduledAt;
  final String? readAt;
  final String createdAt;
  final String updatedAt;

  NotificationModel({
    required this.notificationId,
    this.custId,
    this.custName,
    this.custPhn,
    this.loanId,
    this.loanAmount,
    this.loanType,
    this.reminderId,
    this.reminderTitle,
    required this.notificationType,
    required this.title,
    required this.message,
    required this.isRead,
    required this.isActionRequired,
    required this.actionType,
    this.actionData,
    required this.priority,
    this.scheduledAt,
    this.readAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? actionDataMap;
    if (json['actionData'] != null) {
      if (json['actionData'] is String) {
        try {
          actionDataMap = Map<String, dynamic>.from(
            json['actionData'] as Map<String, dynamic>
          );
        } catch (e) {
          actionDataMap = null;
        }
      } else if (json['actionData'] is Map) {
        actionDataMap = Map<String, dynamic>.from(json['actionData']);
      }
    }

    return NotificationModel(
      notificationId: json['notificationId']?.toString() ?? '',
      custId: json['custId']?.toString(),
      custName: json['custName']?.toString(),
      custPhn: json['custPhn']?.toString(),
      loanId: json['loanId']?.toString(),
      loanAmount: json['loanAmount']?.toString(),
      loanType: json['loanType']?.toString(),
      reminderId: json['reminderId']?.toString(),
      reminderTitle: json['reminderTitle']?.toString(),
      notificationType: json['notificationType']?.toString() ?? 'reminder',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      isRead: json['isRead'] == 1 || json['isRead'] == true,
      isActionRequired: json['isActionRequired'] == 1 || json['isActionRequired'] == true,
      actionType: json['actionType']?.toString() ?? 'none',
      actionData: actionDataMap,
      priority: json['priority']?.toString() ?? 'medium',
      scheduledAt: json['scheduledAt']?.toString(),
      readAt: json['readAt']?.toString(),
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notificationId': notificationId,
      'custId': custId,
      'custName': custName,
      'custPhn': custPhn,
      'loanId': loanId,
      'loanAmount': loanAmount,
      'loanType': loanType,
      'reminderId': reminderId,
      'reminderTitle': reminderTitle,
      'notificationType': notificationType,
      'title': title,
      'message': message,
      'isRead': isRead,
      'isActionRequired': isActionRequired,
      'actionType': actionType,
      'actionData': actionData,
      'priority': priority,
      'scheduledAt': scheduledAt,
      'readAt': readAt,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Helper methods
  DateTime get createdDateTime {
    try {
      return DateTime.parse(createdAt);
    } catch (e) {
      return DateTime.now();
    }
  }

  DateTime? get scheduledDateTime {
    if (scheduledAt == null) return null;
    try {
      return DateTime.parse(scheduledAt!);
    } catch (e) {
      return null;
    }
  }

  String get formattedCreatedDate {
    try {
      final date = createdDateTime;
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return '';
    }
  }

  String get formattedCreatedTime {
    try {
      final date = createdDateTime;
      final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
      final period = date.hour >= 12 ? 'PM' : 'AM';
      return '$hour:${date.minute.toString().padLeft(2, '0')} $period';
    } catch (e) {
      return '';
    }
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdDateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  bool get isHighPriority => priority == 'high' || priority == 'urgent';
  bool get isUrgent => priority == 'urgent';

  NotificationModel copyWith({
    String? notificationId,
    String? custId,
    String? custName,
    String? custPhn,
    String? loanId,
    String? loanAmount,
    String? loanType,
    String? reminderId,
    String? reminderTitle,
    String? notificationType,
    String? title,
    String? message,
    bool? isRead,
    bool? isActionRequired,
    String? actionType,
    Map<String, dynamic>? actionData,
    String? priority,
    String? scheduledAt,
    String? readAt,
    String? createdAt,
    String? updatedAt,
  }) {
    return NotificationModel(
      notificationId: notificationId ?? this.notificationId,
      custId: custId ?? this.custId,
      custName: custName ?? this.custName,
      custPhn: custPhn ?? this.custPhn,
      loanId: loanId ?? this.loanId,
      loanAmount: loanAmount ?? this.loanAmount,
      loanType: loanType ?? this.loanType,
      reminderId: reminderId ?? this.reminderId,
      reminderTitle: reminderTitle ?? this.reminderTitle,
      notificationType: notificationType ?? this.notificationType,
      title: title ?? this.title,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      isActionRequired: isActionRequired ?? this.isActionRequired,
      actionType: actionType ?? this.actionType,
      actionData: actionData ?? this.actionData,
      priority: priority ?? this.priority,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
