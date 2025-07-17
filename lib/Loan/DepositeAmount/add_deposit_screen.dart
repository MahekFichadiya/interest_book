import 'package:flutter/material.dart';
import 'package:interest_book/Provider/deposite_provider.dart';
import 'package:interest_book/Provider/loan_provider.dart';
import 'package:interest_book/Provider/profile_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../Api/interest.dart';
import '../../Widgets/amount_form_field.dart';

class AddDepositScreen extends StatefulWidget {
  final String loanId;

  const AddDepositScreen({
    Key? key,
    required this.loanId,
  }) : super(key: key);

  @override
  State<AddDepositScreen> createState() => _AddDepositScreenState();
}

class _AddDepositScreenState extends State<AddDepositScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _dateController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isLoading = false;
  String _selectedPaymentMethod = 'cash'; // Default to cash

  @override
  void initState() {
    super.initState();
    // Set current date as default in dd/MM/yyyy format
    _dateController.text = DateFormat("dd/MM/yyyy").format(DateTime.now());
  }

  @override
  void dispose() {
    _amountController.dispose();
    _dateController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = false, bool showRetry = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error : Icons.check_circle,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: Duration(seconds: isError ? 4 : 3),
        behavior: SnackBarBehavior.floating,
        action: showRetry ? SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: () {
            if (!_isLoading) {
              _saveDeposit();
            }
          },
        ) : null,
      ),
    );
  }

  // Convert display format (dd/MM/yyyy) to MySQL format (yyyy-MM-dd)
  String getFormattedDateForMySQL(String dateTime) {
    final DateTime parsedDateTime = DateFormat("dd/MM/yyyy").parse(dateTime);
    return DateFormat("yyyy-MM-dd").format(parsedDateTime);
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blueGrey[700]!,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat("dd/MM/yyyy").format(picked);
      });
    }
  }

  Future<void> _saveDeposit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Get raw amount value for API
      String rawAmount = AmountFormFieldHelper.getRawAmount(_amountController);

      // Convert date from display format (dd/MM/yyyy) to MySQL format (yyyy-MM-dd)
      String formattedDate = getFormattedDateForMySQL(_dateController.text);

      final success = await interestApi().addDeposite(
        rawAmount,
        formattedDate,
        _noteController.text,
        widget.loanId,
        _selectedPaymentMethod,
      );

      if (success) {
        // Immediately notify UI of changes for instant update
        if (mounted) {
          Provider.of<Depositeprovider>(context, listen: false).forceRefresh();
        }

        // Refresh the deposit list in background
        if (mounted) {
          await Provider.of<Depositeprovider>(context, listen: false)
              .fetchDepositeList(widget.loanId);
        }

        // Refresh loan data to update totals
        final prefs = await SharedPreferences.getInstance();
        final userId = prefs.getString("userId");
        final custId = prefs.getString("custId");

        if (mounted && userId != null) {
          await Provider.of<LoanProvider>(context, listen: false)
              .fetchLoanDetailList(userId, custId);

          // Also refresh the profile provider to update profile screen amounts
          if (mounted) {
            await Provider.of<ProfileProvider>(context, listen: false)
                .fetchMoneyInfo();
          }
        }

        if (mounted) {
          _showSnackBar('Deposit added successfully');
          Navigator.pop(context, true);
        }
      } else {
        if (mounted) {
          _showSnackBar('Failed to add deposit. Please try again.', isError: true, showRetry: true);
        }
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'An unexpected error occurred';
        if (e.toString().contains('network') || e.toString().contains('connection')) {
          errorMessage = 'Network error. Please check your connection and try again.';
        } else if (e.toString().contains('timeout')) {
          errorMessage = 'Request timeout. Please try again.';
        } else if (e.toString().contains('server')) {
          errorMessage = 'Server error. Please try again later.';
        }

        _showSnackBar(errorMessage, isError: true, showRetry: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Enter Deposit Details'),
        backgroundColor: Colors.blueGrey[700],
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveDeposit,
            child: const Text(
              'SAVE',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                
                // Amount Field
                AmountFormField(
                  controller: _amountController,
                  label: "Amount",
                  hintText: "Enter deposit amount",
                  prefixIcon: Icons.currency_rupee,
                  showCurrencySymbol: false,
                  allowDecimals: false,
                ),
        
                const SizedBox(height: 16),
        
                // Date Field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: _dateController,
                    readOnly: true,
                    onTap: _selectDate,
                    decoration: const InputDecoration(
                      hintText: 'Deposit Date',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                      suffixIcon: Icon(Icons.calendar_today, color: Colors.grey),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select date';
                      }
                      return null;
                    },
                  ),
                ),
        
                const SizedBox(height: 16),
        
                // Note Field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: _noteController,
                    maxLines: 1,
                    decoration: const InputDecoration(
                      hintText: 'Note (Optional)',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Payment Method Radio Buttons
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Payment Method',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text(
                                  'Cash',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                value: 'cash',
                                groupValue: _selectedPaymentMethod,
                                onChanged: (String? value) {
                                  setState(() {
                                    _selectedPaymentMethod = value!;
                                  });
                                },
                                activeColor: Colors.blueGrey[700],
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text(
                                  'Online',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                value: 'online',
                                groupValue: _selectedPaymentMethod,
                                onChanged: (String? value) {
                                  setState(() {
                                    _selectedPaymentMethod = value!;
                                  });
                                },
                                activeColor: Colors.blueGrey[700],
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),
        
                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveDeposit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
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
                            'SAVE',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                // Add bottom padding to prevent overflow
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
