import 'package:flutter/material.dart';

class CustomerDeletionConfirmationDialog extends StatelessWidget {
  final String customerName;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const CustomerDeletionConfirmationDialog({
    Key? key,
    required this.customerName,
    required this.onConfirm,
    required this.onCancel,
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
              'Delete Customer?',
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
            'This is the last loan for customer:',
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
            'Do you want to delete this customer as well?',
            style: TextStyle(
              fontSize: 16,
              color: Colors.blueGrey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Note: This action cannot be undone.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.red[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'Keep Customer',
            style: TextStyle(
              fontSize: 16,
              color: Colors.blueGrey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(width: 8),
        ElevatedButton(
          onPressed: onConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[600],
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 2,
          ),
          child: Text(
            'Delete Customer',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
      actionsPadding: EdgeInsets.fromLTRB(16, 0, 16, 16),
    );
  }

  /// Static method to show the confirmation dialog
  static Future<bool?> show({
    required BuildContext context,
    required String customerName,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => CustomerDeletionConfirmationDialog(
        customerName: customerName,
        onConfirm: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
      ),
    );
  }
}
