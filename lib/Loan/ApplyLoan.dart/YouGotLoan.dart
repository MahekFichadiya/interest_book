import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:interest_book/Api/add_loan_api.dart';
import 'package:interest_book/Provider/loan_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../image_picker/screen/select_photo_options_screen.dart';
import 'package:intl/intl.dart';

class YouGotLone extends StatefulWidget {
  final String? customerId;
  const YouGotLone({super.key, required this.customerId});

  @override
  State<YouGotLone> createState() => _YouGotLoneState();
}

class _YouGotLoneState extends State<YouGotLone> {
  final amountController = TextEditingController();
  final rateController = TextEditingController();
  final yearController = TextEditingController();
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();
  final noteController = TextEditingController();
  final formkey = GlobalKey<FormState>();
  String? userId = " ";
  String? custId = " ";

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

  //for the take picture
  File? _image;

  Future _pickImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;
      setState(() {
        _image = File(image.path);
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
                      prefixIcon: Icon(Icons.attach_money_rounded),
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
                    validator: (value) {
                      if (value!.isEmpty) {
                        return null;
                      }
                      final startDate =
                          DateTime.tryParse(startDateController.text);
                      final endDate = DateTime.tryParse(value);
                      if (startDate != null &&
                          endDate != null &&
                          endDate.isBefore(startDate)) {
                        return "End date must be after start date";
                      }
                      return null;
                    },
                    onTap: () => _selectEndDate(context),
                  ),
                  TextFormField(
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText:
                          _image == null ? "Select Image" : "Change Image",
                      prefixIcon: const Icon(Icons.camera_alt_outlined),
                    ),
                    onTap: () {
                      _showSelectPhotoOptions(context);
                    },
                    validator: (_) {
                      if (_image == null) {
                        return "Please select an image";
                      }
                      return null;
                    },
                  ),
                  _image == null
                      ? const SizedBox(height: 0)
                      : Container(
                          padding: const EdgeInsets.only(top: 20, bottom: 10),
                          child: Image.file(
                            _image!,
                            height: 300,
                            width: 300,
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
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: GestureDetector(
                      onTap: () async {
                        if (formkey.currentState!.validate()) {
                          formkey.currentState!.save();
                          final String formattedStartDate =
                              getFormattedStartDateForMySQL(
                                  startDateController.text);

                          final String formattedEndDate =
                              getFormattedEndDateForMySQL(
                                  endDateController.text);

                          print(amountController.text);
                          print(rateController.text);
                          print(formattedStartDate);
                          print(getFormattedEndDateForMySQL(
                              endDateController.text));
                          print(_image);
                          print(noteController.text);
                          print(userId);
                          print(custId);

                          try {
                            var loan = await Addloanapi().newLoan(
                                amountController.text,
                                rateController.text,
                                formattedStartDate,
                                formattedEndDate,
                                _image,
                                noteController.text,
                                '0',
                                userId!,
                                custId!,
                                loanProvider);
                            formkey.currentState!.reset();
                            amountController.clear();
                            rateController.clear();
                            startDateController.clear();
                            endDateController.clear();
                            noteController.clear();
                            if (loan) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Loan Added...")),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Failed to add loan")),
                              );
                            }

                            Navigator.pop(context, 'loan_added');
                          } catch (e) {
                            print("Error: $e");
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
                            // color: Colors.white,
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
    ));
  }
}
