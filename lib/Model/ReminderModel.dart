class ReminderModel {
  final String reminderId;
  final String custId;
  final String custName;
  final String custPhn;
  final String? loanId;
  final String? loanAmount;
  final String? loanType;
  final String reminderType;
  final String reminderTitle;
  final String? reminderMessage;
  final String reminderDate;
  final String reminderTime;
  final bool isRecurring;
  final String? recurringInterval;
  final bool isActive;
  final bool isCompleted;
  final String? completedAt;
  final String createdAt;
  final String updatedAt;

  ReminderModel({
    required this.reminderId,
    required this.custId,
    required this.custName,
    required this.custPhn,
    this.loanId,
    this.loanAmount,
    this.loanType,
    required this.reminderType,
    required this.reminderTitle,
    this.reminderMessage,
    required this.reminderDate,
    required this.reminderTime,
    required this.isRecurring,
    this.recurringInterval,
    required this.isActive,
    required this.isCompleted,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      reminderId: json['reminderId']?.toString() ?? '',
      custId: json['custId']?.toString() ?? '',
      custName: json['custName']?.toString() ?? '',
      custPhn: json['custPhn']?.toString() ?? '',
      loanId: json['loanId']?.toString(),
      loanAmount: json['loanAmount']?.toString(),
      loanType: json['loanType']?.toString(),
      reminderType: json['reminderType']?.toString() ?? 'interest',
      reminderTitle: json['reminderTitle']?.toString() ?? '',
      reminderMessage: json['reminderMessage']?.toString(),
      reminderDate: json['reminderDate']?.toString() ?? '',
      reminderTime: json['reminderTime']?.toString() ?? '10:00:00',
      isRecurring: json['isRecurring'] == 1 || json['isRecurring'] == true,
      recurringInterval: json['recurringInterval']?.toString(),
      isActive: json['isActive'] == 1 || json['isActive'] == true,
      isCompleted: json['isCompleted'] == 1 || json['isCompleted'] == true,
      completedAt: json['completedAt']?.toString(),
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reminderId': reminderId,
      'custId': custId,
      'custName': custName,
      'custPhn': custPhn,
      'loanId': loanId,
      'loanAmount': loanAmount,
      'loanType': loanType,
      'reminderType': reminderType,
      'reminderTitle': reminderTitle,
      'reminderMessage': reminderMessage,
      'reminderDate': reminderDate,
      'reminderTime': reminderTime,
      'isRecurring': isRecurring,
      'recurringInterval': recurringInterval,
      'isActive': isActive,
      'isCompleted': isCompleted,
      'completedAt': completedAt,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Helper methods
  DateTime get reminderDateTime {
    try {
      return DateTime.parse('$reminderDate $reminderTime');
    } catch (e) {
      return DateTime.now();
    }
  }

  bool get isDue {
    final now = DateTime.now();
    final reminderDT = reminderDateTime;
    return reminderDT.isBefore(now) || reminderDT.isAtSameMomentAs(now);
  }

  bool get isToday {
    final now = DateTime.now();
    final reminderDT = reminderDateTime;
    return reminderDT.year == now.year &&
           reminderDT.month == now.month &&
           reminderDT.day == now.day;
  }

  String get formattedDate {
    try {
      final date = DateTime.parse(reminderDate);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return reminderDate;
    }
  }

  String get formattedTime {
    try {
      final time = reminderTime.split(':');
      final hour = int.parse(time[0]);
      final minute = int.parse(time[1]);
      final period = hour >= 12 ? 'PM' : 'AM';

      // Convert 24-hour to 12-hour format
      int displayHour;
      if (hour == 0) {
        displayHour = 12; // Midnight (00:xx) becomes 12:xx AM
      } else if (hour > 12) {
        displayHour = hour - 12; // 13:xx becomes 1:xx PM, etc.
      } else {
        displayHour = hour; // 1:xx to 12:xx stays the same
      }

      return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
    } catch (e) {
      return reminderTime;
    }
  }

  ReminderModel copyWith({
    String? reminderId,
    String? custId,
    String? custName,
    String? custPhn,
    String? loanId,
    String? loanAmount,
    String? loanType,
    String? reminderType,
    String? reminderTitle,
    String? reminderMessage,
    String? reminderDate,
    String? reminderTime,
    bool? isRecurring,
    String? recurringInterval,
    bool? isActive,
    bool? isCompleted,
    String? completedAt,
    String? createdAt,
    String? updatedAt,
  }) {
    return ReminderModel(
      reminderId: reminderId ?? this.reminderId,
      custId: custId ?? this.custId,
      custName: custName ?? this.custName,
      custPhn: custPhn ?? this.custPhn,
      loanId: loanId ?? this.loanId,
      loanAmount: loanAmount ?? this.loanAmount,
      loanType: loanType ?? this.loanType,
      reminderType: reminderType ?? this.reminderType,
      reminderTitle: reminderTitle ?? this.reminderTitle,
      reminderMessage: reminderMessage ?? this.reminderMessage,
      reminderDate: reminderDate ?? this.reminderDate,
      reminderTime: reminderTime ?? this.reminderTime,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringInterval: recurringInterval ?? this.recurringInterval,
      isActive: isActive ?? this.isActive,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
