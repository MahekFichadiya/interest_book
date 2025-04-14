import 'package:flutter/material.dart';
import 'package:interest_book/Api/AddCustomer.dart';
import 'package:interest_book/Provider/CustomerProvider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  loadDate() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString("userId");
    custNameController.text = widget.custName ?? "";
    custPhnController.text = widget.custPhn ?? "";
    setState(() {});
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

      final String formattedDateTime =
          DateFormat("dd/MM/yyyy hh:mm a").format(fullDateTime);

      setState(() {
        dateController.text = formattedDateTime;
      });
    }
  }

  String getFormattedDateForMySQL(String dateTime) {
    final DateTime parsedDateTime =
        DateFormat("dd/MM/yyyy hh:mm a").parse(dateTime);
    return DateFormat("yyyy-MM-dd HH:mm:ss").format(parsedDateTime);
  }

  @override
  Widget build(BuildContext context) {
    var addCust = Addcustomer();
    var customerProvider =
        Provider.of<CustomerProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Contact"),
        backgroundColor: Colors.blueGrey[300],
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Form(
                key: formkey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: custNameController,
                      keyboardType: TextInputType.name,
                      decoration: const InputDecoration(
                        label: Text("Name"),
                        prefixIcon: Icon(Icons.person),
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
                    TextFormField(
                      controller: custPhnController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        label: Text("Mobile Number"),
                        prefixIcon: Icon(Icons.phone_android),
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
                    TextFormField(
                      controller: custAddressController,
                      keyboardType: TextInputType.streetAddress,
                      decoration: const InputDecoration(
                        label: Text("Address (OPTIONAL)"),
                        prefixIcon: Icon(Icons.location_city_rounded),
                      ),
                    ),
                    TextFormField(
                      controller: dateController,
                      readOnly: true,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 16),
                        hintText: "Date",
                        prefixIcon: Icon(Icons.calendar_month_outlined),
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
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 25),
                child: GestureDetector(
                  onTap: () async {
                    if (formkey.currentState!.validate()) {
                      formkey.currentState!.save();
                      print(custNameController.text);
                      print(custPhnController.text);
                      print(custAddressController.text);
                      print(getFormattedDateForMySQL(dateController.text));
                      var customer = await addCust.add(
                          custNameController.text,
                          custPhnController.text,
                          custAddressController.text,
                          getFormattedDateForMySQL(dateController.text),
                          userId!,
                          customerProvider);
                          formkey.currentState!.reset();
                          custNameController.clear();
                          custPhnController.clear();
                          custAddressController.clear();
                      if (customer) {
                        print("Adding Cutomer...");
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Customer Added..."),
                          ),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Failed..."),
                        ),
                      );
                    }
                    Navigator.pop(context);
                  },
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                        // color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          width: 2,
                        )),
                    child: Center(
                      child: Text(
                        "SAVE",
                        style: TextStyle(
                            fontSize: 20,
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
      ),
    );
  }
}
