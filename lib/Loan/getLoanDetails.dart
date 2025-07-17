import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:interest_book/Api/UrlConstant.dart';
import 'package:interest_book/Api/remove_loan.dart';
import 'package:interest_book/Api/loan_document_api.dart';
import 'package:interest_book/DashboardScreen.dart';
import 'package:interest_book/Loan/DepositeAmount/InterestDashboard.dart';
import 'package:interest_book/Loan/EditLoan.dart';
import 'package:interest_book/Model/CustomerModel.dart';
import 'package:interest_book/Model/LoanDetail.dart';
import 'package:interest_book/Model/LoanDocument.dart';
import 'package:interest_book/Provider/customer_provider.dart';
import 'package:interest_book/Widgets/enhanced_loan_deletion_dialog.dart';
import 'package:interest_book/Widgets/loan_document_full_screen_viewer.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GetLoanDetails extends StatefulWidget {
  final Loandetail? detail;
  final Customer customer;
  const GetLoanDetails(
      {super.key, required this.detail, required this.customer});

  @override
  State<GetLoanDetails> createState() => _GetLoanDetailsState();
}

class _GetLoanDetailsState extends State<GetLoanDetails> {
  List<LoanDocument> loanDocuments = [];
  bool isLoadingDocuments = false;

  @override
  void initState() {
    super.initState();
    _loadLoanDocuments();
  }

  Future<void> _loadLoanDocuments() async {
    if (widget.detail == null) return;

    setState(() => isLoadingDocuments = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString("userId");

      if (userId != null) {
        final documents = await LoanDocumentApi().getLoanDocuments(
          widget.detail!.loanId,
          userId
        );

        if (mounted) {
          setState(() {
            loanDocuments = documents;
            isLoadingDocuments = false;
          });
        }
      }
    } catch (e) {
      print("Error loading loan documents: $e");
      if (mounted) {
        setState(() {
          isLoadingDocuments = false;
        });
      }
    }
  }

