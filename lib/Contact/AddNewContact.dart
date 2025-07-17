import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:interest_book/Api/add_customer.dart';
import 'package:interest_book/Provider/customer_provider.dart';
import 'package:interest_book/Utils/validation_helper.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../Loan/image_picker/screen/select_photo_options_screen.dart';

class AddNewContact extends StatefulWidget {
  final String? custName;
  final String? custPhn;
  const AddNewContact({super.key, this.custName, this.custPhn});

  @override
  State<AddNewContact> createState() => _AddNewContactState();
}

class _AddNewContactState extends State<AddNewContact> {
  final custNameController = TextEditingController();
  final custPhnController = TextEditingController();
  final custAddressController = TextEditingController();
  final dateController = TextEditingController();
  final formkey = GlobalKey<FormState>();
  String? userId;
  File? _custPic;

  loadDate() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString("userId");
    custNameController.text = widget.custName ?? "";
    custPhnController.text = widget.custPhn ?? "";
    setState(() {});
  }

  Future _pickImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;
      setState(() {
        _custPic = File(image.path);
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
  void initState() {
    // TODO: implement initState
    loadDate();
    super.initState();
  }

  Future<void> _selectDate(BuildContext context) async {
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
        dateController.text = formattedDateTime;
      });
    }
  }

  String getFormattedDateForMySQL(String dateTime) {
    final DateTime parsedDateTime = DateFormat(
      "dd/MM/yyyy hh:mm a",
    ).parse(dateTime);
    return DateFormat("yyyy-MM-dd HH:mm:ss").format(parsedDateTime);
  }

  @override
  Widget build(BuildContext context) {
    var addCust = Addcustomer();
    var customerProvider = Provider.of<CustomerProvider>(
      context,
      listen: false,
    );

    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;
    final isSmallScreen = screenHeight < 700;
    final isTablet = screenWidth > 600;

    // Responsive dimensions
    final horizontalPadding = isTablet ? 24.0 : 16.0;
    final titleFontSize = isSmallScreen ? 16.0 : 18.0;
    final iconSize = isSmallScreen ? 20.0 : 24.0;
    final fieldSpacing = isSmallScreen ? 12.0 : 16.0;
    final textFieldFontSize = isSmallScreen ? 14.0 : 16.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add Contact",
          style: TextStyle(
            fontSize: titleFontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.blueGrey[300],
        automaticallyImplyLeading: false,
        toolbarHeight: isSmallScreen ? 50 : 56,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: iconSize),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(horizontalPadding),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                Form(
                  key: formkey,
                  child: Column(
                    children: [
                      // Name Field
                      TextFormField(
                        controller: custNameController,
                        keyboardType: TextInputType.name,
                        style: TextStyle(fontSize: textFieldFontSize),
                        decoration: InputDecoration(
                          label: const Text("Name"),
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: isSmallScreen ? 12 : 16,
                          ),
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            return;
                          }
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Field can't be empty";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: fieldSpacing),

                      // Mobile Number Field
                      TextFormField(
                        controller: custPhnController,
                        keyboardType: TextInputType.phone,
                        style: TextStyle(fontSize: textFieldFontSize),
                        decoration: InputDecoration(
                          label: const Text("Mobile Number"),
                          prefixIcon: const Icon(Icons.phone_android),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: isSmallScreen ? 12 : 16,
                          ),
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            return;
                          }
                        },
                        validator: ValidationHelper.validateMobileNumber,
                      ),
                      SizedBox(height: fieldSpacing),

                      // Address Field
                      TextFormField(
                        controller: custAddressController,
                        keyboardType: TextInputType.streetAddress,
                        style: TextStyle(fontSize: textFieldFontSize),
                        decoration: InputDecoration(
                          label: const Text("Address (OPTIONAL)"),
                          prefixIcon: const Icon(Icons.location_city_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: isSmallScreen ? 12 : 16,
                          ),
                        ),
                      ),
                      SizedBox(height: fieldSpacing),

                      // Date Field
                      TextFormField(
                        controller: dateController,
                        readOnly: true,
                        style: TextStyle(fontSize: textFieldFontSize),
                        decoration: InputDecoration(
                          hintText: "Date",
                          prefixIcon: const Icon(Icons.calendar_month_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: isSmallScreen ? 12 : 16,
                          ),
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            return;
                          }
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Field can't be empty";
                          }
                          return null;
                        },
                        onTap: () => _selectDate(context),
                      ),
                      SizedBox(height: isSmallScreen ? 16 : 20),

                      // Customer Picture Section
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blueGrey[300]!),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.blueGrey.withValues(alpha: 0.05),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Customer Picture (Optional)",
                              style: TextStyle(
                                fontSize: isSmallScreen ? 14 : 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.blueGrey[700],
                              ),
                            ),
                            SizedBox(height: isSmallScreen ? 8 : 12),
                            Row(
                              children: [
                                // Image preview
                                Container(
                                  width: isSmallScreen ? 70 : 80,
                                  height: isSmallScreen ? 70 : 80,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  child:
                                      _custPic != null
                                          ? ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            child: Image.file(
                                              _custPic!,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                          : Icon(
                                            Icons.person,
                                            size: isSmallScreen ? 30 : 40,
                                            color: Colors.grey[600],
                                          ),
                                ),
                                SizedBox(width: isSmallScreen ? 12 : 16),
                                // Pick image button
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed:
                                        () => _showSelectPhotoOptions(context),
                                    icon: Icon(
                                      Icons.camera_alt,
                                      size: isSmallScreen ? 16 : 20,
                                    ),
                                    label: Text(
                                      _custPic != null
                                          ? "Change Picture"
                                          : "Add Picture",
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 12 : 14,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blueGrey,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: isSmallScreen ? 12 : 16,
                                        vertical: isSmallScreen ? 8 : 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (_custPic != null)
                              Padding(
                                padding: EdgeInsets.only(
                                  top: isSmallScreen ? 6 : 8,
                                ),
                                child: TextButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      _custPic = null;
                                    });
                                  },
                                  icon: Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                    size: isSmallScreen ? 16 : 18,
                                  ),
                                  label: Text(
                                    "Remove Picture",
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: isSmallScreen ? 12 : 14,
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
                // Submit Button
                Padding(
                  padding: EdgeInsets.only(top: isSmallScreen ? 20 : 25),
                  child: GestureDetector(
                    onTap: () async {
                      // Dismiss keyboard first
                      FocusScope.of(context).unfocus();

                      if (formkey.currentState!.validate()) {
                        formkey.currentState!.save();

                        // Check if userId is available
                        if (userId == null || userId!.isEmpty) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'User session expired. Please login again.',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 14 : 16,
                                  ),
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                          return;
                        }

                        // Use debugPrint instead of print for production
                        debugPrint("=== DEBUG: Adding Customer ===");
                        debugPrint("custName: ${custNameController.text}");
                        debugPrint("custPhn: ${custPhnController.text}");
                        debugPrint(
                          "custAddress: ${custAddressController.text}",
                        );
                        debugPrint(
                          "date: ${getFormattedDateForMySQL(dateController.text)}",
                        );
                        debugPrint("userId: $userId");
                        debugPrint("================================");

                        var result = await addCust.add(
                          custNameController.text,
                          custPhnController.text,
                          custAddressController.text,
                          getFormattedDateForMySQL(dateController.text),
                          userId!,
                          customerProvider,
                          custPic: _custPic,
                        );

                        if (result['success'] == true) {
                          debugPrint("Adding Customer...");

                          // Clear form only on success
                          formkey.currentState!.reset();
                          custNameController.clear();
                          custPhnController.clear();
                          custAddressController.clear();
                          setState(() {
                            _custPic = null;
                          });

                          // Refresh the customer list to ensure the new customer appears
                          await customerProvider.fetchCustomerList(userId!);

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  result['message'] ??
                                      "Customer Added Successfully!",
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 14 : 16,
                                  ),
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );

                            // Navigate back to customer list
                            Navigator.of(context).pop();
                          }
                        } else {
                          if (mounted) {
                            String errorMessage =
                                result['message'] ??
                                "Failed to add customer. Please try again.";

                            // Special handling for different error types
                            if (result['isDuplicate'] == true) {
                              var existingCustomer = result['existingCustomer'];
                              if (existingCustomer != null) {
                                errorMessage =
                                    "Customer '${existingCustomer['custName']}' with this phone number already exists!";
                              }
                            } else if (result['error_code'] ==
                                'INVALID_USER_ID') {
                              errorMessage =
                                  'Session expired. Please logout and login again.';
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  errorMessage,
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 14 : 16,
                                  ),
                                ),
                                backgroundColor: Colors.red,
                                duration: const Duration(seconds: 4),
                              ),
                            );
                          }
                        }
                      } else {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Please fill all required fields correctly.",
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 14 : 16,
                                ),
                              ),
                            ),
                          );
                        }
                      }
                    },
                    child: Container(
                      height: isSmallScreen ? 50 : 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          isSmallScreen ? 20 : 25,
                        ),
                        border: Border.all(width: 2, color: Colors.blueGrey),
                        color: Colors.blueGrey.withValues(alpha: 0.05),
                      ),
                      child: Center(
                        child: Text(
                          "SAVE",
                          style: TextStyle(
                            fontSize: isSmallScreen ? 16 : 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey[700],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Bottom spacing
                SizedBox(height: isSmallScreen ? 20 : 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
