import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:interest_book/Provider/reminder_provider.dart';
import 'package:interest_book/Utils/app_colors.dart';
import 'package:interest_book/Reminders/reminders_page.dart';

class ReminderSummaryCard extends StatelessWidget {
  const ReminderSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ReminderProvider>(
      builder: (context, reminderProvider, child) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const RemindersPage(),
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.alarm,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Reminders',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey[400],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          'Today',
                          reminderProvider.todayReminderCount.toString(),
                          reminderProvider.todayReminderCount > 0 
                              ? AppColors.primary 
                              : Colors.grey[600]!,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.grey[300],
                      ),
                      Expanded(
                        child: _buildStatItem(
                          'Overdue',
                          reminderProvider.overdueReminderCount.toString(),
                          reminderProvider.overdueReminderCount > 0 
                              ? Colors.red[600]! 
                              : Colors.grey[600]!,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.grey[300],
                      ),
                      Expanded(
                        child: _buildStatItem(
                          'Active',
                          reminderProvider.activeReminderCount.toString(),
                          Colors.grey[700]!,
                        ),
                      ),
                    ],
                  ),
                  if (reminderProvider.todayReminderCount > 0 || 
                      reminderProvider.overdueReminderCount > 0) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        color: reminderProvider.overdueReminderCount > 0 
                            ? Colors.red[50] 
                            : AppColors.primary.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: reminderProvider.overdueReminderCount > 0 
                              ? Colors.red[200]! 
                              : AppColors.primary.withOpacity(0.2),
                        ),
                      ),
                      child: Text(
                        reminderProvider.overdueReminderCount > 0
                            ? 'You have ${reminderProvider.overdueReminderCount} overdue reminder${reminderProvider.overdueReminderCount > 1 ? 's' : ''}'
                            : 'You have ${reminderProvider.todayReminderCount} reminder${reminderProvider.todayReminderCount > 1 ? 's' : ''} for today',
                        style: TextStyle(
                          fontSize: 12,
                          color: reminderProvider.overdueReminderCount > 0 
                              ? Colors.red[700] 
                              : AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
