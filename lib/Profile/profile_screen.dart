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
import 'package:interest_book/Api/business_report_service.dart';
import 'package:interest_book/Model/customerLoanData.dart';
import 'package:interest_book/Profile/update_profile.dart';
import 'package:interest_book/Provider/profile_provider.dart';
import 'package:interest_book/pdfGenerator/generate_pdf_whole_customer_list.dart';
import 'package:interest_book/settledLoan/list_of_settled_customer.dart';
import 'package:interest_book/settledLoan/settled_loan_list.dart';
import 'package:interest_book/Utils/amount_formatter.dart';
import 'package:interest_book/Utils/app_colors.dart';
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
      Uri.parse(
        UrlConstant.getCustomerLoanData,
      ), // Replace with actual URL and dynamic ID
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
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;
    final isSmallScreen = screenHeight < 700;
    final isTablet = screenWidth > 600;

    // Responsive dimensions
    final horizontalPadding = isTablet ? 24.0 : 16.0;
    final titleFontSize = isSmallScreen ? 16.0 : 18.0;
    final iconSize = isSmallScreen ? 20.0 : 24.0;
    final sectionHeaderFontSize = isSmallScreen ? 14.0 : 15.0;
    final listTileFontSize = isSmallScreen ? 14.0 : 15.0;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Text(
          "Profile",
          style: TextStyle(
            fontSize: titleFontSize,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        toolbarHeight: isSmallScreen ? 50 : 56,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (context) => UpdateProfile()));
            },
            icon: Icon(Icons.edit, size: iconSize, color: Colors.white),
          ),
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text(
                      "Are you sure want to logout ??",
                      style: TextStyle(fontSize: isSmallScreen ? 16 : 18),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          prefs.clear();
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                            (route) => false,
                          );
                        },
                        child: Text(
                          "OK",
                          style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Cancel",
                          style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
            icon: Icon(Icons.power_settings_new_rounded, size: iconSize),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(horizontalPadding),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Personal Info Section
                Container(
                  height: isSmallScreen ? 35 : 40,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(isSmallScreen ? 6.0 : 8.0),
                    child: Row(
                      children: [
                        Text(
                          "Personal Info.",
                          style: TextStyle(
                            fontSize: sectionHeaderFontSize,
                            fontWeight: FontWeight.w600,
                            color: Colors.blueGrey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: isSmallScreen ? 8 : 12),

                // Name - Improved layout for better display
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 20 : 16,
                    vertical: isSmallScreen ? 8 : 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Name",
                        style: TextStyle(
                          fontSize: listTileFontSize,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 4 : 6),
                      SizedBox(
                        width: double.infinity,
                        child: Text(
                          profile.name.isNotEmpty ? profile.name : 'No name provided',
                          style: TextStyle(
                            fontSize: listTileFontSize,
                            color: profile.name.isNotEmpty
                                ? Colors.blueGrey[600]
                                : Colors.grey[500],
                            fontStyle: profile.name.isNotEmpty
                                ? FontStyle.normal
                                : FontStyle.italic,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, thickness: 1, color: Colors.blueGrey[200]),

                // Mobile Number - Improved layout for better display
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 20 : 16,
                    vertical: isSmallScreen ? 8 : 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Mobile No.",
                        style: TextStyle(
                          fontSize: listTileFontSize,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 4 : 6),
                      SizedBox(
                        width: double.infinity,
                        child: Text(
                          profile.mobileNo.isNotEmpty ? profile.mobileNo : 'No mobile number provided',
                          style: TextStyle(
                            fontSize: listTileFontSize,
                            color: profile.mobileNo.isNotEmpty
                                ? Colors.blueGrey[600]
                                : Colors.grey[500],
                            fontStyle: profile.mobileNo.isNotEmpty
                                ? FontStyle.normal
                                : FontStyle.italic,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, thickness: 1, color: Colors.blueGrey[200]),

                // Email - Improved layout for better display
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 20 : 16,
                    vertical: isSmallScreen ? 8 : 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Email",
                        style: TextStyle(
                          fontSize: listTileFontSize,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 4 : 6),
                      SizedBox(
                        width: double.infinity,
                        child: Text(
                          profile.email.isNotEmpty ? profile.email : 'No email provided',
                          style: TextStyle(
                            fontSize: listTileFontSize,
                            color: profile.email.isNotEmpty
                                ? Colors.blueGrey[600]
                                : Colors.grey[500],
                            fontStyle: profile.email.isNotEmpty
                                ? FontStyle.normal
                                : FontStyle.italic,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, thickness: 1, color: Colors.blueGrey[200]),
                // History Section
                Padding(
                  padding: EdgeInsets.only(top: isSmallScreen ? 6 : 8),
                  child: Container(
                    height: isSmallScreen ? 35 : 40,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(isSmallScreen ? 6.0 : 8.0),
                      child: Row(
                        children: [
                          Text(
                            "History",
                            style: TextStyle(
                              fontSize: sectionHeaderFontSize,
                              fontWeight: FontWeight.w600,
                              color: Colors.blueGrey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: isSmallScreen ? 8 : 12),

                // Settled Customer
                ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 20 : 16,
                    vertical: isSmallScreen ? 4 : 8,
                  ),
                  title: Text(
                    "Settled Customer",
                    style: TextStyle(
                      fontSize: listTileFontSize,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: IconButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => Listofsettledcustomer(),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: isSmallScreen ? 16 : 18,
                      color: Colors.blueGrey[600],
                    ),
                  ),
                ),

                // Settled Loan
                ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 20 : 16,
                    vertical: isSmallScreen ? 4 : 8,
                  ),
                  title: Text(
                    "Settled Loan",
                    style: TextStyle(
                      fontSize: listTileFontSize,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: IconButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => Settledloanlist(),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: isSmallScreen ? 16 : 18,
                      color: Colors.blueGrey[600],
                    ),
                  ),
                ),
                Divider(height: 1, thickness: 1, color: Colors.blueGrey[200]),
                // Money Info Section
                Padding(
                  padding: EdgeInsets.only(top: isSmallScreen ? 6 : 8),
                  child: Container(
                    height: isSmallScreen ? 35 : 40,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(isSmallScreen ? 6.0 : 8.0),
                      child: Row(
                        children: [
                          Text(
                            "Money Info.",
                            style: TextStyle(
                              fontSize: sectionHeaderFontSize,
                              fontWeight: FontWeight.w600,
                              color: Colors.blueGrey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: isSmallScreen ? 8 : 12),


                // Total You Gave (Principal + Interest)
                Consumer<ProfileProvider>(
                  builder: (context, profileProvider, child) {
                    if (profileProvider.isLoadingMoneyInfo) {
                      return ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 20 : 16,
                          vertical: isSmallScreen ? 4 : 8,
                        ),
                        title: Text(
                          "Total You Gave",
                          style: TextStyle(
                            fontSize: listTileFontSize,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        trailing: SizedBox(
                          width: isSmallScreen ? 16 : 20,
                          height: isSmallScreen ? 16 : 20,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    }

                    return ListTile(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 20 : 16,
                        vertical: isSmallScreen ? 4 : 8,
                      ),
                      title: Text(
                        "Total You Gave",
                        style: TextStyle(
                          fontSize: listTileFontSize,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: Text(
                        AmountFormatter.formatCurrency(profileProvider.totalYouGave),
                        style: TextStyle(
                          fontSize: listTileFontSize,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
                Divider(height: 1, thickness: 1, color: Colors.blueGrey[200]),

                // Total You Got (Principal + Interest)
                Consumer<ProfileProvider>(
                  builder: (context, profileProvider, child) {
                    if (profileProvider.isLoadingMoneyInfo) {
                      return ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 20 : 16,
                          vertical: isSmallScreen ? 4 : 8,
                        ),
                        title: Text(
                          "Total You Got",
                          style: TextStyle(
                            fontSize: listTileFontSize,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        trailing: SizedBox(
                          width: isSmallScreen ? 16 : 20,
                          height: isSmallScreen ? 16 : 20,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    }

                    return ListTile(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 20 : 16,
                        vertical: isSmallScreen ? 4 : 8,
                      ),
                      title: Text(
                        "Total You Got",
                        style: TextStyle(
                          fontSize: listTileFontSize,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: Text(
                        AmountFormatter.formatCurrency(profileProvider.totalYouGot),
                        style: TextStyle(
                          fontSize: listTileFontSize,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
                Divider(height: 1, thickness: 1, color: Colors.blueGrey[200]),
                // Download Report Button
                Padding(
                  padding: EdgeInsets.only(top: isSmallScreen ? 16 : 20),
                  child: GestureDetector(
                    onTap: () async {
                      try {
                        // Show loading indicator
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Generating business report...',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 14 : 16,
                                ),
                              ),
                              backgroundColor: Colors.blue,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }

                        // Get profile data
                        final profileProvider = Provider.of<ProfileProvider>(
                          context,
                          listen: false,
                        );

                        // Fetch comprehensive business report data with interest
                        final businessReportData = await BusinessReportService.fetchBusinessReportData(
                          profileProvider.userId.toString(),
                        );

                        // Generate PDF with enhanced data including interest
                        await generatePdfFromData(
                          businessReportData.customers,
                          userName:
                              profileProvider.name.isNotEmpty
                                  ? profileProvider.name
                                  : null,
                          userEmail:
                              profileProvider.email.isNotEmpty
                                  ? profileProvider.email
                                  : null,
                          userPhone:
                              profileProvider.mobileNo.isNotEmpty
                                  ? profileProvider.mobileNo
                                  : null,
                          totalYouGave: businessReportData.summary.principalYouGave,
                          totalYouGot: businessReportData.summary.principalYouGot,
                          totalYouGaveInterest: businessReportData.summary.interestYouGave,
                          totalYouGotInterest: businessReportData.summary.interestYouGot,
                          totalInterest: businessReportData.summary.totalInterest,
                        );

                        // Business report generated successfully - no snackbar message as per user preference
                      } catch (e) {
                        // Use debugPrint instead of print for production
                        debugPrint('Profile PDF generation error: $e');
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Failed to generate report: ${e.toString()}",
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 14 : 16,
                                ),
                              ),
                              backgroundColor: Colors.red,
                              duration: const Duration(seconds: 5),
                            ),
                          );
                        }
                      }
                    },
                    child: Container(
                      height: isSmallScreen ? 45 : 50,
                      decoration: BoxDecoration(
                        border: Border.all(width: 2, color: Colors.blueGrey),
                        borderRadius: BorderRadius.circular(
                          isSmallScreen ? 16 : 20,
                        ),
                        color: Colors.blueGrey.withValues(alpha: 0.05),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(isSmallScreen ? 6.0 : 8.0),
                        child: Center(
                          child: Text(
                            "Download Report",
                            style: TextStyle(
                              fontSize: listTileFontSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey[700],
                            ),
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
