import 'package:flutter/material.dart';
import 'package:interest_book/DashboardScreen.dart';
import 'package:interest_book/Login&Signup/LoginScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool login = false;
  loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    login = prefs.getBool("login") ?? false;
  }

  @override
  void initState() {
    super.initState();
    loadData();
    _navigatetohome();
  }

  _navigatetohome() async {
    await Future.delayed(
      const Duration(seconds: 4),
      () {},
    );
    // ignore: use_build_context_synchronously
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (BuildContext context) {
          return checkLogin();
        },
      ),
      (route) => false,
    );
  }

  checkLogin() {
    if (login) {
      return const DashboardScreen();
    } else {
      return const LoginScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assest/OM.png',
            ),
            const Text(
              "Om Jewellers",
              style: TextStyle(
                color: Colors.black,
                fontSize: 40,
                fontWeight: FontWeight.bold,
                fontFamily: "TiltPrism",
                decoration: TextDecoration.underline,
                decorationThickness: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
