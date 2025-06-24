import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:interest_book/Api/UrlConstant.dart';
import 'package:interest_book/Api/update_loan_api.dart';
import 'package:interest_book/Loan/LoanDashborad/LoanDashborad.dart';
import 'package:interest_book/Model/CustomerModel.dart';
import 'package:interest_book/Model/LoanDetail.dart';
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
  File? _image;
  File? _localImage;

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

  Future _pickImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;
      setState(() {
        _localImage = File(image.path);
        Navigator.of(context).pop();
      });
    } on PlatformException {
      Navigator.of(context).pop();
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
                        Icons.attach_money_rounded,
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
                      _buildImageSelector(),
                      const SizedBox(height: 10),
                      _buildImagePreview(),
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

  Widget _buildImageSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        readOnly: true,
        decoration: InputDecoration(
          labelText:
              (widget.details.image.isNotEmpty || _localImage != null)
                  ? "Change Image"
                  : "Select Image",
          prefixIcon: const Icon(Icons.camera_alt_outlined),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onTap: () => _showSelectPhotoOptions(context),
        validator: (_) {
          if (_image == null &&
              _localImage == null &&
              widget.details.image.isEmpty) {
            return "Please select an image";
          }
          return null;
        },
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
  Widget _buildImagePreview() {
    if (_localImage != null) {
      return Image.file(
        _localImage!,
        height: 250,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    } else if (widget.details.image.isNotEmpty) {
      // Construct the full image URL
      String imageUrl;
      // Check if the image path already contains the base URL
      if (widget.details.image.startsWith('http')) {
        imageUrl = widget.details.image;
      } else {
        // Ensure there's no double slash between base URL and image path
        final String imagePath =
            widget.details.image.startsWith('/')
                ? widget.details.image.substring(1)
                : widget.details.image;
        imageUrl = "${UrlConstant.showImage}/$imagePath";
      }

      return Image.network(
        imageUrl,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 250,
            width: double.infinity,
            color: Colors.grey.shade100,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.image_outlined,
                  size: 80,
                  color: Colors.blueGrey,
                ),
                const SizedBox(height: 16),
                const Text(
                  "Original image not available",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: Colors.blueGrey,
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
        height: 250,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    } else {
      return Container(
        height: 250,
        width: double.infinity,
        color: Colors.grey.shade200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_photo_alternate, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              "No image selected",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }
  }

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
        // Determine which image to send
        File? imageToSend;
        if (_localImage != null) {
          imageToSend = _localImage;
        } else if (_image != null) {
          imageToSend = _image;
        }

        var success = await updateLoan(
          widget.details.loanId,
          amountController.text,
          rateController.text,
          startDateController.text,
          endDateController.text,
          imageToSend,
          noteController.text,
          userId!,
          custId!,
        );

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
