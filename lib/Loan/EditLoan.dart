import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:interest_book/Api/UrlConstant.dart';
import 'package:interest_book/Api/update_loan_api.dart';
import 'package:interest_book/Api/loan_document_api.dart';
import 'package:interest_book/Loan/LoanDashborad/LoanDashborad.dart';
import 'package:interest_book/Model/CustomerModel.dart';
import 'package:interest_book/Model/LoanDetail.dart';
import 'package:interest_book/Model/LoanDocument.dart';
import 'package:interest_book/Provider/loan_provider.dart';
import 'package:interest_book/Provider/profile_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'image_picker/screen/select_photo_options_screen.dart';
import 'package:provider/provider.dart';


class EditLoan extends StatefulWidget {
  final Customer customer;
  final Loandetail details;
  const EditLoan({super.key, required this.customer, required this.details});

  @override
  State<EditLoan> createState() => _EditLoanState();
}

class _EditLoanState extends State<EditLoan> {
  final formKey = GlobalKey<FormState>();
  TextEditingController amountController = TextEditingController();
  TextEditingController rateController = TextEditingController();
  TextEditingController yearController = TextEditingController();
  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  String? userId = ' ';
  String? custId = ' ';
  List<LoanDocument> _existingDocuments = [];
  List<File> _newDocuments = [];
  bool _isLoadingDocuments = false;

  // loadData() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   userId = prefs.getString("userId");
  //   custId = widget.customer.custId;

  //   // Format start date
  //   if (widget.details.startDate.isNotEmpty) {
  //     try {
  //       final DateTime parsedStartDate = DateFormat(
  //         "yyyy-MM-dd HH:mm:ss",
  //       ).parse(widget.details.startDate);
  //       startDateController.text = DateFormat(
  //         "dd/MM/yyyy hh:mm a",
  //       ).format(parsedStartDate);
  //     } catch (e) {
  //       print("Error parsing start date: $e");
  //       startDateController.text = "";
  //     }
  //   }

  //   // Format end date
  //   if (widget.details.endDate.isNotEmpty &&
  //       widget.details.endDate != '0000-00-00') {
  //     try {
  //       final DateTime parsedEndDate = DateFormat(
  //         "yyyy-MM-dd",
  //       ).parse(widget.details.endDate);
  //       endDateController.text = DateFormat("dd/MM/yyyy").format(parsedEndDate);
  //     } catch (e) {
  //       print("Error parsing end date: $e");
  //       endDateController.text = "";
  //     }
  //   }

  //   // Set other field values
  //   amountController.text = widget.details.amount;
  //   rateController.text = widget.details.rate;
  //   noteController.text = widget.details.note;

  //   // Handle image
  //   if (widget.details.image.isNotEmpty) {
  //     _image = File(widget.details.image);
  //   }

  //   if (mounted) setState(() {});
  //   // setState(() {});
  // }
  loadData() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString("userId");
    custId = widget.customer.custId;

    // Format start date
    if (widget.details.startDate.isNotEmpty) {
      try {
        final DateTime parsedStartDate = DateFormat(
          "yyyy-MM-dd HH:mm:ss",
        ).parse(widget.details.startDate);
        startDateController.text = DateFormat(
          "dd/MM/yyyy hh:mm a",
        ).format(parsedStartDate);
      } catch (e) {
        // Handle date parsing error silently
        startDateController.text = "";
      }
    }

    // Format end date
    if (widget.details.endDate.isNotEmpty &&
        widget.details.endDate != '0000-00-00') {
      try {
        final DateTime parsedEndDate = DateFormat(
          "yyyy-MM-dd",
        ).parse(widget.details.endDate);
        endDateController.text = DateFormat("dd/MM/yyyy").format(parsedEndDate);
      } catch (e) {
        // Handle date parsing error silently
        endDateController.text = "";
      }
    }

    // Set other field values
    amountController.text = widget.details.amount;
    rateController.text = widget.details.rate;
    noteController.text = widget.details.note;

