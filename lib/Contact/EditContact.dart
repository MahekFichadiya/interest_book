import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:interest_book/Api/update_customer.dart';
import 'package:interest_book/Api/update_customer_with_image.dart';
import 'package:interest_book/Model/CustomerModel.dart';
import 'package:interest_book/Provider/customer_provider.dart';
import 'package:interest_book/Utils/validation_helper.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../Loan/image_picker/screen/select_photo_options_screen.dart';
import '../Api/UrlConstant.dart';

class EditContact extends StatefulWidget {
  final Customer? customer;
  const EditContact({super.key, this.customer});

  @override
  State<EditContact> createState() => _EditContactState();
}

class _EditContactState extends State<EditContact> {
  final formKey = GlobalKey<FormState>();
  TextEditingController namecontroller = TextEditingController();
  TextEditingController mobilenumbercontroller = TextEditingController();
  TextEditingController addresscontroller = TextEditingController();
  String? date;
  String? userId;
  File? _custPic;
  String? _currentCustPic;

  loadData() {
    namecontroller.text = widget.customer!.custName;
    mobilenumbercontroller.text = widget.customer!.custPhn;
    addresscontroller.text = widget.customer!.custAddress!;
    date = widget.customer!.date;
    userId = widget.customer!.userId;
    _currentCustPic = widget.customer!.custPic;
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
    loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
        automaticallyImplyLeading: false,
        toolbarHeight: isSmallScreen ? 50 : 56,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(
              context,
              Customer(
                custName: namecontroller.text,
                custPhn: mobilenumbercontroller.text,
                date: date!,
                userId: userId!,
              ),
            );
          },
          icon: Icon(Icons.arrow_back_ios_rounded, size: iconSize),
        ),
        title: Text(
          'Edit Customer',
          style: TextStyle(
            fontSize: titleFontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.blueGrey.shade300,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(horizontalPadding),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      // Name Field
                      TextFormField(
                        controller: namecontroller,
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
                        controller: mobilenumbercontroller,
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
                        controller: addresscontroller,
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
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.grey),
                                  ),
                                  child:
                                      _custPic != null
                                          ? ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: Image.file(
                                              _custPic!,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                          : (_currentCustPic != null &&
                                              _currentCustPic!.isNotEmpty)
                                          ? ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: Image.network(
                                              "${UrlConstant.showImage}/$_currentCustPic",
                                              fit: BoxFit.cover,
                                              errorBuilder: (
                                                context,
                                                error,
                                                stackTrace,
                                              ) {
                                                return const Icon(
                                                  Icons.person,
                                                  size: 40,
                                                  color: Colors.grey,
                                                );
                                              },
                                            ),
                                          )
                                          : const Icon(
                                            Icons.person,
                                            size: 40,
                                            color: Colors.grey,
                                          ),
                                ),
                                const SizedBox(width: 16),
                                // Pick image button
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed:
                                        () => _showSelectPhotoOptions(context),
                                    icon: const Icon(Icons.camera_alt),
                                    label: Text(
                                      _custPic != null ||
                                              (_currentCustPic != null &&
                                                  _currentCustPic!.isNotEmpty)
                                          ? "Change Picture"
                                          : "Add Picture",
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blueGrey[300],
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (_custPic != null ||
                                (_currentCustPic != null &&
                                    _currentCustPic!.isNotEmpty))
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: TextButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      _custPic = null;
                                      _currentCustPic = null;
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  label: const Text(
                                    "Remove Picture",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 25),
                  child: GestureDetector(
                    onTap: () async {
                      if (formKey.currentState!.validate()) {
                        final updated = await UpdateCustomerWithImageApi()
                            .update(
                              widget.customer!.custId.toString(),
                              namecontroller.text,
                              mobilenumbercontroller.text,
                              addresscontroller.text,
                              custPic: _custPic,
                            );

                        if (updated) {
                          // Determine the final picture path
                          String? finalCustPic;
                          if (_custPic != null) {
                            // New image was selected, use the filename
                            finalCustPic =
                                "OmJavellerssHTML/CustomerImages/${_custPic!.path.split('/').last}";
                          } else if (_currentCustPic != null &&
                              _currentCustPic!.isNotEmpty) {
                            // Keep existing image
                            finalCustPic = _currentCustPic;
                          }

                          final updatedCustomer = Customer(
                            custId: widget.customer!.custId,
                            custName: namecontroller.text,
                            custPhn: mobilenumbercontroller.text,
                            custAddress: addresscontroller.text,
                            custPic: finalCustPic,
                            date: widget.customer!.date,
                            userId: widget.customer!.userId,
                          );

                          Provider.of<CustomerProvider>(
                            context,
                            listen: false,
                          ).updateCustomer(updatedCustomer);

                          Navigator.pop(
                            context,
                            true,
                          ); // ✅ Return true to refresh Loandashboard
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to update customer'),
                            ),
                          );
                        }
                      }
                    },
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        // color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(width: 2),
                      ),
                      child: Center(
                        child: Text(
                          "SAVE",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey,
                          ),
                        ),
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
