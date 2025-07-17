import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:interest_book/Api/add_loan_api.dart';
import 'package:interest_book/Provider/loan_provider.dart';
import 'package:interest_book/Provider/profile_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../image_picker/screen/select_photo_options_screen.dart';
import 'package:intl/intl.dart';

class YouGaveLone extends StatefulWidget {
  final String? customerId;
  const YouGaveLone({super.key, required this.customerId});

  @override
  State<YouGaveLone> createState() => _YouGaveLoneState();
}

class _YouGaveLoneState extends State<YouGaveLone> {
  final amountController = TextEditingController();
  final rateController = TextEditingController();
  final yearController = TextEditingController();
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();
  final noteController = TextEditingController();
  final formkey = GlobalKey<FormState>();
  String? userId = " ";
  String? custId = " ";
  bool isSubmitting = false;
  String _selectedPaymentMethod = 'cash'; // Default to cash

  loadData() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString("userId");
    custId = widget.customerId;
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
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

      final String formattedDateTime =
          DateFormat("dd/MM/yyyy hh:mm a").format(fullDateTime);

      setState(() {
        startDateController.text = formattedDateTime;
      });
    }
  }

  String getFormattedStartDateForMySQL(String dateTime) {
    final DateTime parsedDateTime =
        DateFormat("dd/MM/yyyy hh:mm a").parse(dateTime);
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

  //for multiple documents
  List<File> _documents = [];

  Future _pickImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;
      setState(() {
        _documents.add(File(image.path));
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
          _documents.add(File(image.path));
        }
      });
    } on PlatformException catch (e) {
      print("Error picking multiple images: $e");
    }
  }

  void _removeDocument(int index) {
    setState(() {
      _documents.removeAt(index);
    });
  }

  void _showSelectPhotoOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25.0),
        ),
      ),
      builder: (context) => DraggableScrollableSheet(
          initialChildSize: 0.28,
          maxChildSize: 0.4,
          minChildSize: 0.28,
          expand: false,
          builder: (context, scrollController) {
            return SelectPhotoOptionsScreen(
              onTap: _pickImage,
            );
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    var loanProvider = Provider.of<LoanProvider>(context, listen: false);
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Form(
                key: formkey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        label: Text("Amount"),
                        prefixIcon: Icon(Icons.currency_rupee),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Field can't be empty";
                        }
                        final amount = double.tryParse(value);
                        if (amount == null || amount <= 0) {
                          return "Enter a valid positive number";
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: rateController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        label: Text("Rate"),
                        prefixIcon: Icon(Icons.percent_rounded),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Field can't be empty";
                        }
                        final rate = double.tryParse(value);
                        if (rate == null || rate < 0 || rate > 100) {
                          return "Enter a valid rate between 0 and 100";
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: startDateController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        hintText: "Opening Date",
                        prefixIcon: Icon(Icons.calendar_month_outlined),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please select a start date";
                        }
                        return null;
                      },
                      onTap: () => _selectStartDate(context),
                    ),
                    TextFormField(
                      controller: endDateController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        hintText: "Return Date (Optional)",
                        prefixIcon: Icon(Icons.calendar_month_outlined),
                      ),
                      onTap: () => _selectEndDate(context),
                    ),
                    // Documents selection section
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
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
                                'Loan Documents (${_documents.length})',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
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
                          if (_documents.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 100,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _documents.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    child: Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.file(
                                            _documents[index],
                                            width: 80,
                                            height: 80,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Positioned(
                                          top: 4,
                                          right: 4,
                                          child: GestureDetector(
                                            onTap: () => _removeDocument(index),
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
                          ],
                        ],
                      ),
                    ),
                    TextFormField(
                      controller: noteController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.event_note_outlined),
                        label: Text("Note"),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Field can't be empty";
                        }
                        return null;
                      },
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 16),
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Payment Mode',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.blueGrey,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Wrap(
                              spacing: 12,
                              alignment: WrapAlignment.start,
                              children: [
                              ChoiceChip(
                                label: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.money,
                                      size: 18,
                                      color: _selectedPaymentMethod == 'cash'
                                        ? Colors.white
                                        : Colors.blueGrey[700],
                                    ),
                                    const SizedBox(width: 8),
                                    const Text('Cash'),
                                  ],
                                ),
                                selected: _selectedPaymentMethod == 'cash',
                                onSelected: (selected) {
                                  setState(() => _selectedPaymentMethod = 'cash');
                                },
                                selectedColor: Colors.blueGrey[700],
                                labelStyle: TextStyle(
                                  color: _selectedPaymentMethod == 'cash'
                                    ? Colors.white
                                    : Colors.blueGrey[700],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              ChoiceChip(
                                label: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.credit_card,
                                      size: 18,
                                      color: _selectedPaymentMethod == 'online'
                                        ? Colors.white
                                        : Colors.blueGrey[700],
                                    ),
                                    const SizedBox(width: 8),
                                    const Text('Online'),
                                  ],
                                ),
                                selected: _selectedPaymentMethod == 'online',
                                onSelected: (selected) {
                                  setState(() => _selectedPaymentMethod = 'online');
                                },
                                selectedColor: Colors.blueGrey[700],
                                labelStyle: TextStyle(
                                  color: _selectedPaymentMethod == 'online'
                                    ? Colors.white
                                    : Colors.blueGrey[700],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: GestureDetector(
                        onTap: () async {
                          if (formkey.currentState!.validate()) {
                            setState(() => isSubmitting = true);

                            formkey.currentState!.save();
                            final String formattedStartDate =
                                getFormattedStartDateForMySQL(
                                    startDateController.text);

                            final String formattedEndDate =
                                getFormattedEndDateForMySQL(
                                    endDateController.text);

                            try {
                              var result = await Addloanapi().newLoan(
                                  amountController.text,
                                  rateController.text,
                                  formattedStartDate,
                                  formattedEndDate,
                                  _documents,
                                  noteController.text,
                                  '1',
                                  userId!,
                                  custId!,
                                  _selectedPaymentMethod,
                                  loanProvider);

                              if (result.success) {
                                formkey.currentState!.reset();
                                amountController.clear();
                                rateController.clear();
                                startDateController.clear();
                                endDateController.clear();
                                noteController.clear();
                                _documents.clear();

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(result.message)),
                                );
                              } else {
                                String errorMessage = result.message;
                                if (result.errorCode == "CUSTOMER_NOT_FOUND") {
                                  errorMessage = "Customer not found. Please refresh and try again.";
                                }

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(errorMessage),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }

                              if (mounted) {
                                await Provider.of<LoanProvider>(context,
                                        listen: false)
                                    .addNewLoanAndRefresh(
                                        userId: userId!, custId: custId!);

                                // Also refresh the profile provider to update profile screen amounts
                                if (mounted) {
                                  await Provider.of<ProfileProvider>(context, listen: false)
                                      .fetchMoneyInfo();
                                }
                              }

                              setState(() => isSubmitting = false);

                              Navigator.pop(context, 'loan_added');
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      "An error occurred while adding the loan"),
                                ),
                              );
                            }
                          }
                        },
                        child: Container(
                          height: 70,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                width: 2,
                              )),
                          child: const Center(
                            child: Text(
                              "SAVE",
                              style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueGrey),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
