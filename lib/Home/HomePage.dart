import 'package:flutter/material.dart';
import 'package:interest_book/Contact/ContactList.dart';
import 'package:interest_book/Home/CustomerList.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[300],
        title: const Text("Interest Book"),
      ),
      body: Column(
        children: [
          // Container(
          //   height: 150,
          //   decoration: BoxDecoration(
          //     color: Colors.blueGrey[200],
          //   ),
          //   child: Center(
          //     child: Container(
          //       height: 120,
          //       width: 300,
          //       decoration: const BoxDecoration(
          //         color: Colors.white,
          //       ),
          //       child: const Column(
          //         children: [
          //           Row(
          //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //             children: [
          //               Column(
          //                 children: [
          //                   Text(
          //                     "₹25000",
          //                     style: TextStyle(
          //                       fontSize: 20,
          //                       fontWeight: FontWeight.bold,
          //                       color: Colors.red,
          //                     ),
          //                   ),
          //                   Text(
          //                     "You gave ↓",
          //                     style: TextStyle(
          //                       fontSize: 12,
          //                       fontWeight: FontWeight.bold,
          //                       color: Colors.black,
          //                     ),
          //                   ),
          //                 ],
          //               ),
          //               Column(
          //                 children: [
          //                   Text(
          //                     "₹0",
          //                     style: TextStyle(
          //                       fontSize: 20,
          //                       fontWeight: FontWeight.bold,
          //                       color: Colors.green,
          //                     ),
          //                   ),
          //                   Text(
          //                     "You got ↑",
          //                     style: TextStyle(
          //                       fontSize: 12,
          //                       fontWeight: FontWeight.bold,
          //                       color: Colors.black,
          //                     ),
          //                   ),
          //                 ],
          //               ),
          //             ],
          //           ),
          //           Divider(
          //             height: 20,
          //           ),
          //           Text(
          //             "Downlod the Report",
          //             style: TextStyle(
          //               fontSize: 20,
          //               fontWeight: FontWeight.bold,
          //               decoration: TextDecoration.underline,
          //               decorationThickness: 2,
          //             ),
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),
          Expanded(child: CustomerList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) => const ContactList(title: "Contact",),
            ),
          );
        },
        child: const Icon(Icons.phone),
      ),
    );
  }
}
