import 'package:flutter/material.dart';
import 'package:interest_book/Login&Signup/splashScreen.dart';
import 'package:interest_book/Provider/LoanProvider.dart';
import 'package:interest_book/Provider/ProfileProvider.dart';
import 'package:interest_book/Provider/backupedCustomerProvider.dart';
import 'package:interest_book/Provider/depositeProvider.dart';
import 'package:interest_book/Provider/settledLoanProvider.dart';
import 'package:provider/provider.dart';
import 'Provider/CustomerProvider.dart';
import 'Provider/interestProvider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CustomerProvider>(
          create: (context) => CustomerProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => LoanProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => Settledloanprovider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ProfileProvider()..loadProfile(),
        ),
        ChangeNotifierProvider<backupedCustomerProvider>(
          create: (context) => backupedCustomerProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => Interestprovider(),
        ),
        ChangeNotifierProvider(
          create: (context) => Depositeprovider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blueGrey,
        ),
        home: SplashScreen(),
      ),
    );
  }
}
