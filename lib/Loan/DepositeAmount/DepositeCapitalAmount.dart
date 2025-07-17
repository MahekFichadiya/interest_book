import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:interest_book/Api/interest.dart';
import 'package:interest_book/Loan/DepositeAmount/showDeposite.dart';
import 'package:interest_book/Provider/deposite_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DepositeCapitalAmount extends StatefulWidget {
  final String? loanId;
  const DepositeCapitalAmount({super.key, required this.loanId});

  @override
  State<DepositeCapitalAmount> createState() => _DepositeCapitalAmountState();
}

class _DepositeCapitalAmountState extends State<DepositeCapitalAmount> {
  final formkey = GlobalKey<FormState>();
  final amountcontroller = TextEditingController();
  final startDateController = TextEditingController();
  final notecontroller = TextEditingController();

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? startDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (startDate != null) {
      final DateTime now = DateTime.now();

      final String formattedDateTime =
          DateFormat("dd/MM/yyyy hh:mm a").format(now);

      setState(() {
        startDateController.text = formattedDateTime;
      });
    }
  }

  String getFormattedStartDateForMySQL(String dateTime) {
    final DateTime parsedDateTime = DateFormat("dd/MM/yyyy").parse(dateTime);
    return DateFormat("yyyy-MM-dd").format(parsedDateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Form(
              key: formkey,
              child: Column(
                children: [
                  TextFormField(
                    controller: amountcontroller,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      label: Text("Amount"),
                      prefixIcon: Icon(Icons.currency_rupee),
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
                    controller: startDateController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 16),
                      hintText: "Interest till Date",
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
                    onTap: () => _selectStartDate(context),
                  ),
                  TextFormField(
                    controller: notecontroller,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      label: Text("Note"),
                      prefixIcon: Icon(Icons.edit),
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
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: () async {
                if (formkey.currentState!.validate()) {
                  final String formattedStartDate =
                      getFormattedStartDateForMySQL(startDateController.text);

                  try {
                    var isAdded = await interestApi().addDeposite(
                      amountcontroller.text,
                      formattedStartDate,
                      notecontroller.text,
                      widget.loanId.toString(),
                      'cash', // Default to cash for this legacy call
                    );
                    formkey.currentState!.reset();

                    if (isAdded) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Deposite Added...")),
                      );

                      // After adding the deposit, refresh the deposit list in DepositeProvider
                      await Provider.of<Depositeprovider>(context,
                              listen: false)
                          .fetchDepositeList(widget.loanId.toString());

                      // Navigate to the showDeposite page
                      // Navigator.pushReplacement(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) {
                      //       return DepositeCapitalAmount(
                      //         loanId: widget.loanId.toString(),
                      //       );
                      //     },
                      //   ),
                      // );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Failed to add deposite")),
                      );
                    }
                  } catch (e) {
                    print("Error: $e");
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text("An error occurred while adding the deposite"),
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Something is missing in form"),
                    ),
                  );
                }
              },
              child: Container(
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    width: 2,
                  ),
                ),
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
            const Divider(
              height: 40,
              thickness: 3,
            ),
            Card(
              child: ListTile(
                title: const Text("Show Deposite"),
                trailing: IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ShowDeposite(
                          amount: amountcontroller.text,
                          date: startDateController.text,
                          note: notecontroller.text,
                          loanId: widget.loanId.toString(),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.arrow_forward_ios_rounded),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
