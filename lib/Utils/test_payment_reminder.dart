import 'dart:io';
import 'package:flutter/material.dart';
import 'package:interest_book/Utils/simple_payment_reminder.dart';

/// Test class for payment reminder functionality
class TestPaymentReminder {
  /// Test the payment reminder generation
  static Future<void> testPaymentReminderGeneration() async {
    try {
      print('Testing payment reminder generation...');
      
      // Test basic payment reminder
      final File? basicReminder = await SimplePaymentReminder.generatePaymentReminderImage(
        customerName: 'Mital',
        totalAmount: 16988.0,
        companyName: 'Interest Book',
        customMessage: 'You owe ₹16,988 as on 18 Jun 2025 11:38 PM',
      );
      
      if (basicReminder != null) {
        print('Basic payment reminder generated successfully: ${basicReminder.path}');
        print('File size: ${await basicReminder.length()} bytes');
      } else {
        print('Failed to generate basic payment reminder');
      }
      
      // Test detailed payment reminder
      final File? detailedReminder = await SimplePaymentReminder.generateDetailedPaymentReminder(
        customerName: 'Mital',
        principalAmount: 15000.0,
        interestAmount: 1988.0,
        totalAmount: 16988.0,
        companyName: 'Interest Book',
      );
      
      if (detailedReminder != null) {
        print('Detailed payment reminder generated successfully: ${detailedReminder.path}');
        print('File size: ${await detailedReminder.length()} bytes');
      } else {
        print('Failed to generate detailed payment reminder');
      }
      
    } catch (e) {
      print('Error testing payment reminder generation: $e');
    }
  }
}

/// Widget to test payment reminder in UI
class PaymentReminderTestWidget extends StatefulWidget {
  const PaymentReminderTestWidget({Key? key}) : super(key: key);

  @override
  State<PaymentReminderTestWidget> createState() => _PaymentReminderTestWidgetState();
}

class _PaymentReminderTestWidgetState extends State<PaymentReminderTestWidget> {
  File? _generatedImage;
  bool _isGenerating = false;

  Future<void> _generateTestImage() async {
    setState(() {
      _isGenerating = true;
    });

    try {
      final File? imageFile = await SimplePaymentReminder.generateDetailedPaymentReminder(
        customerName: 'Mital',
        principalAmount: 15000.0,
        interestAmount: 1988.0,
        totalAmount: 16988.0,
        companyName: 'Interest Book',
      );

      setState(() {
        _generatedImage = imageFile;
        _isGenerating = false;
      });

      if (imageFile != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment reminder generated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to generate payment reminder'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isGenerating = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Reminder Test'),
        backgroundColor: Colors.blueGrey[700],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _isGenerating ? null : _generateTestImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: _isGenerating
                  ? const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text('Generating...'),
                      ],
                    )
                  : const Text('Generate Payment Reminder'),
            ),
            
            const SizedBox(height: 20),
            
            if (_generatedImage != null)
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      'Generated Payment Reminder:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            _generatedImage!,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'File: ${_generatedImage!.path}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              )
            else if (!_isGenerating)
              const Expanded(
                child: Center(
                  child: Text(
                    'Click the button above to generate a payment reminder',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
