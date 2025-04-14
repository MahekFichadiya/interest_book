import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:interest_book/Api/interest.dart';
import 'package:interest_book/Loan/DepositeAmount/showInterest.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../Provider/interestProvider.dart';

class DepositeInterest extends StatefulWidget {
  final String? loanId;
  const DepositeInterest({super.key, required this.loanId});

  @override
  State<DepositeInterest> createState() => _DepositeInterestState();
}

class _DepositeInterestState extends State<DepositeInterest> {
  final formkey = GlobalKey<FormState>();
  final amountcontroller = TextEditingController();
  final startDateController = TextEditingController();
  final notecontroller = TextEditingController();

  String getFormattedStartDateForMySQL(String dateTime) {
    final DateTime parsedDateTime = DateFormat("dd/MM/yyyy").parse(dateTime);
    return DateFormat("yyyy-MM-dd").format(parsedDateTime);
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

      final String formattedDateTime = DateFormat("dd/MM/yyyy").format(now);

      setState(() {
        startDateController.text = formattedDateTime;
      });
    }
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
                      prefixIcon: Icon(Icons.attach_money_rounded),
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

                  var add = await interestApi().addInterest(
                    amountcontroller.text,
                    formattedStartDate,
                    notecontroller.text,
                    widget.loanId.toString(),
                  );
                  if (add) {
                    // Now that it's a boolean, we continue here
                    await Provider.of<Interestprovider>(context, listen: false)
                        .fetchInterestList(widget.loanId.toString());

                    formkey.currentState!.reset();

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Interest Added...")),
                    );

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => showInterest(
                          amount: amountcontroller.text,
                          date: startDateController.text,
                          note: notecontroller.text,
                          loanId: widget.loanId.toString(),
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Failed to add interest")),
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
            const Divider(
              height: 40,
              thickness: 3,
            ),
            Card(
              child: ListTile(
                title: const Text("Show Interest"),
                trailing: IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => showInterest(
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
