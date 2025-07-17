import 'package:flutter/material.dart';
import 'package:interest_book/Api/signup_api.dart';
import 'package:interest_book/Login&Signup/LoginScreen.dart';
import 'package:interest_book/Utils/app_colors.dart';
import 'package:interest_book/Utils/validation_helper.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final formkey = GlobalKey<FormState>();
  final RegExp emailValidatorRegExp = RegExp(
    r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
  );
  bool agreePersonalData = false;
  final emailcontroller = TextEditingController();
  final namecontroller = TextEditingController();
  final phncontroller = TextEditingController();
  final passwordcontroller = TextEditingController();
  final confirmpasscontroller = TextEditingController();
  bool isSimplePassword = true;
  bool isConfirmPassword = true;
  String? simplepass;
  String? confirmpass;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    var userSignup = signupApi();
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
    final fieldSpacing = isSmallScreen ? 12.0 : 16.0;

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
                minHeight:
                    screenHeight -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Top spacing - reduced
                    SizedBox(height: isSmallScreen ? 30 : 50),

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
                        Icons.person_add_rounded,
                        size: isSmallScreen ? 30 : 40,
                        color: Colors.white,
                      ),
                    ),

                    SizedBox(height: isSmallScreen ? 16 : 20),

                    // Welcome text
                    Text(
                      "Create Account",
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
                      "Join us to start managing your loans efficiently",
                      style: TextStyle(
                        fontSize: subtitleFontSize,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: isSmallScreen ? 20 : 30),

                    // Main signup container with modern design
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
                          padding: EdgeInsets.all(isSmallScreen ? 18 : 24),
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
                                    // Full Name field with modern design
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
                                        controller: namecontroller,
                                        keyboardType: TextInputType.name,
                                        style: TextStyle(
                                          fontSize: isSmallScreen ? 14 : 16,
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        decoration: InputDecoration(
                                          labelText: "Full Name",
                                          labelStyle: TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: isSmallScreen ? 12 : 14,
                                          ),
                                          prefixIcon: Container(
                                            margin: const EdgeInsets.all(10),
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Icon(
                                              Icons.person_outline,
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
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return "Full name is required";
                                          }
                                          return null;
                                        },
                                      ),
                                    ),

                                    SizedBox(height: fieldSpacing),

                                    // Phone Number field with modern design
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
                                        controller: phncontroller,
                                        keyboardType: TextInputType.phone,
                                        style: TextStyle(
                                          fontSize: isSmallScreen ? 14 : 16,
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        decoration: InputDecoration(
                                          labelText: "Phone Number",
                                          labelStyle: TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: isSmallScreen ? 12 : 14,
                                          ),
                                          errorStyle: TextStyle(
                                            color: AppColors.error,
                                            fontSize: isSmallScreen ? 11 : 12,
                                          ),
                                          errorMaxLines: 2,
                                          prefixIcon: Container(
                                            margin: const EdgeInsets.all(10),
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Icon(
                                              Icons.phone_outlined,
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
                                        validator: ValidationHelper.validateMobileNumber,
                                      ),
                                    ),

                                    SizedBox(height: fieldSpacing),

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
                                        keyboardType:
                                            TextInputType.emailAddress,
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
                                          errorStyle: TextStyle(
                                            color: AppColors.error,
                                            fontSize: isSmallScreen ? 11 : 12,
                                          ),
                                          errorMaxLines: 2,
                                          prefixIcon: Container(
                                            margin: const EdgeInsets.all(10),
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(6),
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

                                    SizedBox(height: fieldSpacing),

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
                                        keyboardType:
                                            TextInputType.visiblePassword,
                                        obscureText: isSimplePassword,
                                        obscuringCharacter: "•",
                                        style: TextStyle(
                                          fontSize: isSmallScreen ? 14 : 16,
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        onChanged: (value) {
                                          setState(() {
                                            simplepass = value;
                                          });
                                        },
                                        decoration: InputDecoration(
                                          labelText: "Password",
                                          labelStyle: TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: isSmallScreen ? 12 : 14,
                                          ),
                                          errorStyle: TextStyle(
                                            color: AppColors.error,
                                            fontSize: isSmallScreen ? 11 : 12,
                                          ),
                                          errorMaxLines: 2,
                                          prefixIcon: Container(
                                            margin: const EdgeInsets.all(10),
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(6),
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
                                                isSimplePassword =
                                                    !isSimplePassword;
                                              });
                                            },
                                            icon: Icon(
                                              isSimplePassword
                                                  ? Icons
                                                      .visibility_off_outlined
                                                  : Icons.visibility_outlined,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: isSmallScreen ? 16 : 20,
                                          ),
                                          focusedBorder: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                        ),
                                        validator: ValidationHelper.validatePassword,
                                      ),
                                    ),

                                    SizedBox(height: fieldSpacing),

                                    // Confirm Password field with modern design
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
                                        controller: confirmpasscontroller,
                                        keyboardType:
                                            TextInputType.visiblePassword,
                                        obscureText: isConfirmPassword,
                                        obscuringCharacter: "•",
                                        style: TextStyle(
                                          fontSize: isSmallScreen ? 16 : 18,
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        onChanged: (value) {
                                          setState(() {
                                            confirmpass = value;
                                          });
                                        },
                                        decoration: InputDecoration(
                                          labelText: "Confirm Password",
                                          labelStyle: TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: isSmallScreen ? 14 : 16,
                                          ),
                                          errorStyle: TextStyle(
                                            color: AppColors.error,
                                            fontSize: isSmallScreen ? 11 : 12,
                                          ),
                                          errorMaxLines: 2,
                                          prefixIcon: Container(
                                            margin: const EdgeInsets.all(12),
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                              Icons.lock_outline,
                                              color: AppColors.primary,
                                              size: 20,
                                            ),
                                          ),
                                          suffixIcon: IconButton(
                                            onPressed: () {
                                              setState(() {
                                                isConfirmPassword =
                                                    !isConfirmPassword;
                                              });
                                            },
                                            icon: Icon(
                                              isConfirmPassword
                                                  ? Icons
                                                      .visibility_off_outlined
                                                  : Icons.visibility_outlined,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: isSmallScreen ? 16 : 20,
                                          ),
                                          focusedBorder: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                        ),
                                        validator: (value) => ValidationHelper.validateConfirmPassword(value, simplepass),
                                      ),
                                    ),

                                    SizedBox(height: fieldSpacing),

                                    // Terms and conditions checkbox with modern design
                                    Container(
                                      padding: EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: AppColors.primarySurface,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: AppColors.borderLight,
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Checkbox(
                                            value: agreePersonalData,
                                            onChanged: (bool? value) {
                                              setState(() {
                                                agreePersonalData = value!;
                                              });
                                            },
                                            activeColor: AppColors.primary,
                                            checkColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                          ),
                                          Expanded(
                                            child: RichText(
                                              text: TextSpan(
                                                style: TextStyle(
                                                  fontSize:
                                                      isSmallScreen ? 14 : 16,
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                                children: [
                                                  TextSpan(
                                                    text: 'I agree to the ',
                                                  ),
                                                  TextSpan(
                                                    text: 'Terms of Service',
                                                    style: TextStyle(
                                                      color: AppColors.primary,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  TextSpan(text: ' and '),
                                                  TextSpan(
                                                    text: 'Privacy Policy',
                                                    style: TextStyle(
                                                      color: AppColors.primary,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    SizedBox(height: isSmallScreen ? 20 : 24),

                                    // Sign up button with modern design
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
                                            color: AppColors.primary
                                                .withOpacity(0.3),
                                            blurRadius: 12,
                                            offset: const Offset(0, 6),
                                          ),
                                        ],
                                      ),
                                      child: ElevatedButton(
                                        onPressed:
                                            isLoading
                                                ? null
                                                : () async {
                                                  if (formkey.currentState!
                                                          .validate() &&
                                                      agreePersonalData) {
                                                    setState(() {
                                                      isLoading = true;
                                                    });
                                                    formkey.currentState!
                                                        .save();

                                                    try {
                                                      final signupResponse =
                                                          await userSignup
                                                              .userSignup(
                                                                namecontroller
                                                                    .text,
                                                                phncontroller
                                                                    .text,
                                                                emailcontroller
                                                                    .text,
                                                                confirmpass!,
                                                              );

                                                      if (mounted) {
                                                        setState(() {
                                                          isLoading = false;
                                                        });

                                                        if (signupResponse
                                                            .success) {
                                                          formkey.currentState!
                                                              .reset();
                                                          if (mounted) {
                                                            Navigator.of(
                                                              context,
                                                            ).pushAndRemoveUntil(
                                                              MaterialPageRoute(
                                                                builder: (
                                                                  BuildContext
                                                                  context,
                                                                ) {
                                                                  return const LoginScreen();
                                                                },
                                                              ),
                                                              (route) => false,
                                                            );
                                                            ScaffoldMessenger.of(
                                                              context,
                                                            ).showSnackBar(
                                                              SnackBar(
                                                                content: Text(
                                                                  signupResponse
                                                                      .message,
                                                                ),
                                                                backgroundColor:
                                                                    AppColors
                                                                        .success,
                                                                behavior:
                                                                    SnackBarBehavior
                                                                        .floating,
                                                                shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        8,
                                                                      ),
                                                                ),
                                                              ),
                                                            );
                                                          }
                                                        } else {
                                                          if (mounted) {
                                                            ScaffoldMessenger.of(
                                                              context,
                                                            ).showSnackBar(
                                                              SnackBar(
                                                                content: Text(
                                                                  signupResponse
                                                                      .message,
                                                                ),
                                                                backgroundColor:
                                                                    AppColors
                                                                        .error,
                                                                behavior:
                                                                    SnackBarBehavior
                                                                        .floating,
                                                                shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        8,
                                                                      ),
                                                                ),
                                                              ),
                                                            );
                                                          }
                                                        }
                                                      }
                                                    } catch (e) {
                                                      if (mounted) {
                                                        setState(() {
                                                          isLoading = false;
                                                        });
                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).showSnackBar(
                                                          SnackBar(
                                                            content: const Text(
                                                              "Something went wrong. Please try again.",
                                                            ),
                                                            backgroundColor:
                                                                AppColors.error,
                                                            behavior:
                                                                SnackBarBehavior
                                                                    .floating,
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    8,
                                                                  ),
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                    }
                                                  } else if (!agreePersonalData) {
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      SnackBar(
                                                        content: const Text(
                                                          'Please agree to the Terms and Privacy Policy',
                                                        ),
                                                        backgroundColor:
                                                            AppColors.warning,
                                                        behavior:
                                                            SnackBarBehavior
                                                                .floating,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                8,
                                                              ),
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                        ),
                                        child:
                                            isLoading
                                                ? SizedBox(
                                                  height: 24,
                                                  width: 24,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2.5,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                          Color
                                                        >(Colors.white),
                                                  ),
                                                )
                                                : Text(
                                                  "Create Account",
                                                  style: TextStyle(
                                                    fontSize:
                                                        isSmallScreen ? 18 : 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                      ),
                                    ),

                                    SizedBox(height: isSmallScreen ? 20 : 24),

                                    // Login link
                                    Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            "Already have an account? ",
                                            style: TextStyle(
                                              fontSize: isSmallScreen ? 14 : 16,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.of(
                                                context,
                                              ).pushReplacement(
                                                MaterialPageRoute(
                                                  builder:
                                                      (context) =>
                                                          const LoginScreen(),
                                                ),
                                              );
                                            },
                                            child: Text(
                                              "Sign In",
                                              style: TextStyle(
                                                fontSize:
                                                    isSmallScreen ? 14 : 16,
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
