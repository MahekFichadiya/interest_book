import 'package:flutter/material.dart';
import 'package:interest_book/Utils/app_colors.dart';

/// Widget to generate app icon for different platforms
/// This can be used to create consistent app icons
class AppIconGenerator extends StatelessWidget {
  final double size;
  final bool forAndroid;
  final bool forIOS;

  const AppIconGenerator({
    super.key,
    this.size = 512.0,
    this.forAndroid = true,
    this.forIOS = false,
  });

  @override
  Widget build(BuildContext context) {
    // Different corner radius for different platforms
    final borderRadius = forIOS 
        ? size * 0.2237 // iOS standard corner radius
        : forAndroid 
            ? size * 0.2 // Android adaptive icon
            : size * 0.15; // Default

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: size * 0.02,
            offset: Offset(0, size * 0.01),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Main book icon
          Container(
            width: size * 0.6,
            height: size * 0.45,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(size * 0.02),
            ),
            child: Stack(
              children: [
                // Book spine
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: size * 0.08,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(size * 0.02),
                        bottomLeft: Radius.circular(size * 0.02),
                      ),
                    ),
                  ),
                ),
                // Book lines
                Positioned(
                  left: size * 0.12,
                  right: size * 0.05,
                  top: size * 0.08,
                  child: Column(
                    children: [
                      _buildBookLine(size * 0.4),
                      SizedBox(height: size * 0.03),
                      _buildBookLine(size * 0.4),
                      SizedBox(height: size * 0.03),
                      _buildBookLine(size * 0.4),
                      SizedBox(height: size * 0.03),
                      _buildBookLine(size * 0.3),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Currency symbol overlay
          Positioned(
            right: size * 0.15,
            bottom: size * 0.15,
            child: Container(
              width: size * 0.25,
              height: size * 0.25,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.accent,
                    AppColors.accent.withValues(alpha: 0.8),
                  ],
                ),
                border: Border.all(
                  color: Colors.white,
                  width: size * 0.01,
                ),
              ),
              child: Center(
                child: CustomPaint(
                  size: Size(size * 0.12, size * 0.12),
                  painter: RupeeSymbolPainter(
                    color: Colors.white,
                    strokeWidth: size * 0.008,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookLine(double width) {
    return Container(
      width: width,
      height: size * 0.008,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(size * 0.004),
      ),
    );
  }
}

/// Custom painter for Rupee symbol
class RupeeSymbolPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  RupeeSymbolPainter({
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final width = size.width;
    final height = size.height;

    // Top horizontal line
    canvas.drawLine(
      Offset(width * 0.1, height * 0.2),
      Offset(width * 0.9, height * 0.2),
      paint,
    );

    // Middle horizontal line
    canvas.drawLine(
      Offset(width * 0.1, height * 0.4),
      Offset(width * 0.7, height * 0.4),
      paint,
    );

    // Vertical line
    canvas.drawLine(
      Offset(width * 0.2, height * 0.2),
      Offset(width * 0.2, height * 0.9),
      paint,
    );

    // Diagonal line
    canvas.drawLine(
      Offset(width * 0.2, height * 0.5),
      Offset(width * 0.8, height * 0.9),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Demo widget to show how the icon looks at different sizes
class AppIconDemo extends StatelessWidget {
  const AppIconDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('App Icon Generator'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'App Icon Preview',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            
            // Different sizes
            Text(
              'Different Sizes:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Column(
                  children: [
                    AppIconGenerator(size: 120),
                    const SizedBox(height: 8),
                    Text('120x120', style: TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
                const SizedBox(width: 20),
                Column(
                  children: [
                    AppIconGenerator(size: 80),
                    const SizedBox(height: 8),
                    Text('80x80', style: TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
                const SizedBox(width: 20),
                Column(
                  children: [
                    AppIconGenerator(size: 60),
                    const SizedBox(height: 8),
                    Text('60x60', style: TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Platform specific
            Text(
              'Platform Specific:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Column(
                  children: [
                    AppIconGenerator(size: 100, forAndroid: true, forIOS: false),
                    const SizedBox(height: 8),
                    Text('Android', style: TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
                const SizedBox(width: 20),
                Column(
                  children: [
                    AppIconGenerator(size: 100, forAndroid: false, forIOS: true),
                    const SizedBox(height: 8),
                    Text('iOS', style: TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Instructions
            Container(
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
                    'How to use as App Icon:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.info,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '1. Use this widget to generate icons at required sizes\n'
                    '2. Take screenshots or export as images\n'
                    '3. Replace the default app icons in android/app/src/main/res/\n'
                    '4. For iOS, replace icons in ios/Runner/Assets.xcassets/AppIcon.appiconset/\n'
                    '5. Common sizes: 48x48, 72x72, 96x96, 144x144, 192x192 (Android)\n'
                    '6. iOS sizes: 29x29, 40x40, 60x60, 76x76, 83.5x83.5, 1024x1024',
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
}
