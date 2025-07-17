import 'dart:io';
import 'package:flutter/material.dart';
import 'package:interest_book/Api/fetch_all_loans_by_user_and_customer.dart';
import 'package:interest_book/Api/remove_customer.dart';
import 'package:interest_book/Api/UrlConstant.dart';
import 'package:interest_book/Contact/EditContact.dart';
import 'package:interest_book/Loan/ApplyLoan/ApplyLoan.dart';
import 'package:interest_book/Loan/LoanDashborad/LoanList.dart';
import 'package:interest_book/Model/CustomerModel.dart';
import 'package:interest_book/Provider/customer_provider.dart';
import 'package:interest_book/Provider/loan_provider.dart';
import 'package:interest_book/Provider/profile_provider.dart';
import 'package:interest_book/Utils/amount_formatter.dart';
import 'package:interest_book/Utils/sms_helper.dart';
import 'package:interest_book/Utils/whatsapp_helper.dart';
import 'package:interest_book/Utils/reliable_payment_reminder.dart';
import 'package:interest_book/pdfGenerator/generate_pdf_for_particular_customer.dart';
import 'package:interest_book/Widgets/full_screen_image_viewer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Loandashboard extends StatefulWidget {
  final String custId;
  const Loandashboard({super.key, required this.custId});

  @override
  State<Loandashboard> createState() => _LoandashboardState();
}

class _LoandashboardState extends State<Loandashboard> {
  String? userId;

