import 'package:flutter/material.dart';
import 'package:interest_book/Api/show_customer.dart';
import 'package:interest_book/Provider/backuped_customer_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Model/backupedCustomerModel.dart';
import '../Api/UrlConstant.dart';

class Listofsettledcustomer extends StatefulWidget {
  const Listofsettledcustomer({super.key});

  @override
  State<Listofsettledcustomer> createState() => _ListofsettledcustomerState();
}

class _ListofsettledcustomerState extends State<Listofsettledcustomer> {
  List<Backupedcustomermodel> custList = [];
  String? userId;
  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString("userId");

    if (userId != null) {
      // Load the local customer list if necessary
      custList = await ShowCustomer().backupedCustList(userId);

      // Notify provider after fetching data from API
      await fetchCustomerList(userId);
      setState(() {}); // Update the UI if needed
    } else {
      print("UserId is null");
    }
  }

  Future<void> fetchCustomerList(String userId) async {
    Provider.of<backupedCustomerProvider>(context, listen: false)
        .fetchCustomerList(userId);
  }

  String formateDate(String date) {
    try {
      DateTime parse = DateTime.parse(date);
      return DateFormat('dd-MM-yyyy hh:mm a').format(parse);
    } catch (e) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blueGrey[300],
        title: const Text("History Customer"),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body: Consumer<backupedCustomerProvider>(
        builder: (context, BackupedCustomerProvider, child) {
          if (BackupedCustomerProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (BackupedCustomerProvider.customers.isEmpty) {
            return Center(
              child: Text(
                "No customer data available.",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            );
          } else {
            return ListView.builder(
              itemCount: BackupedCustomerProvider.customers.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {},
                  child: Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.blueGrey[300],
                        child: BackupedCustomerProvider.customers[index].custPic != null &&
                               BackupedCustomerProvider.customers[index].custPic!.isNotEmpty
                            ? ClipOval(
                                child: Image.network(
                                  "${UrlConstant.showImage}/${BackupedCustomerProvider.customers[index].custPic}",
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Text(
                                      BackupedCustomerProvider.customers[index].custName.isNotEmpty
                                          ? BackupedCustomerProvider.customers[index].custName[0].toUpperCase()
                                          : '',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  },
                                ),
                              )
                            : Text(
                                BackupedCustomerProvider.customers[index].custName.isNotEmpty
                                    ? BackupedCustomerProvider.customers[index].custName[0].toUpperCase()
                                    : '',
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                      title: Text(
                          BackupedCustomerProvider.customers[index].custName),
                      subtitle: Text(formateDate(
                          BackupedCustomerProvider.customers[index].date)),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
