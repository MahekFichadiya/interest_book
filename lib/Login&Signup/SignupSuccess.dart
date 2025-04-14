import "package:flutter/material.dart";
import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'package:interest_book/DashboardScreen.dart';
import 'package:lottie/lottie.dart';

class SignupSuccess extends StatelessWidget {
  const SignupSuccess({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterSplashScreen(
        backgroundColor: Colors.white,
        useImmersiveMode: true,
        duration: Duration(milliseconds: 3000),
        nextScreen: DashboardScreen(),
        // backgroundColor: Colors.blueGrey[100],
        splashScreenBody: Center(
          child: SizedBox(
            height: 300,
            child: Lottie.asset(
              'assest/AnimationSignupSuccess.json',
            ),
          ),
        ),
      ),
    );
  }
}