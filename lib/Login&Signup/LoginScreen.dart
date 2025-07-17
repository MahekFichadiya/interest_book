import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:interest_book/Api/login_api.dart';
import 'package:interest_book/Login&Signup/SignupScreen.dart';
import 'package:interest_book/Login&Signup/LoginSuccess.dart';
import 'package:interest_book/Login&Signup/ForgotPasswordScreen.dart';
import 'package:interest_book/Utils/app_colors.dart';
import 'package:interest_book/Utils/validation_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formkey = GlobalKey<FormState>();
  final emailcontroller = TextEditingController();
  final passwordcontroller = TextEditingController();
  bool ispassword = true;
  final RegExp emailValidatorRegExp =
      RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
  bool isloading = false;
  String? email, password;
  bool? login;

  userData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    login = prefs.getBool("login");
    email = prefs.getString("email");
    // Note: Password is no longer stored for security reasons
  }

  @override
  void initState() {
    userData();
    super.initState();
  }

  storeLoginData() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Do you want to save login data?"),
          actions: [
            TextButton(
              onPressed: () async {
                formkey.currentState!.save();
                setState(() {
                  isloading = true;
                });
                // Always authenticate with server for security
                var loginResponse = await LoginAPI()
                    .userLogin(emailcontroller.text, passwordcontroller.text);
                if (loginResponse.success) {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  prefs.setBool("login", true);
                  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
                    builder: (BuildContext context) {
                      return const LoginSuccess();
                    },
                  ), (route) => false);
                } else {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(loginResponse.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text("Yes"),
            ),
            TextButton(
              onPressed: () async {
                formkey.currentState!.save();
                setState(() {
                  isloading = true;
                });
                var loginResponse = await LoginAPI()
                    .userLogin(emailcontroller.text, passwordcontroller.text);
                if (loginResponse.success) {
                  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
                    builder: (BuildContext context) {
                      return const LoginSuccess();
                    },
                  ), (route) => false);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(loginResponse.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text("Cancle"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;
    final isSmallScreen = screenHeight < 700;
    final isTablet = screenWidth > 600;

    // Responsive dimensions - reduced sizes with safe margins
    final containerMaxWidth = isTablet ? 350.0 : screenWidth * 0.82;
    final horizontalPadding = isTablet ? 24.0 : 20.0;
    final titleFontSize = isSmallScreen ? 24.0 : 28.0;
    final subtitleFontSize = isSmallScreen ? 12.0 : 14.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryLight.withOpacity(0.1),
              AppColors.background,
              AppColors.primarySurface,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: screenHeight - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Top spacing - reduced
                    SizedBox(height: isSmallScreen ? 40 : 60),

                    // App Logo/Icon - smaller
                    Container(
                      height: isSmallScreen ? 60 : 80,
                      width: isSmallScreen ? 60 : 80,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.account_balance_wallet_rounded,
                        size: isSmallScreen ? 30 : 40,
                        color: Colors.white,
                      ),
                    ),

                    SizedBox(height: isSmallScreen ? 16 : 20),

                    // Welcome text
                    Text(
                      "Welcome Back!",
                      style: TextStyle(
                        fontSize: titleFontSize,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: isSmallScreen ? 6 : 8),

                    // Subtitle
                    Text(
                      "Sign in to continue managing your loans",
                      style: TextStyle(
                        fontSize: subtitleFontSize,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: isSmallScreen ? 20 : 30),

                    // Main login container with modern design
                    Center(
                      child: Container(
                        width: containerMaxWidth,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.shadowLight,
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.05),
                              blurRadius: 40,
                              offset: const Offset(0, 16),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                            // Form with modern styling
                            Form(
                              key: formkey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Email field with modern design
                                  Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceVariant,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: AppColors.borderLight,
                                        width: 1,
                                      ),
                                    ),
                                    child: TextFormField(
                                      controller: emailcontroller,
                                      keyboardType: TextInputType.emailAddress,
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 14 : 16,
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      decoration: InputDecoration(
                                        labelText: "Email Address",
                                        labelStyle: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: isSmallScreen ? 12 : 14,
                                        ),
                                        prefixIcon: Container(
                                          margin: const EdgeInsets.all(10),
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Icon(
                                            Icons.email_outlined,
                                            color: AppColors.primary,
                                            size: 18,
                                          ),
                                        ),
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: isSmallScreen ? 10 : 14,
                                        ),
                                        focusedBorder: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                      ),
                                      validator: ValidationHelper.validateEmail,
                                    ),
                                  ),

                                  SizedBox(height: isSmallScreen ? 12 : 16),

                                  // Password field with modern design
                                  Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceVariant,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: AppColors.borderLight,
                                        width: 1,
                                      ),
                                    ),
                                    child: TextFormField(
                                      controller: passwordcontroller,
                                      keyboardType: TextInputType.visiblePassword,
                                      obscureText: ispassword,
                                      obscuringCharacter: "•",
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 14 : 16,
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      decoration: InputDecoration(
                                        labelText: "Password",
                                        labelStyle: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: isSmallScreen ? 12 : 14,
                                        ),
                                        prefixIcon: Container(
                                          margin: const EdgeInsets.all(10),
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Icon(
                                            Icons.lock_outline,
                                            color: AppColors.primary,
                                            size: 18,
                                          ),
                                        ),
                                        suffixIcon: IconButton(
                                          onPressed: () {
                                            setState(() {
                                              ispassword = !ispassword;
                                            });
                                          },
                                          icon: Icon(
                                            ispassword
                                                ? Icons.visibility_off_outlined
                                                : Icons.visibility_outlined,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: isSmallScreen ? 10 : 14,
                                        ),
                                        focusedBorder: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Password is required";
                                        }
                                        return null;
                                      },
                                    ),
                                  ),

                                  SizedBox(height: isSmallScreen ? 16 : 20),
                                  // Forgot Password link
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => const ForgotPasswordScreen(),
                                          ),
                                        );
                                      },
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                      ),
                                      child: Text(
                                        "Forgot Password?",
                                        style: TextStyle(
                                          fontSize: isSmallScreen ? 14 : 16,
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: isSmallScreen ? 20 : 24),
                                  // Login button with modern design
                                  Container(
                                    width: double.infinity,
                                    height: isSmallScreen ? 48 : 56,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors.primary,
                                          AppColors.primaryDark,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primary.withOpacity(0.3),
                                          blurRadius: 12,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: ElevatedButton(
                                      onPressed: isloading ? null : () async {
                                        if (formkey.currentState!.validate()) {
                                          formkey.currentState!.save();
                                          setState(() {
                                            isloading = true;
                                          });

                                          try {
                                            var loginResponse = await LoginAPI()
                                                .userLogin(emailcontroller.text, passwordcontroller.text);

                                            if (mounted) {
                                              if (loginResponse.success) {
                                                formkey.currentState!.reset();
                                                emailcontroller.clear();
                                                passwordcontroller.clear();

                                                if (mounted) {
                                                  showDialog(
                                                    context: context,
                                                    barrierDismissible: false,
                                                    builder: (dialogContext) {
                                                      return AlertDialog(
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(16),
                                                        ),
                                                        title: Text(
                                                          "Save Login Data?",
                                                          style: TextStyle(
                                                            color: AppColors.textPrimary,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                        content: Text(
                                                          "Would you like to save your login information for faster access next time?",
                                                          style: TextStyle(
                                                            color: AppColors.textSecondary,
                                                          ),
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () {
                                                              if (mounted) {
                                                                Navigator.of(dialogContext).pop();
                                                                Navigator.of(context).pushAndRemoveUntil(
                                                                  MaterialPageRoute(
                                                                    builder: (context) => const LoginSuccess(),
                                                                  ),
                                                                  (route) => false,
                                                                );
                                                              }
                                                            },
                                                            child: Text(
                                                              "Skip",
                                                              style: TextStyle(
                                                                color: AppColors.textSecondary,
                                                              ),
                                                            ),
                                                          ),
                                                          ElevatedButton(
                                                            onPressed: () async {
                                                              SharedPreferences prefs = await SharedPreferences.getInstance();
                                                              prefs.setBool("login", true);
                                                              if (mounted) {
                                                                Navigator.of(dialogContext).pop();
                                                                Navigator.of(context).pushAndRemoveUntil(
                                                                  MaterialPageRoute(
                                                                    builder: (context) => const LoginSuccess(),
                                                                  ),
                                                                  (route) => false,
                                                                );
                                                              }
                                                            },
                                                            style: ElevatedButton.styleFrom(
                                                              backgroundColor: AppColors.primary,
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.circular(8),
                                                              ),
                                                            ),
                                                            child: const Text(
                                                              "Save",
                                                              style: TextStyle(color: Colors.white),
                                                            ),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                }
                                              } else {
                                                if (mounted) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text(loginResponse.message),
                                                      backgroundColor: AppColors.error,
                                                      behavior: SnackBarBehavior.floating,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      duration: const Duration(seconds: 4),
                                                    ),
                                                  );
                                                }
                                              }
                                            }
                                          } catch (e) {
                                            if (mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: const Text("Something went wrong. Please try again."),
                                                  backgroundColor: AppColors.error,
                                                  behavior: SnackBarBehavior.floating,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  duration: const Duration(seconds: 4),
                                                ),
                                              );
                                            }
                                          } finally {
                                            if (mounted) {
                                              setState(() {
                                                isloading = false;
                                              });
                                            }
                                          }
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                      ),
                                      child: isloading
                                          ? SizedBox(
                                              height: 24,
                                              width: 24,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.5,
                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                              ),
                                            )
                                          : Text(
                                              "Sign In",
                                              style: TextStyle(
                                                fontSize: isSmallScreen ? 18 : 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: isSmallScreen ? 20 : 24),

                            // Signup link
                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Don't have an account? ",
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 14 : 16,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                          builder: (context) => const SignupScreen(),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      "Sign Up",
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 14 : 16,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Bottom spacing
                    SizedBox(height: isSmallScreen ? 30 : 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