  Widget _buildDocumentsPreview() {
    if (isLoadingDocuments) {
      return const SizedBox(
        width: 50,
        height: 50,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (loanDocuments.isEmpty) {
      return const Icon(
        Icons.folder_open_outlined,
        size: 50,
        color: Colors.grey,
      );
    }

    if (loanDocuments.length == 1) {
      return GestureDetector(
        onTap: () => _showDocumentsScreen(),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            LoanDocumentApi.getDocumentUrl(loanDocuments[0].documentPath),
            height: 50,
            width: 50,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.broken_image_outlined,
                size: 50,
                color: Colors.grey,
              );
            },
          ),
        ),
      );
    }

    // Multiple documents - show stack
    return GestureDetector(
      onTap: () => _showDocumentsScreen(),
      child: Stack(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                LoanDocumentApi.getDocumentUrl(loanDocuments[0].documentPath),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.folder_outlined,
                    size: 30,
                    color: Colors.grey,
                  );
                },
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${loanDocuments.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDocumentsScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DocumentsViewScreen(
          documents: loanDocuments,
          loanDetail: widget.detail!,
        ),
      ),
    );
  }

  String monthDifference(String? sDate, String? eDate) {
    if (sDate == null || eDate == null || eDate == "0000-00-00") {
      return "N/A";
    }

    DateTime startDate = DateTime.parse(sDate);
    DateTime endDate = DateTime.parse(eDate);

    int yearDiff = endDate.year - startDate.year;
    int monthDiff = endDate.month - startDate.month;

    return (yearDiff * 12 + monthDiff).toString();
  }

  String? formateDate(String Date) {
    try {
      DateTime parse = DateTime.parse(Date);
      return DateFormat('dd-MM-yyyy hh:mm a').format(parse);
    } catch (e) {
      return Date;
    }
  }

  String? formateEndDate(String Date) {
    try {
      DateTime parse = DateTime.parse(Date);
      return DateFormat('dd-MM-yyyy').format(parse);
    } catch (e) {
      return Date;
    }
  }

  String formatAmount(double value) {
    return value.toInt().toString();
  }

  Future<void> _deleteLoanWithConfirmation(bool confirmCustomerDeletion) async {
    try {
      final result = await RemoveLoan().remove(
        widget.detail!.loanId,
        confirmCustomerDeletion: confirmCustomerDeletion,
      );

      if (!mounted) return;

      if (result.success) {
        // If customer was deleted, remove from customer provider
        if (result.customerDeleted && result.customerId != null) {
          Provider.of<CustomerProvider>(context, listen: false)
              .removeCustomer(result.customerId!);
        }

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.customerDeleted
              ? 'Loan deleted and customer removed (no remaining loans)'
              : 'Loan successfully deleted'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: result.customerDeleted ? 4 : 3),
          ),
        );

        // Always navigate to dashboard (shows customer list) after loan deletion
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const DashboardScreen(),
          ),
          (route) => false,
        );
      } else if (result.confirmationRequired) {
        // Show enhanced confirmation dialog with three options
        final choice = await EnhancedLoanDeletionDialog.show(
          context: context,
          customerName: widget.customer!.custName,
        );

        if (choice == LoanDeletionChoice.deleteBoth) {
          // User wants to delete both loan and customer
          await _deleteLoanWithConfirmation(true);
        } else if (choice == LoanDeletionChoice.deleteLoanOnly) {
          // User wants to delete loan only, keep customer
          final result = await RemoveLoan().remove(
            widget.detail!.loanId,
            deleteLoanOnly: true,
          );

          if (mounted && result.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result.message),
                backgroundColor: Colors.green,
              ),
            );

            // Navigate to dashboard
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const DashboardScreen(),
              ),
              (route) => false,
            );
          }
        } else {
          // User cancelled, show message that loan was not deleted
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Loan deletion cancelled'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error deleting loan'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Entry Detail"),
        backgroundColor: Colors.blueGrey.shade300,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => EditLoan(
                    customer: widget.customer,
                    details: widget.detail!,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            onPressed: () async {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text("Do you want to sattle loan?"),
                    actions: [
                      TextButton(
                        onPressed: () async {
                          Navigator.of(context).pop(); // Close the dialog first
                          await _deleteLoanWithConfirmation(false);
                        },
                        child: const Text('Yes'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cancle'),
                      ),
                    ],
                  );
                },
              );
            },
            icon: const Icon(
              Icons.delete,
              size: 27,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 10, top: 20),
              child: Text(
                "${widget.customer.custName} Took",
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                "₹${widget.detail?.amount}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  color: Colors.red,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                "On ${formateDate(widget.detail!.startDate) ?? 'N/A'}", // Handle null case
                style: const TextStyle(
                  color: Colors.black45,
                  fontSize: 15,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text(
                "Remaining Balance: ₹${widget.detail?.updatedAmount}",
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.red,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const Divider(
              color: Colors.black,
              height: 2,
            ),
            const Padding(
              padding: EdgeInsets.only(
                top: 10,
                bottom: 10,
                left: 8,
                right: 8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total Deposit Amount",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    "₹0",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(
              color: Colors.black,
              height: 2,
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 10,
                bottom: 10,
                left: 8,
                right: 8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Return Date",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    formateEndDate(widget.detail!.endDate == "0000-00-00"
                            ? "N/A"
                            : widget.detail!.endDate) ??
                        'N/A', // Handle null case
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(
              color: Colors.black,
              height: 2,
            ),
            Padding(
              padding: EdgeInsets.only(
                top: 10,
                bottom: 10,
                left: 8,
                right: 8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Interest",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    "₹${formatAmount(double.parse(widget.detail!.totalInterest))}",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(
              color: Colors.black,
              height: 2,
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 10,
                bottom: 10,
                left: 8,
                right: 8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Months",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    monthDifference(
                      widget.detail?.startDate,
                      widget.detail?.endDate,
                    ),
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(
              color: Colors.black,
              height: 2,
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 10,
                bottom: 10,
                left: 8,
                right: 8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Rate",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    "${widget.detail!.rate}%",
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(
              color: Colors.black,
              height: 2,
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 10,
                bottom: 10,
                left: 8,
                right: 8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Note",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    widget.detail!.note,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Divider(
              color: Colors.black,
              height: 2,
            ),
            const Padding(
              padding: EdgeInsets.only(
                top: 10,
                bottom: 10,
                left: 8,
                right: 8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total Deposite Interest",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    "₹0",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black54,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(
              color: Colors.black,
              height: 2,
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 10,
                bottom: 10,
                left: 8,
                right: 8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Documents",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  _buildDocumentsPreview(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 20, left: 20),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => Depositeinterest(
                        detail: widget.detail,
                      ),
                    ),
                  );
                },
                child: Container(
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      width: 2,
                      color: Colors.black,
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      "Deposite Amount",
                      style: TextStyle(
                        color: Colors.blueGrey,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DocumentsViewScreen extends StatelessWidget {
  final List<LoanDocument> documents;
  final Loandetail loanDetail;

  const DocumentsViewScreen({
    super.key,
    required this.documents,
    required this.loanDetail
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Loan Documents (${documents.length})'),
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body: documents.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.folder_open_outlined,
                    size: 100,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    "No documents available",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: documents.length,
              itemBuilder: (context, index) {
                final document = documents[index];
                return GestureDetector(
                  onTap: () => _showFullScreenDocument(context, document),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.2),
                          spreadRadius: 2,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        children: [
                          Image.network(
                            LoanDocumentApi.getDocumentUrl(document.documentPath),
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[200],
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.broken_image_outlined,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Failed to load',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(12),
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
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showFullScreenDocument(BuildContext context, LoanDocument document) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LoanDocumentFullScreenViewer(
          document: document,
        ),
      ),
    );
  }
}
