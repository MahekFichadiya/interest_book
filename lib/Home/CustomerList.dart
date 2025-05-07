import 'package:flutter/material.dart';
import 'package:interest_book/Loan/LoanDashborad/LoanDashborad.dart';
import 'package:interest_book/Provider/CustomerProvider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

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

    if (userId != null && userId.isNotEmpty) {
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
          return const Center(
            child: Text(
              "No customer data available.",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          );
        }

        return ListView.builder(
          controller: widget.scrollController,
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
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: ListTile(
                  title: Text(customer.custName),
                  subtitle: Text(formatDate(customer.date)),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
