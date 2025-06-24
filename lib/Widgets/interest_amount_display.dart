import 'package:flutter/material.dart';
import 'package:interest_book/Utils/amount_formatter.dart';

/// Widget for displaying interest amounts with proper styling for advance payments
class InterestAmountDisplay extends StatelessWidget {
  final dynamic totalInterest;
  final double fontSize;
  final FontWeight fontWeight;
  final bool showIcon;
  final bool showLabel;

  const InterestAmountDisplay({
    Key? key,
    required this.totalInterest,
    this.fontSize = 16,
    this.fontWeight = FontWeight.w500,
    this.showIcon = false,
    this.showLabel = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final interestData = AmountFormatter.formatInterestWithAdvancePayment(totalInterest);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showIcon) ...[
          Icon(
            interestData['icon'] as IconData,
            color: interestData['color'] as Color,
            size: fontSize,
          ),
          const SizedBox(width: 4),
        ],
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              interestData['amount'] as String,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: fontWeight,
                color: interestData['color'] as Color,
              ),
            ),
            if (showLabel && interestData['isAdvancePayment'] == true) ...[
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: interestData['lightColor'] as Color,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: interestData['borderColor'] as Color,
                    width: 1,
                  ),
                ),
                child: Text(
                  'Advance Payment',
                  style: TextStyle(
                    fontSize: fontSize * 0.6,
                    color: interestData['color'] as Color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

/// Widget for displaying interest amount in detail rows
class InterestDetailRow extends StatelessWidget {
  final String label;
  final dynamic totalInterest;

  const InterestDetailRow({
    Key? key,
    required this.label,
    required this.totalInterest,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final interestData = AmountFormatter.formatInterestWithAdvancePayment(totalInterest);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (interestData['isAdvancePayment'] == true) ...[
                Icon(
                  Icons.trending_up,
                  color: interestData['color'] as Color,
                  size: 16,
                ),
                const SizedBox(width: 4),
              ],
              Text(
                interestData['amount'] as String,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: interestData['color'] as Color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Widget for displaying interest amount in cards (like loan dashboard)
class InterestCardDisplay extends StatelessWidget {
  final dynamic totalInterest;
  final String title;
  final double cardWidth;

  const InterestCardDisplay({
    Key? key,
    required this.totalInterest,
    this.title = 'Interest',
    this.cardWidth = 120,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final interestData = AmountFormatter.formatInterestWithAdvancePayment(totalInterest);
    
    return Container(
      width: cardWidth,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: interestData['borderColor'] as Color,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (interestData['color'] as Color).withValues(alpha: 0.15),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            spreadRadius: 0,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                interestData['icon'] as IconData,
                color: interestData['color'] as Color,
                size: 16,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: (interestData['color'] as Color).withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            interestData['amount'] as String,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: interestData['color'] as Color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (interestData['isAdvancePayment'] == true) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: interestData['lightColor'] as Color,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: interestData['borderColor'] as Color,
                  width: 0.5,
                ),
              ),
              child: Text(
                'Advance',
                style: TextStyle(
                  fontSize: 9,
                  color: interestData['color'] as Color,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Helper function to get interest display data
class InterestDisplayHelper {
  /// Check if the amount represents an advance payment
  static bool isAdvancePayment(dynamic totalInterest) {
    final data = AmountFormatter.formatInterestWithAdvancePayment(totalInterest);
    return data['isAdvancePayment'] == true;
  }

  /// Get the display color for interest amount
  static Color getInterestColor(dynamic totalInterest) {
    final data = AmountFormatter.formatInterestWithAdvancePayment(totalInterest);
    return data['color'] as Color;
  }

  /// Get formatted amount string with proper sign
  static String getFormattedAmount(dynamic totalInterest) {
    final data = AmountFormatter.formatInterestWithAdvancePayment(totalInterest);
    return data['amount'] as String;
  }

  /// Get appropriate icon for interest status
  static IconData getInterestIcon(dynamic totalInterest) {
    final data = AmountFormatter.formatInterestWithAdvancePayment(totalInterest);
    return data['icon'] as IconData;
  }
}
