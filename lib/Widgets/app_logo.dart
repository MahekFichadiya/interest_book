import 'package:flutter/material.dart';
import 'package:interest_book/Utils/app_colors.dart';

/// Custom app logo widget for Interest Book application
/// Creates an icon-based logo similar to WhatsApp/Instagram style
class AppLogo extends StatelessWidget {
  final double size;
  final bool showShadow;
  final bool showBackground;
  final Color? backgroundColor;
  final Color? iconColor;

  const AppLogo({
    super.key,
    this.size = 60.0,
    this.showShadow = true,
    this.showBackground = true,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppColors.primary;
    final foregroundColor = iconColor ?? Colors.white;
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: showBackground ? bgColor : Colors.transparent,
        borderRadius: BorderRadius.circular(size * 0.2), // 20% border radius
        boxShadow: showShadow ? [
          BoxShadow(
            color: AppColors.shadowMedium,
            blurRadius: size * 0.1,
            offset: Offset(0, size * 0.05),
          ),
        ] : null,
        gradient: showBackground ? LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            bgColor,
            bgColor.withValues(alpha: 0.8),
          ],
        ) : null,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Main book icon
          Icon(
            Icons.menu_book_rounded,
            size: size * 0.45,
            color: foregroundColor,
          ),
          // Currency symbol overlay
          Positioned(
            right: size * 0.15,
            bottom: size * 0.15,
            child: Container(
              width: size * 0.25,
              height: size * 0.25,
              decoration: BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: foregroundColor,
                  width: size * 0.02,
                ),
              ),
              child: Icon(
                Icons.currency_rupee,
                size: size * 0.15,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Alternative logo design with calculator theme
class AppLogoCalculator extends StatelessWidget {
  final double size;
  final bool showShadow;
  final bool showBackground;
  final Color? backgroundColor;
  final Color? iconColor;

  const AppLogoCalculator({
    super.key,
    this.size = 60.0,
    this.showShadow = true,
    this.showBackground = true,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppColors.primary;
    final foregroundColor = iconColor ?? Colors.white;
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: showBackground ? bgColor : Colors.transparent,
        borderRadius: BorderRadius.circular(size * 0.2),
        boxShadow: showShadow ? [
          BoxShadow(
            color: AppColors.shadowMedium,
            blurRadius: size * 0.1,
            offset: Offset(0, size * 0.05),
          ),
        ] : null,
        gradient: showBackground ? LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            bgColor,
            bgColor.withValues(alpha: 0.8),
          ],
        ) : null,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Calculator base
          Icon(
            Icons.calculate_rounded,
            size: size * 0.5,
            color: foregroundColor,
          ),
          // Percentage symbol overlay
          Positioned(
            right: size * 0.12,
            top: size * 0.12,
            child: Container(
              width: size * 0.2,
              height: size * 0.2,
              decoration: BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: foregroundColor,
                  width: size * 0.015,
                ),
              ),
              child: Center(
                child: Text(
                  '%',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: size * 0.12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Minimalist logo with just initials
class AppLogoMinimal extends StatelessWidget {
  final double size;
  final bool showShadow;
  final bool showBackground;
  final Color? backgroundColor;
  final Color? textColor;
  final String initials;

  const AppLogoMinimal({
    super.key,
    this.size = 60.0,
    this.showShadow = true,
    this.showBackground = true,
    this.backgroundColor,
    this.textColor,
    this.initials = 'IB', // Interest Book
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppColors.primary;
    final foregroundColor = textColor ?? Colors.white;
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: showBackground ? bgColor : Colors.transparent,
        borderRadius: BorderRadius.circular(size * 0.2),
        boxShadow: showShadow ? [
          BoxShadow(
            color: AppColors.shadowMedium,
            blurRadius: size * 0.1,
            offset: Offset(0, size * 0.05),
          ),
        ] : null,
        gradient: showBackground ? LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            bgColor,
            bgColor.withValues(alpha: 0.8),
          ],
        ) : null,
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: foregroundColor,
            fontSize: size * 0.35,
            fontWeight: FontWeight.bold,
            letterSpacing: size * 0.02,
          ),
        ),
      ),
    );
  }
}

/// Animated logo with subtle animation
class AppLogoAnimated extends StatefulWidget {
  final double size;
  final bool showShadow;
  final bool showBackground;
  final Color? backgroundColor;
  final Color? iconColor;

  const AppLogoAnimated({
    super.key,
    this.size = 60.0,
    this.showShadow = true,
    this.showBackground = true,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  State<AppLogoAnimated> createState() => _AppLogoAnimatedState();
}

class _AppLogoAnimatedState extends State<AppLogoAnimated>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: AppLogo(
              size: widget.size,
              showShadow: widget.showShadow,
              showBackground: widget.showBackground,
              backgroundColor: widget.backgroundColor,
              iconColor: widget.iconColor,
            ),
          ),
        );
      },
    );
  }
}
