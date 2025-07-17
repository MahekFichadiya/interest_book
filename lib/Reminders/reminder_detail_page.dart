import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:interest_book/Provider/reminder_provider.dart';
import 'package:interest_book/Utils/app_colors.dart';
import 'package:interest_book/Model/ReminderModel.dart';
import 'package:interest_book/Services/sms_service.dart';
import 'package:url_launcher/url_launcher.dart';

class ReminderDetailPage extends StatelessWidget {
  final ReminderModel reminder;

  const ReminderDetailPage({
    super.key,
    required this.reminder,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Reminder Details',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  _editReminder(context);
                  break;
                case 'delete':
                  _deleteReminder(context);
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(),
            const SizedBox(height: 16),
            _buildDetailsCard(),
            const SizedBox(height: 16),
            _buildCustomerCard(),
            if (reminder.loanId != null) ...[
              const SizedBox(height: 16),
              _buildLoanCard(),
            ],
            const SizedBox(height: 24),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    final isOverdue = reminder.isDue && !reminder.isCompleted;
    final isToday = reminder.isToday;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    reminder.reminderTitle,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: reminder.isCompleted
                        ? Colors.green[100]
                        : isOverdue
                            ? Colors.red[100]
                            : isToday
                                ? AppColors.primary.withOpacity(0.1)
                                : Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    reminder.isCompleted
                        ? 'COMPLETED'
                        : isOverdue
                            ? 'OVERDUE'
                            : isToday
                                ? 'TODAY'
                                : 'PENDING',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: reminder.isCompleted
                          ? Colors.green[700]
                          : isOverdue
                              ? Colors.red[700]
                              : isToday
                                  ? AppColors.primary
                                  : Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 20,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Text(
                  '${reminder.formattedDate} at ${reminder.formattedTime}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            if (reminder.reminderMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                reminder.reminderMessage!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reminder Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            _buildDetailRow('Type', _getReminderTypeText()),
            _buildDetailRow('Created', formattedCreatedDate),
            if (reminder.isRecurring) ...[
              _buildDetailRow('Recurring', _getRecurringText()),
            ],
            if (reminder.isCompleted && reminder.completedAt != null) ...[
              _buildDetailRow('Completed', _getFormattedCompletedDate()),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Customer Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    reminder.custName.isNotEmpty ? reminder.custName[0].toUpperCase() : 'C',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reminder.custName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        reminder.custPhn,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _callCustomer(reminder.custPhn),
                  icon: const Icon(
                    Icons.phone,
                    color: AppColors.primary,
                  ),
                  tooltip: 'Call Customer',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoanCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Related Loan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            if (reminder.loanAmount != null) ...[
              _buildDetailRow('Amount', '₹${reminder.loanAmount}'),
            ],
            if (reminder.loanType != null) ...[
              _buildDetailRow('Type', reminder.loanType == '0' ? 'You Got' : 'You Gave'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    if (reminder.isCompleted) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _callCustomer(reminder.custPhn),
                icon: const Icon(Icons.phone),
                label: const Text('Call Customer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _sendSmsReminder(context),
                icon: const Icon(Icons.sms),
                label: const Text('Send SMS'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _markCompleted(context),
            icon: const Icon(Icons.check),
            label: const Text('Mark as Completed'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.green[700],
              side: BorderSide(color: Colors.green[300]!),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getReminderTypeText() {
    switch (reminder.reminderType) {
      case 'interest':
        return 'Interest Payment';
      case 'deposit':
        return 'Deposit Collection';
      case 'custom':
        return 'Custom Reminder';
      default:
        return reminder.reminderType;
    }
  }

  String _getRecurringText() {
    if (!reminder.isRecurring || reminder.recurringInterval == null) {
      return 'No';
    }
    return 'Yes (${reminder.recurringInterval!.toUpperCase()})';
  }

  String _getFormattedCompletedDate() {
    if (reminder.completedAt == null) return '';
    try {
      final date = DateTime.parse(reminder.completedAt!);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return reminder.completedAt!;
    }
  }

  String get formattedCreatedDate {
    try {
      final date = DateTime.parse(reminder.createdAt);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return reminder.createdAt;
    }
  }

  void _callCustomer(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  void _markCompleted(BuildContext context) async {
    final success = await context.read<ReminderProvider>().markReminderCompleted(reminder.reminderId);
    
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reminder marked as completed'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  void _editReminder(BuildContext context) {
    // TODO: Implement edit functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edit functionality coming soon'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _deleteReminder(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reminder'),
        content: const Text('Are you sure you want to delete this reminder?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await context.read<ReminderProvider>().deleteReminder(reminder.reminderId);
      
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reminder deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  void _sendSmsReminder(BuildContext context) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Sending SMS...'),
            ],
          ),
        ),
      );

      // Get loan amount for SMS (you might want to fetch this from loan data)
      final principalAmount = double.tryParse(reminder.loanAmount ?? '0') ?? 0.0;
      final interestAmount = 0.0; // Calculate from loan data if needed

      final result = await SmsService().sendReminderSms(
        customerName: reminder.custName,
        customerPhone: reminder.custPhn,
        reminderTitle: reminder.reminderTitle,
        reminderMessage: reminder.reminderMessage,
        principalAmount: principalAmount,
        interestAmount: interestAmount,
        dueDate: reminder.formattedDate,
      );

      // Close loading dialog
      Navigator.of(context).pop();

      // Show result
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('SMS sent successfully to ${reminder.custName}'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send SMS: ${result['message']}'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _sendSmsReminder(context),
            ),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if still open
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending SMS: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
