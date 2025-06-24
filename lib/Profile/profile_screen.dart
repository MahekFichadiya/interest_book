// import 'package:flutter/material.dart';
// import 'package:interest_book/Profile/UpdateProfile.dart';
// import 'package:interest_book/Provider/ProfileProvider.dart';
// import 'package:interest_book/settledLoan/settledLoanList.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import '../Login&Signup/LoginScreen.dart';
// import '../settledLoan/ListOfSettledCustomer.dart';

// class ProfileScreen extends StatelessWidget {
//   const ProfileScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final profile = Provider.of<ProfileProvider>(context);

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.blueGrey[300],
//         automaticallyImplyLeading: false,
//         title: const Text("Profile"),
//         actions: [
//           IconButton(
//             onPressed: () {
//               Navigator.of(
//                 context,
//               ).push(MaterialPageRoute(builder: (context) => UpdateProfile()));
//             },
//             icon: Icon(Icons.edit),
//           ),
//           IconButton(
//             onPressed: () {
//               showDialog(
//                 context: context,
//                 builder: (context) {
//                   return AlertDialog(
//                     title: const Text("Are you sure want to logout ??"),
//                     actions: [
//                       TextButton(
//                         onPressed: () async {
//                           SharedPreferences prefs =
//                               await SharedPreferences.getInstance();
//                           prefs.clear();
//                           Navigator.of(context).pushAndRemoveUntil(
//                             MaterialPageRoute(
//                               builder: (context) => const LoginScreen(),
//                             ),
//                             (route) => false,
//                           );
//                         },
//                         child: const Text("OK"),
//                       ),
//                       TextButton(
//                         onPressed: () {
//                           Navigator.pop(context);
//                         },
//                         child: const Text("Cancle"),
//                       ),
//                     ],
//                   );
//                 },
//               );
//             },
//             icon: const Icon(Icons.power_settings_new_rounded),
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               
//               Padding(
//                 padding: const EdgeInsets.only(top: 20),
//                 child: GestureDetector(
//                   onTap: () {},
//                   child: Container(
//                     height: 50,
//                     decoration: BoxDecoration(
//                       border: Border.all(width: 2, color: Colors.blueGrey),
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: const Padding(
//                       padding: EdgeInsets.all(8.0),
//                       child: Center(
//                         child: Text(
//                           "Download Report",
//                           style: TextStyle(
//                             fontSize: 15,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:interest_book/Api/UrlConstant.dart';
import 'package:interest_book/Model/customerLoanData.dart';
import 'package:interest_book/Profile/update_profile.dart';
import 'package:interest_book/Provider/profile_provider.dart';
import 'package:interest_book/pdfGenerator/generate_pdf_whole_customer_list.dart';
import 'package:interest_book/settledLoan/list_of_settled_customer.dart';
import 'package:interest_book/settledLoan/settled_loan_list.dart';
import 'package:interest_book/Utils/amount_formatter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Login&Signup/LoginScreen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Money info will be automatically fetched when profile is loaded
  }

  Future<List<Customerloandata>> fetchCustomerLoanData() async {
    final response = await http.get(
      Uri.parse(UrlConstant.getCustomerLoanData), // Replace with actual URL and dynamic ID
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((item) => Customerloandata.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load report data');
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<ProfileProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[300],
        automaticallyImplyLeading: false,
        title: const Text("Profile"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => UpdateProfile()));
            },
            icon: Icon(Icons.edit),
          ),
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text("Are you sure want to logout ??"),
                    actions: [
                      TextButton(
                        onPressed: () async {
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          prefs.clear();
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                            (route) => false,
                          );
                        },
                        child: const Text("OK"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("Cancel"),
                      ),
                    ],
                  );
                },
              );
            },
            icon: const Icon(Icons.power_settings_new_rounded),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 40,
                width: double.infinity,
                color: Colors.black12,
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Text("Personal Info.", style: TextStyle(fontSize: 15)),
                    ],
                  ),
                ),
              ),
              ListTile(
                title: const Text("Name"),
                trailing: Text(
                  "${profile.name}",
                  style: const TextStyle(fontSize: 15),
                ),
              ),
              const Divider(height: 1, thickness: 2),
              ListTile(
                title: const Text("Mobile No."),
                trailing: Text(
                  "${profile.mobileNo}",
                  style: const TextStyle(fontSize: 15),
                ),
              ),
              const Divider(height: 1, thickness: 2),
              ListTile(
                title: const Text("Email"),
                trailing: Text(
                  "${profile.email}",
                  style: const TextStyle(fontSize: 15),
                ),
              ),
              const Divider(height: 1, thickness: 2),
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Container(
                  height: 40,
                  width: double.infinity,
                  color: Colors.black12,
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Text("History", style: TextStyle(fontSize: 15)),
                      ],
                    ),
                  ),
                ),
              ),
              ListTile(
                title: const Text("Settled Customer"),
                trailing: IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => Listofsettledcustomer(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.arrow_forward_ios_rounded),
                ),
              ),
              ListTile(
                title: const Text("Settled Loan"),
                trailing: IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => Settledloanlist(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.arrow_forward_ios_rounded),
                ),
              ),
              const Divider(height: 1, thickness: 2),
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Container(
                  height: 40,
                  width: double.infinity,
                  color: Colors.black12,
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Text("Money Info.", style: TextStyle(fontSize: 15)),
                      ],
                    ),
                  ),
                ),
              ),
              Consumer<ProfileProvider>(
                builder: (context, profileProvider, child) {
                  if (profileProvider.isLoadingMoneyInfo) {
                    return const ListTile(
                      title: Text("You gave ↓"),
                      trailing: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  }

                  if (profileProvider.moneyInfoError.isNotEmpty) {
                    return const ListTile(
                      title: Text("You gave ↓"),
                      trailing: Text(
                        "Error loading data",
                        style: TextStyle(fontSize: 12, color: Colors.red),
                      ),
                    );
                  }

                  return ListTile(
                    title: const Text("You gave ↓"),
                    trailing: Text(
                      AmountFormatter.formatCurrency(profileProvider.youGave),
                      style: const TextStyle(fontSize: 15, color: Colors.green),
                    ),
                  );
                },
              ),
              const Divider(height: 1, thickness: 2),
              Consumer<ProfileProvider>(
                builder: (context, profileProvider, child) {
                  if (profileProvider.isLoadingMoneyInfo) {
                    return const ListTile(
                      title: Text("You got ↑"),
                      trailing: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  }

                  if (profileProvider.moneyInfoError.isNotEmpty) {
                    return const ListTile(
                      title: Text("You got ↑"),
                      trailing: Text(
                        "Error loading data",
                        style: TextStyle(fontSize: 12, color: Colors.red),
                      ),
                    );
                  }

                  return ListTile(
                    title: const Text("You got ↑"),
                    trailing: Text(
                      AmountFormatter.formatCurrency(profileProvider.youGot),
                      style: const TextStyle(fontSize: 15, color: Colors.red),
                    ),
                  );
                },
              ),
              const Divider(height: 1, thickness: 2),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: GestureDetector(
                  onTap: () async {
                    try {
                      // Show loading indicator
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Generating business report...'),
                          backgroundColor: Colors.blue,
                          duration: Duration(seconds: 2),
                        ),
                      );

                      // Get profile data
                      final profileProvider = Provider.of<ProfileProvider>(context, listen: false);

                      // Fetch customer loan data
                      final data = await fetchCustomerLoanData();

                      // Generate PDF with enhanced data
                      await generatePdfFromData(
                        data,
                        userName: profileProvider.name.isNotEmpty ? profileProvider.name : null,
                        userEmail: profileProvider.email.isNotEmpty ? profileProvider.email : null,
                        userPhone: profileProvider.mobileNo.isNotEmpty ? profileProvider.mobileNo : null,
                        totalYouGave: profileProvider.youGave,
                        totalYouGot: profileProvider.youGot,
                      );

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Business report generated successfully!'),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 3),
                          ),
                        );
                      }
                    } catch (e) {
                      print('Profile PDF generation error: $e');
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Failed to generate report: ${e.toString()}"),
                            backgroundColor: Colors.red,
                            duration: const Duration(seconds: 5),
                          ),
                        );
                      }
                    }
                  },
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border.all(width: 2, color: Colors.blueGrey),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(
                        child: Text(
                          "Download Report",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
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
    );
  }
}
