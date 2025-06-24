import 'package:flutter/material.dart';
import 'package:interest_book/Provider/interest_provider.dart';
import 'package:interest_book/Provider/loan_provider.dart';
import 'package:interest_book/Provider/profile_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../Api/interest.dart';
import '../../Widgets/amount_form_field.dart';

class AddInterestScreen extends StatefulWidget {
  final String loanId;

  const AddInterestScreen({
    Key? key,
    required this.loanId,
  }) : super(key: key);

  @override
  State<AddInterestScreen> createState() => _AddInterestScreenState();
}

class _AddInterestScreenState extends State<AddInterestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _dateController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isLoading = false;

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
              _saveInterest();
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

  Future<void> _saveInterest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Get raw amount value for API
      String rawAmount = AmountFormFieldHelper.getRawAmount(_amountController);

      // Convert date from display format (dd/MM/yyyy) to MySQL format (yyyy-MM-dd)
      String formattedDate = getFormattedDateForMySQL(_dateController.text);

      final success = await interestApi().addInterest(
        rawAmount,
        formattedDate,
        _noteController.text,
        widget.loanId,
      );

      if (success) {
        // Small delay to ensure database operations are completed
        await Future.delayed(const Duration(milliseconds: 500));

        // Refresh the interest list
        if (mounted) {
          await Provider.of<Interestprovider>(context, listen: false)
              .fetchInterestList(widget.loanId);
        }

        // Refresh loan data to update totals immediately
        // This will trigger automatic interest recalculation and update UI
        final prefs = await SharedPreferences.getInstance();
        final userId = prefs.getString("userId");
        String? custId = prefs.getString("custId");

        if (mounted && userId != null) {
          // Refresh loan provider which will trigger interest calculation
          await Provider.of<LoanProvider>(context, listen: false)
              .fetchLoanDetailList(userId, custId);

          // Also refresh the profile provider to update profile screen amounts
          if (mounted) {
            await Provider.of<ProfileProvider>(context, listen: false)
                .fetchMoneyInfo();
          }
        }

        if (mounted) {
          _showSnackBar('Interest payment added successfully');
          Navigator.pop(context, true);
        }
      } else {
        if (mounted) {
          _showSnackBar('Failed to add interest payment. Please try again.', isError: true, showRetry: true);
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
        title: const Text('Enter Interest Details'),
        backgroundColor: Colors.blueGrey[700],
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveInterest,
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),
                
                // Amount Field
                AmountFormField(
                  controller: _amountController,
                  label: "Amount",
                  hintText: "Enter interest amount",
                  prefixIcon: Icons.attach_money_rounded,
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
                        color: Colors.grey.withOpacity(0.1),
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
                      hintText: 'Interest Till Date',
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
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: _noteController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Note (Optional)',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                    ),
                  ),
                ),
        
                const SizedBox(height: 30),
        
                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveInterest,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
