import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:interest_book/Login&Signup/splashScreen.dart';
import 'package:interest_book/Provider/backuped_customer_provider.dart';
import 'package:interest_book/Provider/customer_provider.dart';
import 'package:interest_book/Provider/deposite_provider.dart';
import 'package:interest_book/Provider/interest_provider.dart';
import 'package:interest_book/Provider/loan_provider.dart';
import 'package:interest_book/Provider/profile_provider.dart';
import 'package:interest_book/Provider/settled_loan_provider.dart';
import 'package:interest_book/Utils/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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
        ChangeNotifierProvider(create: (_) => LoanProvider()),
        ChangeNotifierProvider(create: (_) => Settledloanprovider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()..loadProfile()),
        ChangeNotifierProvider<backupedCustomerProvider>(
          create: (context) => backupedCustomerProvider(),
        ),
        ChangeNotifierProvider(create: (context) => Interestprovider()),
        ChangeNotifierProvider(create: (context) => Depositeprovider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blueGrey,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: AppColors.background,
          cardColor: AppColors.surface,
          dividerColor: AppColors.divider,
          // Enhanced text theme with better contrast
          textTheme: const TextTheme(
            displayLarge: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
            displayMedium: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
            displaySmall: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
            headlineLarge: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            headlineMedium: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            headlineSmall: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            titleLarge: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            titleMedium: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            titleSmall: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            bodyLarge: TextStyle(color: AppColors.textPrimary),
            bodyMedium: TextStyle(color: AppColors.textSecondary),
            bodySmall: TextStyle(color: AppColors.textSecondary),
            labelLarge: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            labelMedium: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            labelSmall: TextStyle(
              color: AppColors.textTertiary,
              fontWeight: FontWeight.w500,
            ),
          ),
          // Enhanced app bar theme
          appBarTheme: AppBarTheme(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 2,
            shadowColor: AppColors.shadowMedium,
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor:
                  AppColors.primaryDark, // Darker theme color for status bar
              statusBarIconBrightness: Brightness.light,
              statusBarBrightness: Brightness.dark,
            ),
            titleTextStyle: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          // Enhanced card theme
          cardTheme: CardTheme(
            color: AppColors.surface,
            elevation: 2,
            shadowColor: AppColors.shadowLight,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: AppColors.border, width: 0.5),
            ),
          ),
          // Enhanced elevated button theme
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 2,
              shadowColor: AppColors.shadowMedium,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        home: SplashScreen(),
      ),
    );
  }
}
