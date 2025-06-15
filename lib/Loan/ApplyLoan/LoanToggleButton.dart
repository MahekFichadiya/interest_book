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
        // Enhanced toggle buttons
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.blueGrey.withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                _buildToggleButton(
                  label: "You Gave ₹",
                  icon: Icons.trending_up,
                  isSelected: isYouGive,
                  isLeft: true,
                  onTap: () => _toggleLoanType(true),
                ),
                _buildToggleButton(
                  label: "You Got ₹",
                  icon: Icons.trending_down,
                  isSelected: !isYouGive,
                  isLeft: false,
                  onTap: () => _toggleLoanType(false),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
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

  Widget _buildToggleButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required bool isLeft,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.blueGrey.shade500,
                          Colors.blueGrey.shade600,
                        ],
                      )
                    : null,
                color: isSelected ? null : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? Colors.blueGrey.shade600
                      : Colors.grey.shade300,
                  width: 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.blueGrey.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: isSelected ? Colors.white : Colors.blueGrey.shade600,
                    size: 24,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.blueGrey.shade700,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
