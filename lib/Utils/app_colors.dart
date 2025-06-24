import 'package:flutter/material.dart';

/// Centralized color system for the Interest Book application
/// Provides consistent colors with proper contrast ratios for accessibility
class AppColors {
  
  // ============================================================================
  // PRIMARY THEME COLORS (Blue-Grey Theme)
  // ============================================================================
  
  /// Primary blue-grey color palette
  static const Color primary = Color(0xFF455A64); // Blue Grey 700
  static const Color primaryLight = Color(0xFF78909C); // Blue Grey 400
  static const Color primaryDark = Color(0xFF263238); // Blue Grey 900
  static const Color primarySurface = Color(0xFFECEFF1); // Blue Grey 50
  
  /// Secondary accent colors
  static const Color accent = Color(0xFF0277BD); // Light Blue 800
  static const Color accentLight = Color(0xFF4FC3F7); // Light Blue 300
  
  // ============================================================================
  // SEMANTIC COLORS (High Contrast for Accessibility)
  // ============================================================================
  
  /// Success colors (for advance payments, positive actions)
  static const Color success = Color(0xFF2E7D32); // Green 800 - WCAG AA compliant
  static const Color successLight = Color(0xFFE8F5E8); // Light green background
  static const Color successBorder = Color(0xFF4CAF50); // Green 500
  static const Color successSurface = Color(0xFFF1F8E9); // Green 50
  
  /// Warning colors (for amounts due, pending actions)
  static const Color warning = Color(0xFFE65100); // Orange 900 - WCAG AA compliant
  static const Color warningLight = Color(0xFFFFF3E0); // Light orange background
  static const Color warningBorder = Color(0xFFFF9800); // Orange 500
  static const Color warningSurface = Color(0xFFFFF8E1); // Orange 50
  
  /// Error colors (for overdue, critical issues)
  static const Color error = Color(0xFFC62828); // Red 800 - WCAG AA compliant
  static const Color errorLight = Color(0xFFFFEBEE); // Light red background
  static const Color errorBorder = Color(0xFFF44336); // Red 500
  static const Color errorSurface = Color(0xFFFDE7E7); // Red 50
  
  /// Info colors (for neutral information)
  static const Color info = Color(0xFF1565C0); // Blue 800 - WCAG AA compliant
  static const Color infoLight = Color(0xFFE3F2FD); // Light blue background
  static const Color infoBorder = Color(0xFF2196F3); // Blue 500
  static const Color infoSurface = Color(0xFFF3F9FF); // Blue 50
  
  // ============================================================================
  // NEUTRAL COLORS (Text and Backgrounds)
  // ============================================================================
  
  /// Text colors with proper contrast ratios
  static const Color textPrimary = Color(0xFF212121); // Grey 900 - Highest contrast
  static const Color textSecondary = Color(0xFF757575); // Grey 600 - Medium contrast
  static const Color textTertiary = Color(0xFF9E9E9E); // Grey 500 - Lower contrast
  static const Color textDisabled = Color(0xFFBDBDBD); // Grey 400 - Disabled state
  
  /// Background colors
  static const Color background = Color(0xFFFAFAFA); // Grey 50 - App background
  static const Color surface = Color(0xFFFFFFFF); // White - Card/surface background
  static const Color surfaceVariant = Color(0xFFF5F5F5); // Grey 100 - Alternative surface
  
  /// Border and divider colors
  static const Color border = Color(0xFFE0E0E0); // Grey 300 - Standard borders
  static const Color borderLight = Color(0xFFEEEEEE); // Grey 200 - Light borders
  static const Color divider = Color(0xFFBDBDBD); // Grey 400 - Dividers
  
  // ============================================================================
  // AMOUNT DISPLAY COLORS (Specific to financial data)
  // ============================================================================
  
  /// Advance payment colors (when customer has credit)
  static const Color advancePayment = success;
  static const Color advancePaymentBackground = successLight;
  static const Color advancePaymentBorder = successBorder;
  
  /// Amount due colors (when customer owes money)
  static const Color amountDue = warning;
  static const Color amountDueBackground = warningLight;
  static const Color amountDueBorder = warningBorder;
  
  /// Overdue colors (when payment is late)
  static const Color overdue = error;
  static const Color overdueBackground = errorLight;
  static const Color overdueBorder = errorBorder;
  
  /// Neutral amount colors (zero or informational)
  static const Color neutralAmount = Color(0xFF424242); // Grey 800
  static const Color neutralAmountBackground = Color(0xFFF5F5F5); // Grey 100
  static const Color neutralAmountBorder = Color(0xFF9E9E9E); // Grey 500
  
  // ============================================================================
  // SHADOW COLORS
  // ============================================================================
  
  /// Shadow colors for elevation
  static Color shadowLight = Colors.black.withValues(alpha: 0.08);
  static Color shadowMedium = Colors.black.withValues(alpha: 0.12);
  static Color shadowDark = Colors.black.withValues(alpha: 0.16);
  
  // ============================================================================
  // UTILITY METHODS
  // ============================================================================
  
  /// Get color scheme for interest amounts based on value
  static Map<String, Color> getInterestColorScheme(double amount) {
    if (amount < 0) {
      // Advance payment
      return {
        'primary': advancePayment,
        'background': advancePaymentBackground,
        'border': advancePaymentBorder,
        'surface': successSurface,
      };
    } else if (amount > 0) {
      // Amount due
      return {
        'primary': amountDue,
        'background': amountDueBackground,
        'border': amountDueBorder,
        'surface': warningSurface,
      };
    } else {
      // Neutral/zero
      return {
        'primary': neutralAmount,
        'background': neutralAmountBackground,
        'border': neutralAmountBorder,
        'surface': surfaceVariant,
      };
    }
  }
  
  /// Get status color based on loan status
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'current':
        return success;
      case 'due':
      case 'pending':
        return warning;
      case 'overdue':
      case 'late':
        return error;
      case 'settled':
      case 'completed':
        return info;
      default:
        return neutralAmount;
    }
  }
  
  /// Create a color with opacity while maintaining contrast
  static Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }
  
  /// Get appropriate text color for a given background
  static Color getTextColorForBackground(Color backgroundColor) {
    // Calculate luminance to determine if background is light or dark
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? textPrimary : Colors.white;
  }
  
  /// Create a gradient for cards and surfaces
  static LinearGradient createCardGradient(Color baseColor) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        baseColor.withValues(alpha: 0.05),
        baseColor.withValues(alpha: 0.02),
      ],
    );
  }
}

/// Extension to add convenience methods to Color class
extension ColorExtensions on Color {
  /// Create a lighter version of the color
  Color lighten([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }
  
  /// Create a darker version of the color
  Color darken([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }
  
  /// Check if the color is considered light
  bool get isLight => computeLuminance() > 0.5;
  
  /// Check if the color is considered dark
  bool get isDark => computeLuminance() <= 0.5;
}
