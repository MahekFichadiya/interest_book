import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:interest_book/Provider/reminder_provider.dart';
import 'package:interest_book/Provider/customer_provider.dart';
import 'package:interest_book/Provider/loan_provider.dart';
import 'package:interest_book/Utils/app_colors.dart';
import 'package:interest_book/Model/CustomerModel.dart';
import 'package:interest_book/Model/LoanDetail.dart';
import 'package:interest_book/Services/notification_service.dart';
import 'package:interest_book/Services/realtime_reminder_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddReminderPage extends StatefulWidget {
  final Customer? preSelectedCustomer;
  final Loandetail? preSelectedLoan;

  const AddReminderPage({
    super.key,
    this.preSelectedCustomer,
    this.preSelectedLoan,
  });

  @override
  State<AddReminderPage> createState() => _AddReminderPageState();
}

class _AddReminderPageState extends State<AddReminderPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();

  Customer? _selectedCustomer;
  Loandetail? _selectedLoan;
  String _reminderType = 'interest';
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 0);
  bool _isRecurring = false;
  String? _recurringInterval;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedCustomer = widget.preSelectedCustomer;
    _selectedLoan = widget.preSelectedLoan;
    
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      if (userId != null && mounted) {
        context.read<CustomerProvider>().fetchCustomerList(userId);
        if (_selectedCustomer != null) {
          context.read<LoanProvider>().fetchLoanDetailList(userId, _selectedCustomer!.custId!);
        }
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Add Reminder',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCustomerSelection(),
              const SizedBox(height: 16),
              _buildLoanSelection(),
              const SizedBox(height: 16),
              _buildReminderTypeSelection(),
              const SizedBox(height: 16),
              _buildTitleField(),
              const SizedBox(height: 16),
              _buildMessageField(),
              const SizedBox(height: 16),
              _buildDateTimeSelection(),
              const SizedBox(height: 16),
              _buildRecurringOptions(),
              const SizedBox(height: 32),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerSelection() {
    return Consumer<CustomerProvider>(
      builder: (context, customerProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Customer *',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonFormField<Customer>(
                value: _selectedCustomer,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: InputBorder.none,
                  hintText: 'Choose a customer',
                ),
                items: customerProvider.customers.map((customer) {
                  return DropdownMenuItem<Customer>(
                    value: customer,
                    child: Text(
                      '${customer.custName} - ${customer.custPhn}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  );
                }).toList(),
                onChanged: (Customer? customer) {
                  setState(() {
                    _selectedCustomer = customer;
                    _selectedLoan = null; // Reset loan selection
                  });
                  if (customer != null) {
                    SharedPreferences.getInstance().then((prefs) {
                      final userId = prefs.getString('userId');
                      if (userId != null) {
                        context.read<LoanProvider>().fetchLoanDetailList(userId, customer.custId!);
                      }
                    });
                  }
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a customer';
                  }
                  return null;
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLoanSelection() {
    return Consumer<LoanProvider>(
      builder: (context, loanProvider, child) {
        final customerLoans = _selectedCustomer != null
            ? loanProvider.detail.where((loan) => loan.custId == _selectedCustomer!.custId).toList()
            : <Loandetail>[];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Loan (Optional)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonFormField<Loandetail>(
                value: _selectedLoan,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: InputBorder.none,
                  hintText: 'Choose a loan (optional)',
                ),
                items: customerLoans.map((loan) {
                  return DropdownMenuItem<Loandetail>(
                    value: loan,
                    child: Text(
                      'Loan ₹${loan.amount} - ${loan.type == "0" ? "You Got" : "You Gave"}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  );
                }).toList(),
                onChanged: (Loandetail? loan) {
                  setState(() {
                    _selectedLoan = loan;
                  });
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildReminderTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reminder Type',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: RadioListTile<String>(
                title: const Text('Interest'),
                value: 'interest',
                groupValue: _reminderType,
                onChanged: (value) {
                  setState(() {
                    _reminderType = value!;
                  });
                },
                activeColor: AppColors.primary,
              ),
            ),
            Expanded(
              child: RadioListTile<String>(
                title: const Text('Deposit'),
                value: 'deposit',
                groupValue: _reminderType,
                onChanged: (value) {
                  setState(() {
                    _reminderType = value!;
                  });
                },
                activeColor: AppColors.primary,
              ),
            ),
            Expanded(
              child: RadioListTile<String>(
                title: const Text('Custom'),
                value: 'custom',
                groupValue: _reminderType,
                onChanged: (value) {
                  setState(() {
                    _reminderType = value!;
                  });
                },
                activeColor: AppColors.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reminder Title *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _titleController,
          decoration: InputDecoration(
            hintText: 'Enter reminder title',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a reminder title';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildMessageField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Message (Optional)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _messageController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Enter additional message',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date & Time',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InkWell(
                onTap: _selectTime,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _selectedTime.format(context),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecurringOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Checkbox(
              value: _isRecurring,
              onChanged: (value) {
                setState(() {
                  _isRecurring = value!;
                  if (!_isRecurring) {
                    _recurringInterval = null;
                  }
                });
              },
              activeColor: AppColors.primary,
            ),
            const Text(
              'Recurring Reminder',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        if (_isRecurring) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('Daily'),
                  value: 'daily',
                  groupValue: _recurringInterval,
                  onChanged: (value) {
                    setState(() {
                      _recurringInterval = value;
                    });
                  },
                  activeColor: AppColors.primary,
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('Weekly'),
                  value: 'weekly',
                  groupValue: _recurringInterval,
                  onChanged: (value) {
                    setState(() {
                      _recurringInterval = value;
                    });
                  },
                  activeColor: AppColors.primary,
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('Monthly'),
                  value: 'monthly',
                  groupValue: _recurringInterval,
                  onChanged: (value) {
                    setState(() {
                      _recurringInterval = value;
                    });
                  },
                  activeColor: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveReminder,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Save Reminder',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _saveReminder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a customer'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_isRecurring && _recurringInterval == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select recurring interval'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final reminderDate = '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';
    final reminderTime = '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}:00';

    // Debug: Print the time being saved
    print('Saving reminder with time: $reminderTime (from ${_selectedTime.hour}:${_selectedTime.minute})');

    final success = await context.read<ReminderProvider>().addReminder(
      custId: _selectedCustomer!.custId!,
      loanId: _selectedLoan?.loanId,
      reminderType: _reminderType,
      reminderTitle: _titleController.text.trim(),
      reminderMessage: _messageController.text.trim().isEmpty ? null : _messageController.text.trim(),
      reminderDate: reminderDate,
      reminderTime: reminderTime,
      isRecurring: _isRecurring,
      recurringInterval: _recurringInterval,
    );

    setState(() {
      _isLoading = false;
    });

    if (success) {
      if (mounted) {
        // Trigger immediate check for new reminders
        RealtimeReminderService().checkNow();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reminder saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } else {
      if (mounted) {
        final error = context.read<ReminderProvider>().error ?? 'Failed to save reminder';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
