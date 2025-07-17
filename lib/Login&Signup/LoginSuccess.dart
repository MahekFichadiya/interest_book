import 'package:flutter/material.dart';
import 'package:interest_book/DashboardScreen.dart';
import 'package:interest_book/Utils/app_colors.dart';

class LoginSuccess extends StatefulWidget {
  const LoginSuccess({super.key});

  @override
  State<LoginSuccess> createState() => _LoginSuccessState();
}

class _LoginSuccessState extends State<LoginSuccess>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _textAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _textAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Initialize animations
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textAnimationController,
      curve: Curves.easeOutBack,
    ));

    // Start animations
    _startAnimations();
    
    // Navigate to dashboard after delay
    _navigateToHome();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _animationController.forward();
    
    await Future.delayed(const Duration(milliseconds: 800));
    _textAnimationController.forward();
  }

  void _navigateToHome() async {
    await Future.delayed(const Duration(milliseconds: 3000));
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const DashboardScreen(),
        ),
        (route) => false,
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _textAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final isSmallScreen = screenHeight < 700;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SafeArea(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.background,
                  AppColors.primarySurface,
                  AppColors.background,
                ],
              ),
            ),
            child: Center(
              child: SingleChildScrollView(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                // Floating background elements
                ...List.generate(6, (index) {
                  return AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      final delay = index * 0.2;
                      final animationValue = (_animationController.value - delay).clamp(0.0, 1.0);
                      return Positioned(
                        left: (index % 3) * (screenSize.width / 3) + (index * 20) - 100,
                        top: (index ~/ 3) * (screenSize.height / 4) + (index * 30) - 200,
                        child: Opacity(
                          opacity: animationValue * 0.08,
                          child: Transform.scale(
                            scale: animationValue,
                            child: Container(
                              width: 40 + (index * 8),
                              height: 40 + (index * 8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    AppColors.primary.withValues(alpha: 0.15),
                                    AppColors.primaryLight.withValues(alpha: 0.1),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),
        
                // Main content - properly centered
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                // Success Animation with modern design
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer glow effect
                            Container(
                              width: isSmallScreen ? 220 : 270,
                              height: isSmallScreen ? 220 : 270,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    AppColors.primary.withValues(alpha: 0.1),
                                    AppColors.primaryLight.withValues(alpha: 0.05),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                            // Main success container
                            Container(
                              width: isSmallScreen ? 180 : 220,
                              height: isSmallScreen ? 180 : 220,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.2),
                                    blurRadius: 25,
                                    spreadRadius: 5,
                                    offset: const Offset(0, 8),
                                  ),
                                  BoxShadow(
                                    color: AppColors.primaryDark.withValues(alpha: 0.1),
                                    blurRadius: 15,
                                    spreadRadius: 0,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Container(
                                  width: isSmallScreen ? 100 : 130,
                                  height: isSmallScreen ? 100 : 130,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        AppColors.primary,
                                        AppColors.primaryDark,
                                      ],
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.check_rounded,
                                    size: isSmallScreen ? 50 : 65,
                                    color: Colors.white,
                                    weight: 3.0,
                                  ),
                                ),
                              ),
                            ),
                            // Animated ring
                            AnimatedBuilder(
                              animation: _animationController,
                              builder: (context, child) {
                                return Transform.rotate(
                                  angle: _animationController.value * 2 * 3.14159,
                                  child: Container(
                                    width: isSmallScreen ? 200 : 240,
                                    height: isSmallScreen ? 200 : 240,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.primary.withValues(alpha: 0.3),
                                        width: 2,
                                      ),
                                    ),
                                    child: CustomPaint(
                                      painter: _RingPainter(
                                        progress: _animationController.value,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        
                SizedBox(height: isSmallScreen ? 40 : 50),
        
                // Success Text
                AnimatedBuilder(
                  animation: _textAnimationController,
                  builder: (context, child) {
                    return SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _textAnimationController,
                        child: Column(
                          children: [
                            // Main welcome text with blue-gray gradient effect
                            ShaderMask(
                              shaderCallback: (bounds) => LinearGradient(
                                colors: [
                                  AppColors.primary,
                                  AppColors.primaryDark,
                                ],
                              ).createShader(bounds),
                              child: Text(
                                'Welcome Back!',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 28 : 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
        
                            SizedBox(height: isSmallScreen ? 16 : 20),
        
                            // Success message with icon
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isSmallScreen ? 20 : 24,
                                vertical: isSmallScreen ? 8 : 12,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color: AppColors.primary.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check_circle_rounded,
                                    color: AppColors.primary,
                                    size: isSmallScreen ? 18 : 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Login Successful',
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 16 : 18,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
        
                            SizedBox(height: isSmallScreen ? 12 : 16),
        
                            Text(
                              'Redirecting to dashboard...',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 14 : 16,
                                color: AppColors.textSecondary.withValues(alpha: 0.7),
                                fontStyle: FontStyle.italic,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        
                SizedBox(height: isSmallScreen ? 60 : 80),
        
                // Loading indicator
                AnimatedBuilder(
                  animation: _textAnimationController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _textAnimationController,
                      child: SizedBox(
                        width: isSmallScreen ? 24 : 28,
                        height: isSmallScreen ? 24 : 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                  ],
                ),
                ),
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

// Custom painter for animated ring effect
class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;

  _RingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // Draw animated arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2, // Start from top
      2 * 3.14159 * progress, // Progress-based sweep
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is _RingPainter && oldDelegate.progress != progress;
  }
}