    if (mounted) setState(() {});
  }

  @override
  void initState() {
    loadData();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load documents after userId is available
    if (userId != null && userId!.trim().isNotEmpty) {
      _loadExistingDocuments();
    }
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? startDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (startDate != null) {
      final DateTime now = DateTime.now();
      final DateTime fullDateTime = DateTime(
        startDate.year,
        startDate.month,
        startDate.day,
        now.hour,
        now.minute,
      );

      final String formattedDateTime = DateFormat(
        "dd/MM/yyyy hh:mm a",
      ).format(fullDateTime);

      setState(() {
        startDateController.text = formattedDateTime;
      });
    }
  }

  String getFormattedStartDateForMySQL(String dateTime) {
    final DateTime parsedDateTime = DateFormat(
      "dd/MM/yyyy hh:mm a",
    ).parse(dateTime);
    return DateFormat("yyyy-MM-dd HH:mm:ss").format(parsedDateTime);
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? endDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (endDate != null) {
      final String formattedDate = DateFormat("dd/MM/yyyy").format(endDate);

      setState(() {
        endDateController.text = formattedDate;
      });
    }
  }

  String getFormattedEndDateForMySQL(String date) {
    if (date.isNotEmpty) {
      final DateTime parsedDate = DateFormat("dd/MM/yyyy").parse(date);
      return DateFormat("yyyy-MM-dd").format(parsedDate);
    }
    return "";
  }

  // Load existing documents for this loan
  Future<void> _loadExistingDocuments() async {
    if (userId == null) return;

    setState(() {
      _isLoadingDocuments = true;
    });

    try {
      final documents = await LoanDocumentApi().getLoanDocuments(
        widget.details.loanId,
        userId!
      );
      setState(() {
        _existingDocuments = documents;
        _isLoadingDocuments = false;
      });
    } catch (e) {
      print("Error loading documents: $e");
      setState(() {
        _isLoadingDocuments = false;
      });
    }
  }

  Future _pickImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;
      setState(() {
        _newDocuments.add(File(image.path));
        Navigator.of(context).pop();
      });
    } on PlatformException {
      Navigator.of(context).pop();
    }
  }

  Future _pickMultipleImages() async {
    try {
      final List<XFile> images = await ImagePicker().pickMultipleMedia();
      if (images.isEmpty) return;
      setState(() {
        for (var image in images) {
          _newDocuments.add(File(image.path));
        }
      });
    } on PlatformException catch (e) {
      print("Error picking multiple images: $e");
    }
  }

  void _removeNewDocument(int index) {
    setState(() {
      _newDocuments.removeAt(index);
    });
  }

  Future<void> _removeExistingDocument(LoanDocument document) async {
    if (userId == null) return;

    try {
      bool success = await LoanDocumentApi().deleteLoanDocument(
        document.documentId.toString(),
        userId!
      );

      if (success) {
        setState(() {
          _existingDocuments.removeWhere((doc) => doc.documentId == document.documentId);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Document deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to delete document'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print("Error deleting document: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting document: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showSelectPhotoOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.28,
            maxChildSize: 0.4,
            minChildSize: 0.28,
            expand: false,
            builder: (context, scrollController) {
              return SelectPhotoOptionsScreen(onTap: _pickImage);
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Edit Loan'),
        backgroundColor: Colors.blueGrey.shade600,
        leading: IconButton(
          onPressed: () {
            showDialog(
              barrierDismissible: false,
              context: context,
              builder:
                  (context) => AlertDialog(
                    title: const Text("Cancel update?"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder:
                                  (context) => Loandashboard(
                                    custId: widget.customer.custId!,
                                  ),
                            ),
                            (route) => false,
                          );
                        },
                        child: const Text("YES"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('NO'),
                      ),
                    ],
                  ),
            );
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(
                        amountController,
                        "Amount",
                        Icons.currency_rupee,
                        TextInputType.number,
                      ),
                      _buildTextField(
                        rateController,
                        "Rate",
                        Icons.percent_rounded,
                        TextInputType.number,
                      ),
                      _buildDateField(
                        startDateController,
                        "Opening Date",
                        context,
                        _selectStartDate,
                      ),
                      _buildDateField(
                        endDateController,
                        "Return Date (Optional)",
                        context,
                        _selectEndDate,
                        isOptional: true,
                      ),
                      _buildDocumentsSection(),
                      const SizedBox(height: 10),
                      _buildTextField(
                        noteController,
                        "Note",
                        Icons.event_note_outlined,
                        TextInputType.text,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            GestureDetector(
              onTap: _onSave,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: Colors.blueGrey.shade600,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Center(
                  child: Text(
                    'Save',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
    TextInputType keyboardType,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (value) {
          if (value!.isEmpty) return "Field can't be empty";
          return null;
        },
      ),
    );
  }

  Widget _buildDateField(
    TextEditingController controller,
    String hint,
    BuildContext context,
    Function(BuildContext) onTap, {
    bool isOptional = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: hint,
          prefixIcon: const Icon(Icons.calendar_month_outlined),
          suffixIcon: isOptional && controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      controller.clear();
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onTap: () => onTap(context),
        validator: (value) {
          if (isOptional) {
            return null; // No validation for optional fields
          }
          return value!.isEmpty ? "Please select a date" : null;
        },
      ),
    );
  }

  Widget _buildDocumentsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.attach_file),
                const SizedBox(width: 8),
                Text(
                  'Loan Documents',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Existing documents section
            if (_isLoadingDocuments)
              const Center(child: CircularProgressIndicator())
            else if (_existingDocuments.isNotEmpty) ...[
              Text(
                'Existing Documents (${_existingDocuments.length})',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.blueGrey,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _existingDocuments.length,
                  itemBuilder: (context, index) {
                    final document = _existingDocuments[index];
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              LoanDocumentApi.getDocumentUrl(document.documentPath),
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.image_not_supported),
                                );
                              },
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => _removeExistingDocument(document),
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],

            // New documents section
            if (_newDocuments.isNotEmpty) ...[
              Text(
                'New Documents (${_newDocuments.length})',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _newDocuments.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              _newDocuments[index],
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => _removeNewDocument(index),
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Add documents buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showSelectPhotoOptions(context),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Add Single'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickMultipleImages,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Add Multiple'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildImagePreview() {
  //   if (_localImage != null) {
  //     return Image.file(
  //       _localImage!,
  //       height: 250,
  //       width: double.infinity,
  //       fit: BoxFit.cover,
  //     );
  //   } else if (_image != null) {
  //     print("${UrlConstant.showImage}/${widget.details.image}");
  //     return Image.network(
  //       "${UrlConstant.showImage}/${widget.details.image}",
  //       errorBuilder: (context, error, stackTrace) {
  //         return Center(
  //           child: Column(
  //             children: [
  //               Icon(Icons.image_not_supported, size: 100, color: Colors.grey),
  //               SizedBox(height: 16),
  //               Text(
  //                 "Image not available",
  //                 style: TextStyle(
  //                   fontWeight: FontWeight.w500,
  //                   fontSize: 16,
  //                   color: Colors.grey,
  //                 ),
  //               ),
  //               SizedBox(height: 8),
  //               Text(
  //                 "The image could not be loaded.",
  //                 style: TextStyle(fontSize: 14, color: Colors.grey),
  //               ),
  //             ],
  //           ),
  //         );
  //       },
  //       height: 250,
  //       width: double.infinity,
  //       fit: BoxFit.cover,
  //     );
  //     // return Image.network(
  //     //   "${UrlConstant.showImage}/${widget.details.image}",
  //     //   height: 250,
  //     //   width: double.infinity,
  //     //   fit: BoxFit.cover,
  //     // );
  //   } else {
  //     return Container(
  //       height: 250,
  //       width: double.infinity,
  //       color: Colors.grey.shade200,
  //       child: const Icon(Icons.image, size: 100, color: Colors.grey),
  //     );
  //   }
  // }
  // Image preview method removed - now handled in documents section

  // void _onSave() async {
  //   if (formKey.currentState!.validate()) {
  //     // Show loading indicator
  //     showDialog(
  //       context: context,
  //       barrierDismissible: false,
  //       builder: (BuildContext context) {
  //         return const Center(child: CircularProgressIndicator());
  //       },
  //     );

  //     try {
  //       // Determine which image to send
  //       File? imageToSend;
  //       if (_localImage != null) {
  //         imageToSend = _localImage;
  //       } else if (_image != null) {
  //         imageToSend = _image;
  //       }

  //       var success = await updateLoan(
  //         widget.details.loanId,
  //         amountController.text,
  //         rateController.text,
  //         startDateController.text,
  //         endDateController.text,
  //         imageToSend,
  //         noteController.text,
  //         userId!,
  //         custId!,
  //       );

  //       // Close loading dialog
  //       Navigator.pop(context);

  //       if (success) {
  //         // Also refresh the loan provider to update all screens
  //         final prefs = await SharedPreferences.getInstance();
  //         final userId = prefs.getString("userId");
  //         if (userId != null && mounted) {
  //           await Provider.of<LoanProvider>(
  //             context,
  //             listen: false,
  //           ).fetchLoanDetailList(userId, custId!);
  //         }

  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(content: Text("Loan updated successfully")),
  //         );

  //         // Return to previous screen with success result
  //         Navigator.pop(context, true);
  //       } else {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(content: Text("Failed to update loan")),
  //         );
  //       }
  //     } catch (e) {
  //       // Close loading dialog
  //       Navigator.pop(context);

  //       print("Error updating loan: $e");
  //       ScaffoldMessenger.of(
  //         context,
  //       ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
  //     }
  //   }
  // }
  void _onSave() async {
    if (formKey.currentState!.validate()) {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator());
        },
      );

      try {
        // Update loan with new documents
        var success = await updateLoan(
          widget.details.loanId,
          amountController.text,
          rateController.text,
          startDateController.text,
          endDateController.text,
          _newDocuments,
          noteController.text,
          userId!,
          custId!,
        );

        // If loan update is successful and there are new documents, add them via API
        if (success && _newDocuments.isNotEmpty) {
          try {
            await LoanDocumentApi().addMultipleLoanDocuments(
              widget.details.loanId,
              userId!,
              _newDocuments,
            );
            // Reload documents to show the newly added ones
            await _loadExistingDocuments();
            // Clear new documents list
            setState(() {
              _newDocuments.clear();
            });
          } catch (e) {
            print("Error adding documents: $e");
            // Continue even if document addition fails
          }
        }

        // Close loading dialog
        if (mounted) {
          Navigator.pop(context);
        }

        if (success) {
          // Also refresh the loan provider to update all screens
          final prefs = await SharedPreferences.getInstance();
          final userId = prefs.getString("userId");
          if (userId != null && mounted) {
            await Provider.of<LoanProvider>(
              context,
              listen: false,
            ).fetchLoanDetailList(userId, custId!);

            // Also refresh the profile provider to update profile screen amounts
            if (mounted) {
              await Provider.of<ProfileProvider>(
                context,
                listen: false,
              ).fetchMoneyInfo();
            }
          }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Loan updated successfully")),
            );

            // Navigate to LoanDashboard instead of just popping
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder:
                    (context) => Loandashboard(custId: widget.customer.custId!),
              ),
              (route) => false, // This removes all previous routes from the stack
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Failed to update loan")),
            );
          }
        }
      } catch (e) {
        // Close loading dialog
        if (mounted) {
          Navigator.pop(context);

          // Show a user-friendly error message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "An error occurred while updating the loan. Please try again.",
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
