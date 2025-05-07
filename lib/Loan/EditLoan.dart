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
      final DateTime parsedStartDate = DateFormat(
        "yyyy-MM-dd HH:mm:ss",
      ).parse(widget.details.startDate);
      startDateController.text = DateFormat(
        "dd/MM/yyyy hh:mm a",
      ).format(parsedStartDate);
    }

    if (widget.details.endDate.isNotEmpty &&
        widget.details.endDate != '0000/00/00') {
      final DateTime parsedEndDate = DateFormat(
        "yyyy-MM-dd",
      ).parse(widget.details.endDate);
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
                      ),
                      _buildImageSelector(),
                      const SizedBox(height: 10),
                      _buildImagePreview(),
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
    Function(BuildContext) onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: hint,
          prefixIcon: const Icon(Icons.calendar_month_outlined),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onTap: () => onTap(context),
        validator: (value) => value!.isEmpty ? "Please select a date" : null,
      ),
    );
  }

  Widget _buildImageSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        readOnly: true,
        decoration: InputDecoration(
          labelText: _image == null ? "Select Image" : "Change Image",
          prefixIcon: const Icon(Icons.camera_alt_outlined),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onTap: () => _showSelectPhotoOptions(context),
        validator: (_) {
          if (_image == null && _localImage == null) {
            return "Please select an image";
          }
          return null;
        },
      ),
    );
  }

  Widget _buildImagePreview() {
    if (_localImage != null) {
      return Image.file(
        _localImage!,
        height: 250,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    } else if (_image != null) {
      return Image.network(
        "${UrlConstant.showImage}/${widget.details.image}",
        height: 250,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    } else {
      return Container(
        height: 250,
        width: double.infinity,
        color: Colors.grey.shade200,
        child: const Icon(Icons.image, size: 100, color: Colors.grey),
      );
    }
  }

  void _onSave() async {
    if (formKey.currentState!.validate()) {
      var loan = await updateLoan(
        widget.details.loanId,
        amountController.text,
        rateController.text,
        startDateController.text,
        endDateController.text,
        _localImage ?? _image,
        noteController.text,
        userId!,
        custId!,
      );
      if (loan) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Loan updated successfully")),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Failed to update loan")));
      }
    }
  }
}
