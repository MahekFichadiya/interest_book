import 'package:flutter/material.dart';
import 'package:interest_book/Loan/ApplyLoan/YouGaveLoan.dart';
import 'package:interest_book/Loan/ApplyLoan/YouGotLoan.dart';

class LoanToggleButton extends StatefulWidget {
  final String? customerId;
  const LoanToggleButton({super.key, required this.customerId});

  @override
  State<LoanToggleButton> createState() => _LoanToggleButtonState();
}

class _LoanToggleButtonState extends State<LoanToggleButton>
    with TickerProviderStateMixin {
  bool isYouGive = true;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleLoanType(bool isGive) {
    if (isYouGive != isGive) {
      setState(() {
        isYouGive = isGive;
      });
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Card-style selection similar to payment mode
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Loan Type',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.blueGrey[700],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildLoanTypeCard(
                    label: "You Gave",
                    subtitle: "Money Lent",
                    icon: Icons.trending_up_rounded,
                    isSelected: isYouGive,
                    color: Colors.red.shade600,
                    onTap: () => _toggleLoanType(true),
                  ),
                  const SizedBox(width: 12),
                  _buildLoanTypeCard(
                    label: "You Got",
                    subtitle: "Money Borrowed",
                    icon: Icons.trending_down_rounded,
                    isSelected: !isYouGive,
                    color: Colors.green.shade600,
                    onTap: () => _toggleLoanType(false),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Content area with animation
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.3, 0),
              end: Offset.zero,
            ).animate(_slideAnimation),
            child: FadeTransition(
              opacity: _slideAnimation,
              child: isYouGive
                  ? YouGaveLone(customerId: widget.customerId)
                  : YouGotLone(customerId: widget.customerId),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoanTypeCard({
    required String label,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.1) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : Colors.blueGrey.shade200,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? color.withValues(alpha: 0.2)
                    : Colors.blueGrey.withValues(alpha: 0.1),
                blurRadius: isSelected ? 8 : 4,
                offset: const Offset(0, 2),
                spreadRadius: isSelected ? 1 : 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon with background
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? color : color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isSelected ? Colors.white : color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              // Main label
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? color : Colors.blueGrey[700],
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              // Subtitle
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.blueGrey[500],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
