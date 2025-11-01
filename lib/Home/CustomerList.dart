import 'package:flutter/material.dart';
import 'package:interest_book/Loan/LoanDashborad/LoanDashborad.dart';
import 'package:interest_book/Provider/customer_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../Api/UrlConstant.dart';

class CustomerList extends StatefulWidget {
  final ScrollController scrollController;
  final String searchQuery;

  const CustomerList({
    Key? key,
    required this.scrollController,
    required this.searchQuery,
  }) : super(key: key);

  @override
  _CustomerListState createState() => _CustomerListState();
}

class _CustomerListState extends State<CustomerList> {
  @override
  void initState() {
    super.initState();
    loadUserIdAndFetchData();
  }

  Future<void> loadUserIdAndFetchData() async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString("userId");

    if (userId != null && userId.isNotEmpty && mounted) {
      await Provider.of<CustomerProvider>(context, listen: false)
          .fetchCustomerList(userId);
    }
  }

  String formatDate(String date) {
    try {
      DateTime parsed = DateTime.parse(date);
      return DateFormat('dd-MM-yyyy hh:mm a').format(parsed);
    } catch (e) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;
    final isSmallScreen = screenHeight < 700;
    final isTablet = screenWidth > 600;

    // Responsive dimensions
    final avatarRadius = isSmallScreen ? 20.0 : 25.0;
    final cardMargin = EdgeInsets.symmetric(
      horizontal: isTablet ? 16 : 10,
      vertical: isSmallScreen ? 4 : 6,
    );
    final titleFontSize = isSmallScreen ? 16.0 : 18.0;
    final subtitleFontSize = isSmallScreen ? 12.0 : 14.0;
    final emptyStateFontSize = isSmallScreen ? 16.0 : 20.0;
    final emptyStateSubtitleFontSize = isSmallScreen ? 10.0 : 12.0;

    return Consumer<CustomerProvider>(
      builder: (context, customerProvider, child) {
        if (customerProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final filtered = customerProvider.customers.where((cust) {
          final query = widget.searchQuery.toLowerCase();
          return cust.custName.toLowerCase().contains(query);
        }).toList();

        if (filtered.isEmpty) {
          return Padding(
            padding: EdgeInsets.all(isTablet ? 16.0 : 8.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "No customer data available....",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: emptyStateFontSize,
                      color: Colors.blueGrey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: isSmallScreen ? 8 : 12),
                  Text(
                    "Add a new Customer, by tapping on the '📞' button.",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: emptyStateSubtitleFontSize,
                      color: Colors.blueGrey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          controller: widget.scrollController,
          physics: const BouncingScrollPhysics(),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final customer = filtered[index];
            return GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => Loandashboard(custId: customer.custId!),
                  ),
                );
              },
              child: Card(
                margin: cardMargin,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 20 : 16,
                    vertical: isSmallScreen ? 8 : 12,
                  ),
                  leading: CircleAvatar(
                    radius: avatarRadius,
                    backgroundColor: Colors.blueGrey[300],
                    child: customer.custPic != null && customer.custPic!.isNotEmpty
                        ? ClipOval(
                            child: Image.network(
                              "${UrlConstant.showImage}/${customer.custPic}",
                              width: avatarRadius * 2,
                              height: avatarRadius * 2,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Text(
                                  customer.custName.isNotEmpty
                                      ? customer.custName[0].toUpperCase()
                                      : '',
                                  style: TextStyle(
                                    fontSize: avatarRadius * 0.8,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
                            ),
                          )
                        : Text(
                            customer.custName.isNotEmpty
                                ? customer.custName[0].toUpperCase()
                                : '',
                            style: TextStyle(
                              fontSize: avatarRadius * 0.8,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  title: Text(
                    customer.custName,
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w600,
                      color: Colors.blueGrey[800],
                    ),
                  ),
                  subtitle: Text(
                    formatDate(customer.date),
                    style: TextStyle(
                      fontSize: subtitleFontSize,
                      color: Colors.blueGrey[600],
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: isSmallScreen ? 16 : 18,
                    color: Colors.blueGrey[400],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
