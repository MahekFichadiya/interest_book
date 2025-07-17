import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:interest_book/Provider/reminder_provider.dart';
import 'package:interest_book/Utils/app_colors.dart';
import 'package:interest_book/Model/ReminderModel.dart';
import 'package:interest_book/Reminders/add_reminder_page.dart';
import 'package:interest_book/Reminders/reminder_detail_page.dart';
import 'package:interest_book/Utils/reminder_test_helper.dart';
import 'package:interest_book/Services/realtime_reminder_service.dart';
import 'package:url_launcher/url_launcher.dart';

class RemindersPage extends StatefulWidget {
  const RemindersPage({super.key});

  @override
  State<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends State<RemindersPage> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReminderProvider>().loadReminders();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Reminders',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Today'),
            Tab(text: 'Active'),
            Tab(text: 'Completed'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.read<ReminderProvider>().generateAutomaticReminders();
            },
            icon: const Icon(Icons.auto_awesome),
            tooltip: 'Generate Auto Reminders',
          ),
          IconButton(
            onPressed: () {
              context.read<ReminderProvider>().loadReminders();
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'test_system') {
                final results = await ReminderTestHelper.testReminderSystem();
                if (mounted) {
                  ReminderTestHelper.showTestResults(context, results);
                }
              } else if (value == 'test_overdue') {
                await ReminderTestHelper.testOverdueNotification();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Test overdue notification sent!'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              } else if (value == 'check_now') {
                await RealtimeReminderService().checkNow();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Checked for due reminders!'),
                      backgroundColor: Colors.blue,
                    ),
                  );
                }
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'test_system',
                child: Row(
                  children: [
                    Icon(Icons.bug_report),
                    SizedBox(width: 8),
                    Text('Test System'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'test_overdue',
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Test Overdue'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'check_now',
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Check Now'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<ReminderProvider>(
        builder: (context, reminderProvider, child) {
          if (reminderProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          if (reminderProvider.error != null) {
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
                    reminderProvider.error!,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      reminderProvider.clearError();
                      reminderProvider.loadReminders();
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

          return TabBarView(
            controller: _tabController,
            children: [
              _buildRemindersList(reminderProvider.todayReminders, 'today'),
              _buildRemindersList(reminderProvider.activeReminders, 'active'),
              _buildRemindersList(reminderProvider.completedReminders, 'completed'),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddReminderPage(),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildRemindersList(List<ReminderModel> reminders, String type) {
    if (reminders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              type == 'today' ? Icons.today : 
              type == 'active' ? Icons.notifications_active : 
              Icons.check_circle_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              type == 'today' ? 'No reminders for today' :
              type == 'active' ? 'No active reminders' :
              'No completed reminders',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            if (type == 'active') ...[
              const SizedBox(height: 8),
              Text(
                'Tap + to add a new reminder',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<ReminderProvider>().loadReminders(),
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: reminders.length,
        itemBuilder: (context, index) {
          final reminder = reminders[index];
          return _buildReminderCard(reminder);
        },
      ),
    );
  }

  Widget _buildReminderCard(ReminderModel reminder) {
    final isOverdue = reminder.isDue && !reminder.isCompleted;
    final isToday = reminder.isToday;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isOverdue ? Colors.red.withOpacity(0.3) :
                 isToday ? AppColors.primary.withOpacity(0.3) :
                 Colors.transparent,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ReminderDetailPage(reminder: reminder),
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
                  Expanded(
                    child: Text(
                      reminder.reminderTitle,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isOverdue ? Colors.red[700] : Colors.black87,
                      ),
                    ),
                  ),
                  if (isOverdue)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'OVERDUE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.red[700],
                        ),
                      ),
                    ),
                  if (isToday && !isOverdue)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'TODAY',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.person,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    reminder.custName,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${reminder.formattedDate} at ${reminder.formattedTime}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
              if (reminder.reminderMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  reminder.reminderMessage!,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  if (!reminder.isCompleted) ...[
                    ElevatedButton.icon(
                      onPressed: () => _callCustomer(reminder.custPhn),
                      icon: const Icon(Icons.phone, size: 16),
                      label: const Text('Call'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () => _markCompleted(reminder),
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Done'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green[700],
                        side: BorderSide(color: Colors.green[300]!),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 16,
                            color: Colors.green[700],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Completed',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
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

  void _markCompleted(ReminderModel reminder) {
    context.read<ReminderProvider>().markReminderCompleted(reminder.reminderId);
  }
}
