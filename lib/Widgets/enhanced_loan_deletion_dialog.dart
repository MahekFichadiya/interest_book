import 'package:flutter/material.dart';

enum LoanDeletionChoice {
  cancel,
  deleteLoanOnly,
  deleteBoth,
}

class EnhancedLoanDeletionDialog extends StatelessWidget {
  final String customerName;
  final Function(LoanDeletionChoice) onChoice;

  const EnhancedLoanDeletionDialog({
    Key? key,
    required this.customerName,
    required this.onChoice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Colors.orange,
            size: 28,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Last Loan for Customer',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey[800],
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This is the last loan for:',
            style: TextStyle(
              fontSize: 16,
              color: Colors.blueGrey[600],
            ),
          ),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blueGrey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blueGrey[200]!),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.person,
                  color: Colors.blueGrey[600],
                  size: 20,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    customerName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.blueGrey[800],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Text(
            'What would you like to do?',
            style: TextStyle(
              fontSize: 16,
              color: Colors.blueGrey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 16),
          
          // Option 1: Delete loan only
          _buildOptionCard(
            icon: Icons.delete_outline,
            iconColor: Colors.blue[600]!,
            title: 'Delete Loan Only',
            subtitle: 'Keep customer (even with no loans)',
            onTap: () => onChoice(LoanDeletionChoice.deleteLoanOnly),
          ),
          
          SizedBox(height: 12),
          
          // Option 2: Delete both
          _buildOptionCard(
            icon: Icons.delete_forever,
            iconColor: Colors.red[600]!,
            title: 'Delete Loan & Customer',
            subtitle: 'Remove both loan and customer',
            onTap: () => onChoice(LoanDeletionChoice.deleteBoth),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => onChoice(LoanDeletionChoice.cancel),
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'Cancel',
            style: TextStyle(
              fontSize: 16,
              color: Colors.blueGrey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
      actionsPadding: EdgeInsets.fromLTRB(16, 0, 16, 16),
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blueGrey[200]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.blueGrey[800],
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blueGrey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.blueGrey[400],
            ),
          ],
        ),
      ),
    );
  }

  /// Static method to show the enhanced confirmation dialog
  static Future<LoanDeletionChoice?> show({
    required BuildContext context,
    required String customerName,
  }) {
    return showDialog<LoanDeletionChoice>(
      context: context,
      barrierDismissible: false,
      builder: (context) => EnhancedLoanDeletionDialog(
        customerName: customerName,
        onChoice: (choice) => Navigator.of(context).pop(choice),
      ),
    );
  }
}
