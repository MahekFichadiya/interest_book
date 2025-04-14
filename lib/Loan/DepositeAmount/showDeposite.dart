import 'package:flutter/material.dart';
import 'package:interest_book/Provider/depositeProvider.dart';
import 'package:provider/provider.dart';

class ShowDeposite extends StatefulWidget {
  final String amount;
  final String date;
  final String note;
  final String loanId;
  const ShowDeposite({
    super.key,
    required this.amount,
    required this.date,
    required this.note,
    required this.loanId,
  });

  @override
  State<ShowDeposite> createState() => _ShowDepositeState();
}

class _ShowDepositeState extends State<ShowDeposite> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchDepositeData();
    });
  }

  Future<void> fetchDepositeData() async {
    // Ensure data is refreshed when the page is loaded
    await Provider.of<Depositeprovider>(context, listen: false)
        .fetchDepositeList(widget.loanId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blueGrey.shade300,
        title: Text("Deposite"),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body: Consumer<Depositeprovider>(
        builder: (context, depositeprovider, child) {
          if (depositeprovider.isLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (depositeprovider.deposite.isEmpty) {
            return Center(
              child: Text(
                "No Deposit data available.",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            );
          } else {
            return ListView.builder(
              itemCount: depositeprovider.deposite.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title:
                        Text(depositeprovider.deposite[index].depositeAmount),
                    subtitle:
                        Text(depositeprovider.deposite[index].depositeDate),
                    trailing:
                        Text(depositeprovider.deposite[index].depositeNote),
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