  loadData() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString("userId");
    setState(() {});
  }

  @override
  void initState() {
    loadData();
    super.initState();
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri url = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _sendSMSMessage(
    Customer customer,
    Map<String, dynamic> totals,
  ) async {
    try {
      // Get values from totals
      double principalAmount =
          totals['totalAmount'] ?? 0.0; // This is the current principal
      double totalInterest =
          totals['totalInterest'] ?? 0.0; // This is pending interest
      double totalDue =
          totals['totalDue'] ?? 0.0; // This is principal + interest

      // Generate the message
      String message = SMSHelper.generateLoanSummaryMessage(
        totalAmount: totalDue,
        totalInterest: totalInterest,
        principalAmount: principalAmount,
      );

      // Send SMS
      await SMSHelper.sendSMS(phoneNumber: customer.custPhn, message: message);

      // SMS sent successfully - no snackbar message as per user preference
    } catch (e) {
      // Show error message to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send SMS: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _sendWhatsAppPaymentReminder(
    Customer customer,
    Map<String, dynamic> totals,
  ) async {
    print('=== WhatsApp Payment Reminder Started ===');
    print('Customer: ${customer.custName}');
    print('Totals: $totals');

    try {
      // Show loading indicator with new text
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Generating payment reminder image...'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Get values from totals
      double principalAmount = totals['totalAmount'] ?? 0.0;
      double totalInterest = totals['totalInterest'] ?? 0.0;
      double totalDue = totals['totalDue'] ?? 0.0;

      // Generate payment reminder image with fallback options
      File? imageFile;

      print('Starting image generation for ${customer.custName}');

      // Try detailed payment reminder first
      try {
        print('Trying detailed payment reminder...');
        imageFile =
            await ReliablePaymentReminder.generateDetailedPaymentReminder(
              customerName: customer.custName,
              principalAmount: principalAmount,
              interestAmount: totalInterest,
              totalAmount: totalDue,
              companyName: 'Interest Book',
            );
        if (imageFile != null) {
          print(
            'Detailed payment reminder generated successfully: ${imageFile.path}',
          );
        } else {
          print('Detailed payment reminder returned null');
        }
      } catch (e) {
        print('Detailed payment reminder failed: $e');
      }

      // If detailed fails, try basic payment reminder
      if (imageFile == null) {
        try {
          print('Trying basic payment reminder...');
          imageFile =
              await ReliablePaymentReminder.generateBasicPaymentReminder(
                customerName: customer.custName,
                totalAmount: totalDue,
                companyName: 'Interest Book',
              );
          if (imageFile != null) {
            print(
              'Basic payment reminder generated successfully: ${imageFile.path}',
            );
          } else {
            print('Basic payment reminder returned null');
          }
        } catch (e) {
          print('Basic payment reminder failed: $e');
        }
      }

      // If both fail, try fallback reminder
      if (imageFile == null) {
        try {
          print('Trying fallback payment reminder...');
          imageFile = await ReliablePaymentReminder.generateFallbackReminder(
            customerName: customer.custName,
            totalAmount: totalDue,
            companyName: 'Interest Book',
          );
          if (imageFile != null) {
            print(
              'Fallback payment reminder generated successfully: ${imageFile.path}',
            );
          } else {
            print('Fallback payment reminder returned null');
          }
        } catch (e) {
          print('Fallback payment reminder failed: $e');
        }
      }

      print(
        'Final imageFile status: ${imageFile != null ? 'Generated' : 'Failed'}',
      );

      // Opening WhatsApp directly - no loading message as per user preference

      // Create a payment reminder message
      String paymentMessage =
          'Dear ${customer.custName}, Please find your payment reminder attached. Total Amount Due: ${AmountFormatter.formatCurrency(totalDue)}. Please make the payment as soon as possible. Thank you!';

      if (imageFile != null) {
        // Send image directly to WhatsApp - opens WhatsApp with image and message ready to send
        await WhatsAppHelper.sendImageDirectly(
          imageFile: imageFile,
          phoneNumber: customer.custPhn,
          message: paymentMessage,
        );
      } else {
        // Fallback to text-only message if image generation fails
        await WhatsAppHelper.openWhatsAppDirectly(
          phoneNumber: customer.custPhn,
          message: paymentMessage,
        );
      }

      // WhatsApp opened successfully - no snackbar message as per user preference
    } catch (e) {
      // Show detailed error message to user
      String errorMessage = 'Failed to send payment reminder';
      if (e.toString().contains('not installed')) {
        errorMessage =
            'WhatsApp is not installed. Please install WhatsApp first.';
      } else if (e.toString().contains('internet')) {
        errorMessage = 'Please check your internet connection and try again.';
      } else {
        errorMessage =
            'Failed to send payment reminder. Please try again or contact support.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _sendWhatsAppPaymentReminder(customer, totals),
            ),
          ),
        );
      }
    }
  }

  // Show customer picture in full screen
  void _showFullScreenImage(String imagePath, String customerName) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => FullScreenImageViewer(
              imagePath: imagePath,
              customerName: customerName,
            ),
      ),
    );
  }

  // Remove this method as we'll use the provider's totals directly

  Future<void> _deleteCustomer(customer) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString("userId");

      if (userId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error: User not found'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Show loading indicator
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => const Center(child: CircularProgressIndicator()),
        );
      }

      // Call the delete API
      final result = await Removecustomer().remove(customer.custId, userId);

      // Hide loading indicator
      if (mounted) {
        Navigator.pop(context);
      }

      if (result.success) {
        // Remove customer from provider
        if (mounted) {
          Provider.of<CustomerProvider>(
            context,
            listen: false,
          ).removeCustomer(customer.custId);

          // Navigate back to home page
          Navigator.pop(context);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${customer.custName} deleted successfully',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    result.detailedMessage,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      // Hide loading indicator if still showing
      if (mounted) {
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting customer: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDeleteDialog(customer) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Customer'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Are you sure you want to delete ${customer.custName}?',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  'This will permanently delete:',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                const Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('• Customer record', style: TextStyle(fontSize: 13)),
                      Text('• All associated loans', style: TextStyle(fontSize: 13)),
                      Text('• All interest payments', style: TextStyle(fontSize: 13)),
                      Text('• All deposit records', style: TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'The customer will be moved to history. This action cannot be undone.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _deleteCustomer(customer);
                },
                child: const Text(
                  'Delete All',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String amount,
    Color color,
    IconData icon,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isSmallScreen = screenWidth < 400;
        final cardWidth = isSmallScreen ? 120.0 : 140.0;
        final iconSize = isSmallScreen ? 24.0 : 28.0;
        final amountFontSize = isSmallScreen ? 14.0 : 16.0;
        final titleFontSize = isSmallScreen ? 11.0 : 13.0;
        final padding = isSmallScreen ? 12.0 : 16.0;

        return Container(
          width: cardWidth,
          margin: const EdgeInsets.only(right: 12),
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.1)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: iconSize),
              SizedBox(height: isSmallScreen ? 8 : 10),
              Text(
                amount,
                style: TextStyle(
                  fontSize: amountFontSize,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: isSmallScreen ? 4 : 6),
              Text(
                title,
                style: TextStyle(fontSize: titleFontSize, color: Colors.grey[600]),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInterestSummaryCard(String title, dynamic totalInterest) {
    final interestData = AmountFormatter.formatInterestWithAdvancePayment(
      totalInterest,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isSmallScreen = screenWidth < 400;
        final cardWidth = isSmallScreen ? 120.0 : 140.0;
        final iconSize = isSmallScreen ? 24.0 : 28.0;
        final amountFontSize = isSmallScreen ? 14.0 : 16.0;
        final titleFontSize = isSmallScreen ? 11.0 : 13.0;
        final padding = isSmallScreen ? 12.0 : 16.0;

        return Container(
          width: cardWidth,
          margin: const EdgeInsets.only(right: 12),
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: (interestData['color'] as Color).withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: (interestData['color'] as Color).withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                interestData['icon'] as IconData,
                color: interestData['color'] as Color,
                size: iconSize,
              ),
              SizedBox(height: isSmallScreen ? 8 : 10),
              Text(
                interestData['amount'] as String,
                style: TextStyle(
                  fontSize: amountFontSize,
                  fontWeight: FontWeight.bold,
                  color: interestData['color'] as Color,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: isSmallScreen ? 4 : 6),
              Text(
                title,
                style: TextStyle(fontSize: titleFontSize, color: Colors.grey[600]),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _generatePDF(customer) async {
    try {
      // Generating PDF - no loading indicator as per user preference

      // Get current totals from loan provider before async operations
      final loanProvider = Provider.of<LoanProvider>(context, listen: false);
      final totals = loanProvider.totals;

      print('Fetching loan data for customer: ${customer.custName}');
      final data = await fetchAllLoansByUserAndCustomer(
        custId: int.parse(customer.custId.toString()),
        userId: int.parse(customer.userId.toString()),
      );

      print('Loan data fetched, count: ${data.length}');
      await generatePdfForPerticulatCustomer(
        data: data,
        customerName: customer.custName,
        totals: totals,
        customerPhone: customer.custPhn,
      );

      // PDF generated successfully - no snackbar message as per user preference
    } catch (e) {
      print('PDF generation error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate PDF: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _refreshLoanData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("userId");

    if (userId != null && mounted) {
      try {
        // Show loading indicator
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 12),
                Text('Refreshing loan data...'),
              ],
            ),
            backgroundColor: Colors.blueGrey[700],
            duration: const Duration(seconds: 2),
          ),
        );

        // Refresh loan data
        await Provider.of<LoanProvider>(context, listen: false)
            .fetchLoanDetailList(userId, widget.custId);

        // Also refresh the profile provider to update profile screen amounts
        if (mounted) {
          await Provider.of<ProfileProvider>(context, listen: false).fetchMoneyInfo();
        }

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Loan data refreshed successfully'),
              backgroundColor: Colors.green[600],
              duration: const Duration(seconds: 1),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to refresh: $e'),
              backgroundColor: Colors.red[600],
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  Future<void> _navigateToAddLoan(customer) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ApplyLoan(customerId: customer.custId),
      ),
    );

    if (result == 'loan_added' && mounted) {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString("userId");
      if (userId != null && mounted) {
        Provider.of<LoanProvider>(
          context,
          listen: false,
        ).fetchLoanDetailList(userId, widget.custId);

        // Also refresh the profile provider to update profile screen amounts
        if (mounted) {
          Provider.of<ProfileProvider>(context, listen: false).fetchMoneyInfo();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final customer = Provider.of<CustomerProvider>(
      context,
    ).getCustomerById(widget.custId);

    if (customer == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Customer Not Found"),
          backgroundColor: Colors.blueGrey[700],
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              // Ensure safe navigation back to home
              Navigator.of(context).pop();
            },
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_off, size: 80, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                "Customer not found",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Customer ID: ${widget.custId}",
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () async {
                  // Refresh customer list and try again
                  final prefs = await SharedPreferences.getInstance();
                  final userId = prefs.getString("userId");
                  if (userId != null && mounted) {
                    await Provider.of<CustomerProvider>(
                      context,
                      listen: false,
                    ).fetchCustomerList(userId);
                    setState(() {}); // Trigger rebuild
                  }
                },
                icon: const Icon(Icons.refresh),
                label: const Text("Refresh"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey[700],
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blueGrey[700],
        foregroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context, 'Success');
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: Text(
          customer.custName,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            onPressed: () => _makePhoneCall(customer.custPhn),
            icon: const Icon(Icons.phone),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) async {
              if (value == 'edit') {
                final updated = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditContact(customer: customer),
                  ),
                );
                if (updated == true) setState(() {});
              } else if (value == 'delete') {
                _showDeleteDialog(customer);
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(Icons.edit, color: Colors.blueGrey),
                      title: Text('Edit Customer'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete, color: Colors.red),
                      title: Text('Delete Customer'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Modern Customer Header Card - Responsive design
          LayoutBuilder(
            builder: (context, constraints) {
              final screenWidth = MediaQuery.of(context).size.width;
              final isSmallScreen = screenWidth < 400;
              final margin = isSmallScreen ? 12.0 : 16.0;
              final padding = isSmallScreen ? 16.0 : 20.0;

              return Container(
                margin: EdgeInsets.all(margin),
                padding: EdgeInsets.all(padding),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
            child: Column(
              children: [
                // Customer Info Row - Responsive Layout to prevent overflow
                LayoutBuilder(
                  builder: (context, constraints) {
                    final screenWidth = MediaQuery.of(context).size.width;
                    final isSmallScreen = screenWidth < 400;
                    final avatarSize = isSmallScreen ? 80.0 : 100.0;
                    final fontSize = isSmallScreen ? 18.0 : 22.0;

                    return Row(
                      children: [
                        // Large Customer Avatar
                        Container(
                          width: avatarSize,
                          height: avatarSize,
                          decoration: BoxDecoration(
                            color: Colors.blueGrey[100],
                            borderRadius: BorderRadius.circular(avatarSize / 2),
                            border: Border.all(
                              color: Colors.blueGrey[300]!,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withValues(alpha: 0.3),
                                spreadRadius: 2,
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child:
                              customer.custPic != null &&
                                      customer.custPic!.isNotEmpty
                                  ? GestureDetector(
                                    onTap:
                                        () => _showFullScreenImage(
                                          customer.custPic!,
                                          customer.custName,
                                        ),
                                    child: Stack(
                                      children: [
                                        ClipOval(
                                          child: Image.network(
                                            "${UrlConstant.showImage}/${customer.custPic}",
                                            width: avatarSize,
                                            height: avatarSize,
                                            fit: BoxFit.cover,
                                            errorBuilder: (
                                              context,
                                              error,
                                              stackTrace,
                                            ) {
                                              return Container(
                                                width: avatarSize,
                                                height: avatarSize,
                                                decoration: BoxDecoration(
                                                  color: Colors.blueGrey[300],
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    customer.custName.isNotEmpty
                                                        ? customer.custName[0]
                                                            .toUpperCase()
                                                        : '',
                                                    style: TextStyle(
                                                      fontSize: avatarSize * 0.4,
                                                      color: Colors.black,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        // Subtle tap indicator
                                        Positioned(
                                          bottom: 2,
                                          right: 2,
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withValues(
                                                alpha: 0.6,
                                              ),
                                              borderRadius: BorderRadius.circular(
                                                12,
                                              ),
                                            ),
                                            child: const Icon(
                                              Icons.zoom_in,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                  : Container(
                                    width: avatarSize,
                                    height: avatarSize,
                                    decoration: BoxDecoration(
                                      color: Colors.blueGrey[300],
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        customer.custName.isNotEmpty
                                            ? customer.custName[0].toUpperCase()
                                            : '',
                                        style: TextStyle(
                                          fontSize: avatarSize * 0.4,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                        ),
                        const SizedBox(width: 16),
                        // Customer Details - Flexible to prevent overflow
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                customer.custName,
                                style: TextStyle(
                                  fontSize: fontSize,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                customer.custPhn,
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 14.0 : 16.0,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              // Customer Address - Show if available
                              if (customer.custAddress != null &&
                                  customer.custAddress!.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  customer.custAddress!,
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 12.0 : 14.0,
                                    color: Colors.grey[500],
                                    fontStyle: FontStyle.italic,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Action Buttons - Separate row to prevent overflow
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Flexible(
                      child: _buildActionButton(
                        icon: Icons.picture_as_pdf,
                        color: Colors.red,
                        onTap: () => _generatePDF(customer),
                      ),
                    ),
                    Flexible(
                      child: Consumer<LoanProvider>(
                        builder: (context, loanProvider, child) {
                          return _buildActionButton(
                            icon: FontAwesomeIcons.whatsapp,
                            color: Colors.green,
                            onTap:
                                () => _sendWhatsAppPaymentReminder(
                                  customer,
                                  loanProvider.totals,
                                ),
                          );
                        },
                      ),
                    ),
                    Flexible(
                      child: Consumer<LoanProvider>(
                        builder: (context, loanProvider, child) {
                          return _buildActionButton(
                            icon: Icons.message,
                            color: Colors.blue,
                            onTap:
                                () => _sendSMSMessage(
                                  customer,
                                  loanProvider.totals,
                                ),
                          );
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Financial Summary Cards - Real-time updates with responsive design
                Consumer<LoanProvider>(
                  builder: (context, loanProvider, child) {
                    final totals = loanProvider.totals;
                    final screenWidth = MediaQuery.of(context).size.width;
                    final isSmallScreen = screenWidth < 400;

                    return SizedBox(
                      height: isSmallScreen ? 110 : 120,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        physics: const BouncingScrollPhysics(),
                        children: [
                          _buildSummaryCard(
                            'Total Amount',
                            AmountFormatter.formatCurrency(
                              totals['totalAmount'],
                            ),
                            Colors.red,
                            Icons.account_balance_wallet,
                          ),
                          _buildInterestSummaryCard(
                            'Interest',
                            totals['totalInterest'],
                          ),
                          _buildSummaryCard(
                            'Total Due',
                            AmountFormatter.formatCurrency(totals['totalDue']),
                            Colors.blueGrey,
                            Icons.payment,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            );
            },
          ),

          // Loans Section Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Loan List',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Refresh button
                    IconButton(
                      onPressed: () => _refreshLoanData(),
                      icon: const Icon(Icons.refresh, size: 20),
                      tooltip: 'Refresh Loans',
                      style: IconButton.styleFrom(
                        foregroundColor: Colors.blueGrey[700],
                      ),
                    ),
                    // Add loan button
                    TextButton.icon(
                      onPressed: () => _navigateToAddLoan(customer),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Loan'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blueGrey[700],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Loans List
          Expanded(
            child: LoanList(custId: customer.custId, customer: customer),
          ),
        ],
      ),
    );
  }
}
