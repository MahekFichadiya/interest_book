import 'package:flutter/material.dart';
import 'package:interest_book/Utils/app_colors.dart';
import 'package:interest_book/Widgets/app_logo.dart';
import 'package:interest_book/Widgets/app_icon_generator.dart';

/// Demo page to showcase different logo variations
class LogoShowcase extends StatelessWidget {
  const LogoShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('App Logo Showcase'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AppIconDemo(),
                ),
              );
            },
            icon: const Icon(Icons.apps),
            tooltip: 'App Icon Generator',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Choose Your App Logo',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select the logo style that best represents your Interest Book application',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),

            // Main Logo (Book + Currency)
            _buildLogoSection(
              title: '1. Main Logo (Recommended)',
              description: 'Book icon with currency symbol - perfect for financial apps',
              child: Row(
                children: [
                  AppLogo(size: 80),
                  const SizedBox(width: 20),
                  AppLogo(size: 60),
                  const SizedBox(width: 20),
                  AppLogo(size: 40),
                ],
              ),
            ),

            // Calculator Logo
            _buildLogoSection(
              title: '2. Calculator Logo',
              description: 'Calculator icon with percentage - emphasizes calculations',
              child: Row(
                children: [
                  AppLogoCalculator(size: 80),
                  const SizedBox(width: 20),
                  AppLogoCalculator(size: 60),
                  const SizedBox(width: 20),
                  AppLogoCalculator(size: 40),
                ],
              ),
            ),

            // Minimal Logo
            _buildLogoSection(
              title: '3. Minimal Logo',
              description: 'Clean initials design - modern and simple',
              child: Row(
                children: [
                  AppLogoMinimal(size: 80, initials: 'IB'),
                  const SizedBox(width: 20),
                  AppLogoMinimal(size: 60, initials: 'IB'),
                  const SizedBox(width: 20),
                  AppLogoMinimal(size: 40, initials: 'IB'),
                ],
              ),
            ),

            // Animated Logo
            _buildLogoSection(
              title: '4. Animated Logo',
              description: 'Same as main logo but with subtle animation',
              child: Row(
                children: [
                  AppLogoAnimated(size: 80),
                  const SizedBox(width: 20),
                  AppLogoAnimated(size: 60),
                  const SizedBox(width: 20),
                  AppLogoAnimated(size: 40),
                ],
              ),
            ),

            // Color Variations
            _buildLogoSection(
              title: '5. Color Variations',
              description: 'Different color schemes for various contexts',
              child: Column(
                children: [
                  Row(
                    children: [
                      AppLogo(
                        size: 60,
                        backgroundColor: AppColors.accent,
                      ),
                      const SizedBox(width: 20),
                      AppLogo(
                        size: 60,
                        backgroundColor: AppColors.success,
                      ),
                      const SizedBox(width: 20),
                      AppLogo(
                        size: 60,
                        backgroundColor: AppColors.warning,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      AppLogo(
                        size: 60,
                        backgroundColor: Colors.white,
                        iconColor: AppColors.primary,
                        showShadow: true,
                      ),
                      const SizedBox(width: 20),
                      AppLogo(
                        size: 60,
                        showBackground: false,
                        iconColor: AppColors.primary,
                        showShadow: false,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Usage Examples
            _buildLogoSection(
              title: '6. Usage Examples',
              description: 'How the logo looks in different contexts',
              child: Column(
                children: [
                  // App Bar Example
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        AppLogo(size: 40),
                        const SizedBox(width: 12),
                        Text(
                          'Interest Book',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Card Example
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadowLight,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        AppLogo(size: 60),
                        const SizedBox(height: 12),
                        Text(
                          'Interest Book',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Manage your loans with ease',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
            
            // Implementation Note
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.infoLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.infoBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Implementation',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.info,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'To use these logos in your app:\n'
                    '• Import: import \'package:interest_book/Widgets/app_logo.dart\';\n'
                    '• Use: AppLogo(size: 60) or any other variation\n'
                    '• Customize colors, size, and effects as needed',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoSection({
    required String title,
    required String description,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowLight,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}
