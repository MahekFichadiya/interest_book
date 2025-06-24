import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:interest_book/Utils/amount_formatter.dart';

class SimplePaymentReminder {
  /// Generate a simple payment reminder image using Canvas
  static Future<File?> generatePaymentReminderImage({
    required String customerName,
    required double totalAmount,
    required String companyName,
    String? customMessage,
  }) async {
    try {
      // Image dimensions
      const double width = 400;
      const double height = 600;
      
      // Create a picture recorder
      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(recorder);
      
      // Background
      final Paint backgroundPaint = Paint()..color = const Color(0xFFF5F5F5);
      canvas.drawRect(const Rect.fromLTWH(0, 0, width, height), backgroundPaint);
      
      // Main card background
      final Paint cardPaint = Paint()..color = Colors.white;
      final RRect cardRect = RRect.fromRectAndRadius(
        const Rect.fromLTWH(30, 120, width - 60, height - 240),
        const Radius.circular(12),
      );
      canvas.drawRRect(cardRect, cardPaint);
      
      // Card border
      final Paint borderPaint = Paint()
        ..color = Colors.grey[300]!
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawRRect(cardRect, borderPaint);
      
      // Text painters
      final TextStyle companyStyle = TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.blue[700],
      );
      
      final TextStyle headerStyle = TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.grey[600],
      );
      
      final TextStyle amountStyle = const TextStyle(
        fontSize: 42,
        fontWeight: FontWeight.bold,
        color: Colors.red,
      );
      
      final TextStyle messageStyle = TextStyle(
        fontSize: 12,
        color: Colors.grey[600],
      );
      
