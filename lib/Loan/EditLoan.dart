import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:interest_book/Api/UrlConstant.dart';
import 'package:interest_book/Api/updateLoanAPI.dart';
import 'package:interest_book/Loan/LoanDashborad/LoanDashborad.dart';
import 'package:interest_book/Model/CustomerModel.dart';
import 'package:interest_book/Model/LoanDetail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'image_picker/screen/select_photo_options_screen.dart';

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

  loadData() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString("userId");
    custId = widget.customer.custId;

    if (widget.details.startDate.isNotEmpty) {
      final DateTime parsedStartDate =
          DateFormat("yyyy-MM-dd HH:mm:ss").parse(widget.details.startDate);
      startDateController.text =
          DateFormat("dd/MM/yyyy hh:mm a").format(parsedStartDate);
    }

    if (widget.details.endDate.isNotEmpty &&
        widget.details.endDate != '0000/00/00') {
      final DateTime parsedEndDate =
          DateFormat("yyyy-MM-dd").parse(widget.details.endDate);
      endDateController.text = DateFormat("dd/MM/yyyy").format(parsedEndDate);
    }

    amountController.text = widget.details.amount;
    rateController.text = widget.details.rate;
    noteController.text = widget.details.note;

    if (widget.details.image.isNotEmpty) {
      _image = File(widget.details.image);
    }

    setState(() {});
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
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Edit Loan'),
        backgroundColor: Colors.blueGrey.shade300,
        leading: IconButton(
          onPressed: () {
            showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) => AlertDialog(
                title: Text("Cancle update?"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) =>
                              Loandashboard(customer: widget.customer),
                        ),
                        (route) => false,
                      );
                    },
                    child: Text("YES"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('NO'),
                  ),
                ],
              ),
            );
          },
          icon: Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            children: [
              Form(
                key: formKey,
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
                        if (_image == null && _localImage == null) {
                          return "Please select an image";
                        }
                        return null;
                      },
                    ),
                    // Column(
                    //   children: [
                    //     if (_image != null)
                    //       Padding(
                    //         padding: const EdgeInsets.only(
                    //           top: 20,
                    //           bottom: 10,
                    //         ),
                    //         child: Image.network(
                    //           "${UrlConstant.baseUrl}${widget.details.image}",
                    //           height: 300,
                    //           width: 300,
                    //         ),
                    //         // child: Image.file(
                    //         //   _image!,
                    //         //   height: 200,
                    //         //   width: 200,
                    //         //   fit: BoxFit.cover,
                    //         // ),
                    //       )
                    //     else
                    //       Padding(
                    //         padding: const EdgeInsets.only(
                    //           top: 20,
                    //           bottom: 10,
                    //         ),
                    //         child: Image.file(
                    //           _image!,
                    //           height: 300,
                    //           width: 300,
                    //         ),
                    //       ),
                    //   ],
                    // ),
                    Column(
                      children: [
                        // Display network image if available
                        if (_image != null &&
                            _localImage ==
                                null) // Only show network image if no local image is selected
                          Padding(
                            padding: const EdgeInsets.only(top: 20, bottom: 10),
                            child: Image.network(
                              "${UrlConstant.showImage}/${widget.details.image}",
                              height: 300,
                              width: 300,
                              fit: BoxFit.cover,
                            ),
                          )
                        // Display local image if selected
                        else if (_localImage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 20, bottom: 10),
                            child: Image.file(
                              _localImage!,
                              height: 300,
                              width: 300,
                              fit: BoxFit.cover,
                            ),
                          )
                        // Placeholder if no image is available
                        else
                          Padding(
                            padding: const EdgeInsets.only(top: 20, bottom: 10),
                            child: Container(
                              height: 300,
                              width: 300,
                              color: Colors.grey.shade300,
                              child: Icon(
                                Icons.image,
                                size: 100,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                      ],
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
                  ],
                ),
              ),
              GestureDetector(
                onTap: () async {
                  if (formKey.currentState!.validate()) {
                    formKey.currentState!.save();
                    print(widget.details.loanId);
                    print(amountController.text);
                    print(rateController.text);
                    print(startDateController.text);
                    print(endDateController.text);
                    print(_image);
                    print(noteController.text);
                    print(userId);
                    print(custId);

                    // // Determine what to send for the image field
                    // dynamic imageToSend;
                    // if (_image != null) {
                    //   // If a new image is selected, send the File
                    //   imageToSend = _image;
                    // } else {
                    //   // If no new image is selected, send the current image URL as a String
                    //   imageToSend = widget.details.image;
                    // }

                    var loan = await updateLoan(
                      widget.details.loanId,
                      amountController.text,
                      rateController.text,
                      startDateController.text,
                      endDateController.text,
                      _image, // Either a File or the existing image URL
                      noteController.text,
                      userId!,
                      custId!,
                    );
                    formKey.currentState!.reset();
                    amountController.clear();
                    rateController.clear();
                    startDateController.clear();
                    endDateController.clear();
                    noteController.clear();
                    print(loan);
                    if (loan) {
                      print("loan granted");
                      Navigator.pop(context);
                    }
                  } else {
                    print("loan ungranted");
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Container(
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Save',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey,
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
