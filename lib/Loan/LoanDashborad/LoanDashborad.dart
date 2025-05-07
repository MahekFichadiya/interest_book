import 'package:flutter/material.dart';
import 'package:interest_book/Api/fetchAllLoansByUserAndCustomer.dart';
import 'package:interest_book/Contact/EditContact.dart';
import 'package:interest_book/DashboardScreen.dart';
import 'package:interest_book/Loan/ApplyLoan.dart/ApplyLoan.dart';
import 'package:interest_book/Loan/LoanDashborad/LoanList.dart';
import 'package:interest_book/Model/CustomerModel.dart';
import 'package:interest_book/pdfGenerator/generatePdfForPerticularCustomer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../Api/RemoveCustomer.dart';

class Loandashboard extends StatefulWidget {
  final Customer customer;
  const Loandashboard({super.key, required this.customer});

  @override
  State<Loandashboard> createState() => _LoandashboardState();
}

class _LoandashboardState extends State<Loandashboard> {
  String? userId;

  loadData() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString("userId");
    setState(() {});
  }

  @override
  void initState() {
    loadData();
    super.initState();
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri url = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context, 'Success');
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: Text(widget.customer.custName, overflow: TextOverflow.ellipsis),
        backgroundColor: Colors.blueGrey[300],
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'call') {
                _makePhoneCall(widget.customer.custPhn);
                print('Calling ${widget.customer.custPhn}');
              } else if (value == 'edit') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => EditContact(customer: widget.customer),
                  ),
                );
              } else if (value == 'delete') {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("Do you want to delete the customer?"),
                      actions: [
                        TextButton(
                          onPressed: () async {
                            await Removecustomer().remove(
                              widget.customer.custId!,
                              userId!,
                            );
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) => DashboardScreen(),
                              ),
                              (route) => false,
                            );
                          },
                          child: const Text('Yes'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Cancel'),
                        ),
                      ],
                    );
                  },
                );
              }
            },
            itemBuilder:
                (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'call',
                    child: ListTile(
                      leading: Icon(Icons.call),
                      title: Text('Call'),
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(Icons.edit),
                      title: Text('Edit'),
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete),
                      title: Text('Delete'),
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 170,
            decoration: BoxDecoration(
              color: Colors.blueGrey[200],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
            child: Center(
              child: Container(
                height: 120,
                width: 300,
                decoration: const BoxDecoration(color: Colors.white),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: 100,
                        width: 150,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                widget.customer.custName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Divider(height: 2, color: Colors.black),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    onPressed: () async {
                                      try {
                                        print('Fetching data...');
                                        final data =
                                            await fetchAllLoansByUserAndCustomer(
                                              custId: int.parse(
                                                widget.customer.custId
                                                    .toString(),
                                              ),
                                              userId: int.parse(
                                                widget.customer.userId
                                                    .toString(),
                                              ),
                                            );
                                        print(
                                          'Data fetched successfully: ${data.length} items',
                                        );

                                        print('Generating PDF...');
                                        await generatePdfForPerticulatCustomer(
                                          data: data,
                                          customerName:
                                              widget.customer.custName,
                                        );
                                        print('PDF generated successfully');
                                      } catch (e, stacktrace) {
                                        print(
                                          'Error during PDF generation: $e',
                                        );
                                        print('Stacktrace: $stacktrace');

                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Failed to generate report: $e',
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    icon: const Icon(Icons.picture_as_pdf),
                                  ),

                                  const Image(
                                    image: AssetImage(
                                      'assest/WhatsappIcon.png',
                                    ),
                                    height: 30,
                                  ),
                                  IconButton(
                                    onPressed: () {},
                                    icon: const Icon(Icons.message_rounded),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 8, bottom: 8),
                      child: VerticalDivider(width: 2, color: Colors.black),
                    ),
                    Container(
                      height: 100,
                      width: 120,
                      child: const Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "₹23,000",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            Text(
                              "₹700",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            Divider(height: 2, color: Colors.red),
                            Text(
                              "₹23,700",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            Text(
                              "They will pay you..",
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: LoanList(
              custId: widget.customer.custId,
              customer: widget.customer,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 20,
              bottom: 20,
              left: 20,
              right: 20,
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return ApplyLoan(customerId: widget.customer.custId);
                    },
                  ),
                );
              },
              child: Container(
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: const Center(
                  child: Text(
                    "Apply for a loan",
                    style: TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