      final TextStyle nameStyle = const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      );
      
      final TextStyle verificationStyle = TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.blue[700],
      );
      
      final TextStyle downloadStyle = TextStyle(
        fontSize: 12,
        color: Colors.grey[600],
      );
      
      // Draw company name
      final TextPainter companyPainter = TextPainter(
        text: TextSpan(text: companyName, style: companyStyle),
        textDirection: ui.TextDirection.ltr,
      );
      companyPainter.layout();
      companyPainter.paint(canvas, Offset((width - companyPainter.width) / 2, 50));

      // Draw "PAYMENT REMINDER" header
      final TextPainter headerPainter = TextPainter(
        text: const TextSpan(text: 'PAYMENT REMINDER', style: TextStyle(fontSize: 16, color: Colors.grey, letterSpacing: 1.2)),
        textDirection: ui.TextDirection.ltr,
      );
      headerPainter.layout();
      headerPainter.paint(canvas, Offset((width - headerPainter.width) / 2, 160));

      // Draw amount
      final String formattedAmount = AmountFormatter.formatCurrency(totalAmount);
      final TextPainter amountPainter = TextPainter(
        text: TextSpan(text: formattedAmount, style: amountStyle),
        textDirection: ui.TextDirection.ltr,
      );
      amountPainter.layout();
      amountPainter.paint(canvas, Offset((width - amountPainter.width) / 2, 220));

      // Draw message
      final String formattedDate = DateFormat('dd MMM yyyy hh:mm a').format(DateTime.now());
      final String message = customMessage ?? 'You owe $formattedAmount as on $formattedDate';
      final TextPainter messagePainter = TextPainter(
        text: TextSpan(text: message, style: messageStyle),
        textDirection: ui.TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      messagePainter.layout(minWidth: 0, maxWidth: width - 80);
      messagePainter.paint(canvas, Offset((width - messagePainter.width) / 2, 300));

      // Draw customer name button
      final RRect nameButtonRect = RRect.fromRectAndRadius(
        const Rect.fromLTWH(120, 350, 160, 40),
        const Radius.circular(8),
      );
      final Paint nameButtonPaint = Paint()..color = Colors.grey[500]!;
      canvas.drawRRect(nameButtonRect, nameButtonPaint);

      final TextPainter namePainter = TextPainter(
        text: TextSpan(text: customerName, style: nameStyle),
        textDirection: ui.TextDirection.ltr,
      );
      namePainter.layout();
      namePainter.paint(canvas, Offset((width - namePainter.width) / 2, 360));
      
      // Draw check icon (simplified as a circle)
      final Paint checkPaint = Paint()..color = Colors.black;
      canvas.drawCircle(const Offset(width / 2, 450), 20, checkPaint);
      
      // Draw checkmark
      final Paint checkmarkPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      final Path checkmarkPath = Path();
      checkmarkPath.moveTo(width / 2 - 8, 450);
      checkmarkPath.lineTo(width / 2 - 2, 456);
      checkmarkPath.lineTo(width / 2 + 8, 444);
      canvas.drawPath(checkmarkPath, checkmarkPaint);
      
      // Draw verification text
      final TextPainter verificationPainter = TextPainter(
        text: TextSpan(text: 'Verified by $companyName', style: verificationStyle),
        textDirection: ui.TextDirection.ltr,
      );
      verificationPainter.layout();
      verificationPainter.paint(canvas, Offset((width - verificationPainter.width) / 2, 490));

      // Draw download text
      final TextPainter downloadPainter = TextPainter(
        text: const TextSpan(text: 'Download from Google Play Store', style: TextStyle(fontSize: 12, color: Colors.grey)),
        textDirection: ui.TextDirection.ltr,
      );
      downloadPainter.layout();
      downloadPainter.paint(canvas, Offset((width - downloadPainter.width) / 2, 520));
      
      // Convert to image
      final ui.Picture picture = recorder.endRecording();
      final ui.Image image = await picture.toImage(width.toInt(), height.toInt());
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData == null) return null;
      
      // Save to file
      final Directory tempDir = await getTemporaryDirectory();
      final String fileName = 'payment_reminder_${DateTime.now().millisecondsSinceEpoch}.png';
      final File file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(byteData.buffer.asUint8List());
      
      return file;
    } catch (e) {
      print('Error generating payment reminder image: $e');
      return null;
    }
  }

  /// Generate a more detailed payment reminder with loan breakdown
  static Future<File?> generateDetailedPaymentReminder({
    required String customerName,
    required double principalAmount,
    required double interestAmount,
    required double totalAmount,
    required String companyName,
  }) async {
    try {
      // Image dimensions
      const double width = 400;
      const double height = 700;
      
      // Create a picture recorder
      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(recorder);
      
      // Background
      final Paint backgroundPaint = Paint()..color = const Color(0xFFF5F5F5);
      canvas.drawRect(const Rect.fromLTWH(0, 0, width, height), backgroundPaint);
      
      // Main card background
      final Paint cardPaint = Paint()..color = Colors.white;
      final RRect cardRect = RRect.fromRectAndRadius(
        const Rect.fromLTWH(30, 120, width - 60, height - 240),
        const Radius.circular(12),
      );
      canvas.drawRRect(cardRect, cardPaint);
      
      // Card border
      final Paint borderPaint = Paint()
        ..color = Colors.grey[300]!
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawRRect(cardRect, borderPaint);
      
      // Draw company name
      final TextPainter companyPainter = TextPainter(
        text: TextSpan(
          text: companyName,
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue[700]),
        ),
        textDirection: ui.TextDirection.ltr,
      );
      companyPainter.layout();
      companyPainter.paint(canvas, Offset((width - companyPainter.width) / 2, 50));

      // Draw header
      final TextPainter headerPainter = TextPainter(
        text: const TextSpan(
          text: 'PAYMENT REMINDER',
          style: TextStyle(fontSize: 16, color: Colors.grey, letterSpacing: 1.2),
        ),
        textDirection: ui.TextDirection.ltr,
      );
      headerPainter.layout();
      headerPainter.paint(canvas, Offset((width - headerPainter.width) / 2, 160));

      // Draw total amount
      final String formattedTotal = AmountFormatter.formatCurrency(totalAmount);
      final TextPainter totalPainter = TextPainter(
        text: TextSpan(
          text: formattedTotal,
          style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Colors.red),
        ),
        textDirection: ui.TextDirection.ltr,
      );
      totalPainter.layout();
      totalPainter.paint(canvas, Offset((width - totalPainter.width) / 2, 200));
      
      // Draw breakdown
      double yPos = 280;
      
      // Principal amount
      final String principalText = 'Principal: ${AmountFormatter.formatCurrency(principalAmount)}';
      final TextPainter principalPainter = TextPainter(
        text: TextSpan(
          text: principalText,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
        textDirection: ui.TextDirection.ltr,
      );
      principalPainter.layout();
      principalPainter.paint(canvas, Offset((width - principalPainter.width) / 2, yPos));

      yPos += 25;

      // Interest amount
      final String interestText = 'Interest: ${AmountFormatter.formatCurrency(interestAmount)}';
      final TextPainter interestPainter = TextPainter(
        text: TextSpan(
          text: interestText,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
        textDirection: ui.TextDirection.ltr,
      );
      interestPainter.layout();
      interestPainter.paint(canvas, Offset((width - interestPainter.width) / 2, yPos));
      
      yPos += 40;
      
      // Customer name button
      final RRect nameButtonRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(120, yPos, 160, 40),
        const Radius.circular(8),
      );
      final Paint nameButtonPaint = Paint()..color = Colors.grey[500]!;
      canvas.drawRRect(nameButtonRect, nameButtonPaint);
      
      final TextPainter namePainter = TextPainter(
        text: TextSpan(
          text: customerName,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        textDirection: ui.TextDirection.ltr,
      );
      namePainter.layout();
      namePainter.paint(canvas, Offset((width - namePainter.width) / 2, yPos + 10));
      
      // Draw check icon and verification
      yPos += 80;
      
      final Paint checkPaint = Paint()..color = Colors.black;
      canvas.drawCircle(Offset(width / 2, yPos), 20, checkPaint);
      
      // Draw checkmark
      final Paint checkmarkPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      final Path checkmarkPath = Path();
      checkmarkPath.moveTo(width / 2 - 8, yPos);
      checkmarkPath.lineTo(width / 2 - 2, yPos + 6);
      checkmarkPath.lineTo(width / 2 + 8, yPos - 6);
      canvas.drawPath(checkmarkPath, checkmarkPaint);
      
      yPos += 40;
      
      // Verification text
      final TextPainter verificationPainter = TextPainter(
        text: TextSpan(
          text: 'Verified by $companyName',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.blue[700]),
        ),
        textDirection: ui.TextDirection.ltr,
      );
      verificationPainter.layout();
      verificationPainter.paint(canvas, Offset((width - verificationPainter.width) / 2, yPos));
      
      // Convert to image and save
      final ui.Picture picture = recorder.endRecording();
      final ui.Image image = await picture.toImage(width.toInt(), height.toInt());
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData == null) return null;
      
      final Directory tempDir = await getTemporaryDirectory();
      final String fileName = 'detailed_payment_reminder_${DateTime.now().millisecondsSinceEpoch}.png';
      final File file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(byteData.buffer.asUint8List());
      
      return file;
    } catch (e) {
      print('Error generating detailed payment reminder: $e');
      return null;
    }
  }
}
