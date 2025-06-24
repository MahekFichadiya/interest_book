import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:interest_book/Utils/amount_formatter.dart';

class ReliablePaymentReminder {
  /// Generate a simple payment reminder image using basic drawing
  static Future<File?> generateBasicPaymentReminder({
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
        ..color = const Color(0xFFBDBDBD)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawRRect(cardRect, borderPaint);
      
      // Draw simple text elements using basic shapes and colors
      _drawSimpleText(canvas, companyName, 50, 28, const Color(0xFF1976D2), width);
      _drawSimpleText(canvas, 'PAYMENT REMINDER', 160, 16, const Color(0xFF757575), width);
      
      final String formattedAmount = AmountFormatter.formatCurrency(totalAmount);
      _drawSimpleText(canvas, formattedAmount, 220, 42, const Color(0xFFD32F2F), width);
      
      final String formattedDate = DateFormat('dd MMM yyyy hh:mm a').format(DateTime.now());
      final String message = customMessage ?? 'You owe $formattedAmount as on $formattedDate';
      _drawSimpleText(canvas, message, 300, 12, const Color(0xFF757575), width, maxWidth: width - 80);
      
      // Draw customer name button
      final RRect nameButtonRect = RRect.fromRectAndRadius(
        const Rect.fromLTWH(120, 350, 160, 40),
        const Radius.circular(8),
      );
      final Paint nameButtonPaint = Paint()..color = const Color(0xFF9E9E9E);
      canvas.drawRRect(nameButtonRect, nameButtonPaint);
      
      _drawSimpleText(canvas, customerName, 360, 16, Colors.white, width);
      
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
      
      _drawSimpleText(canvas, 'Verified by $companyName', 490, 16, const Color(0xFF1976D2), width);
      _drawSimpleText(canvas, 'Download from Google Play Store', 520, 12, const Color(0xFF757575), width);
      
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
      print('Error generating basic payment reminder: $e');
      return null;
    }
  }

  /// Helper method to draw simple text without TextPainter complexity
  static void _drawSimpleText(
    Canvas canvas,
    String text,
    double y,
    double fontSize,
    Color color,
    double canvasWidth, {
    double? maxWidth,
  }) {
    try {
      final TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            fontSize: fontSize,
            color: color,
            fontWeight: fontSize > 20 ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        textDirection: ui.TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      
      textPainter.layout(
        minWidth: 0,
        maxWidth: maxWidth ?? canvasWidth - 40,
      );
      
      final double x = (canvasWidth - textPainter.width) / 2;
      textPainter.paint(canvas, Offset(x, y));
    } catch (e) {
      print('Error drawing text "$text": $e');
    }
  }

  /// Generate a detailed payment reminder with loan breakdown
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
        ..color = const Color(0xFFBDBDBD)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawRRect(cardRect, borderPaint);
      
      // Draw content
      _drawSimpleText(canvas, companyName, 50, 28, const Color(0xFF1976D2), width);
      _drawSimpleText(canvas, 'PAYMENT REMINDER', 160, 16, const Color(0xFF757575), width);
      
      final String formattedTotal = AmountFormatter.formatCurrency(totalAmount);
      _drawSimpleText(canvas, formattedTotal, 200, 42, const Color(0xFFD32F2F), width);
      
      // Draw breakdown
      double yPos = 280;
      
      final String principalText = 'Principal: ${AmountFormatter.formatCurrency(principalAmount)}';
      _drawSimpleText(canvas, principalText, yPos, 14, const Color(0xFF424242), width);
      
      yPos += 25;
      
      final String interestText = 'Interest: ${AmountFormatter.formatCurrency(interestAmount)}';
      _drawSimpleText(canvas, interestText, yPos, 14, const Color(0xFF424242), width);
      
      yPos += 40;
      
      // Customer name button
      final RRect nameButtonRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(120, yPos, 160, 40),
        const Radius.circular(8),
      );
      final Paint nameButtonPaint = Paint()..color = const Color(0xFF9E9E9E);
      canvas.drawRRect(nameButtonRect, nameButtonPaint);
      
      _drawSimpleText(canvas, customerName, yPos + 10, 16, Colors.white, width);
      
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
      
      _drawSimpleText(canvas, 'Verified by $companyName', yPos, 16, const Color(0xFF1976D2), width);
      
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

  /// Fallback method that creates a simple text-based image
  static Future<File?> generateFallbackReminder({
    required String customerName,
    required double totalAmount,
    required String companyName,
  }) async {
    try {
      const double width = 400;
      const double height = 600;
      
      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(recorder);
      
      // Simple background
      final Paint paint = Paint()..color = Colors.white;
      canvas.drawRect(const Rect.fromLTWH(0, 0, width, height), paint);
      
      // Border
      final Paint borderPaint = Paint()
        ..color = Colors.grey
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawRect(const Rect.fromLTWH(10, 10, width - 20, height - 20), borderPaint);
      
      // Simple text content
      final String content = '''
$companyName

PAYMENT REMINDER

${AmountFormatter.formatCurrency(totalAmount)}

Dear $customerName,

Please make your payment as soon as possible.

Thank you!

Verified by $companyName
''';
      
      _drawSimpleText(canvas, content, 100, 16, Colors.black, width, maxWidth: width - 40);
      
      final ui.Picture picture = recorder.endRecording();
      final ui.Image image = await picture.toImage(width.toInt(), height.toInt());
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData == null) return null;
      
      final Directory tempDir = await getTemporaryDirectory();
      final String fileName = 'fallback_reminder_${DateTime.now().millisecondsSinceEpoch}.png';
      final File file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(byteData.buffer.asUint8List());
      
      return file;
    } catch (e) {
      print('Error generating fallback reminder: $e');
      return null;
    }
  }
}
