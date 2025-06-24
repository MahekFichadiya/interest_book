import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:interest_book/Utils/amount_formatter.dart';

class PaymentReminderGenerator {
  /// Generate a payment reminder image similar to the reference design
  static Future<File?> generatePaymentReminderImage({
    required String customerName,
    required double totalAmount,
    required String companyName,
    String? customMessage,
  }) async {
    try {
      // Create a GlobalKey for the widget
      final GlobalKey repaintBoundaryKey = GlobalKey();
      
      // Create the widget
      final widget = RepaintBoundary(
        key: repaintBoundaryKey,
        child: PaymentReminderWidget(
          customerName: customerName,
          totalAmount: totalAmount,
          companyName: companyName,
          customMessage: customMessage,
        ),
      );

      // Create a temporary widget to render
      final RenderRepaintBoundary boundary = repaintBoundaryKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      
      // Capture the widget as image
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Save to temporary directory
      final Directory tempDir = await getTemporaryDirectory();
      final String fileName = 'payment_reminder_${DateTime.now().millisecondsSinceEpoch}.png';
      final File file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(pngBytes);

      return file;
    } catch (e) {
      print('Error generating payment reminder image: $e');
      return null;
    }
  }

  /// Generate payment reminder image using a different approach with WidgetToImage
  static Future<File?> generatePaymentReminderImageV2({
    required String customerName,
    required double totalAmount,
    required String companyName,
    String? customMessage,
  }) async {
    try {
      // Create the widget
      final widget = PaymentReminderWidget(
        customerName: customerName,
        totalAmount: totalAmount,
        companyName: companyName,
        customMessage: customMessage,
      );

      // Convert widget to image bytes
      final Uint8List? imageBytes = await _widgetToImage(widget);
      if (imageBytes == null) return null;

      // Save to temporary directory
      final Directory tempDir = await getTemporaryDirectory();
      final String fileName = 'payment_reminder_${DateTime.now().millisecondsSinceEpoch}.png';
      final File file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(imageBytes);

      return file;
    } catch (e) {
      print('Error generating payment reminder image V2: $e');
      return null;
    }
  }

  /// Convert widget to image bytes using modern Flutter approach
  static Future<Uint8List?> _widgetToImage(Widget widget) async {
    try {
      // Create a RepaintBoundary to capture the widget
      final repaintBoundary = RenderRepaintBoundary();

      // Create pipeline and build owners
      final pipelineOwner = PipelineOwner();
      final buildOwner = BuildOwner(focusManager: FocusManager());

      // Set up the render tree
      pipelineOwner.rootNode = repaintBoundary;

      // Create the widget tree with proper context
      final rootElement = RenderObjectToWidgetAdapter<RenderBox>(
        container: repaintBoundary,
        child: Directionality(
          textDirection: ui.TextDirection.ltr,
          child: MediaQuery(
            data: const MediaQueryData(
              size: Size(400, 600),
              devicePixelRatio: 3.0,
              textScaler: TextScaler.linear(1.0),
            ),
            child: Material(
              color: Colors.transparent,
              child: widget,
            ),
          ),
        ),
      ).attachToRenderTree(buildOwner);

      // Build and layout the widget tree
      buildOwner.buildScope(rootElement);
      buildOwner.finalizeTree();

      // Set the size for the repaint boundary
      repaintBoundary.layout(const BoxConstraints(
        minWidth: 400,
        maxWidth: 400,
        minHeight: 600,
        maxHeight: 600,
      ));

      // Perform the rendering pipeline
      pipelineOwner.flushLayout();
      pipelineOwner.flushCompositingBits();
      pipelineOwner.flushPaint();

      // Convert to image
      final ui.Image image = await repaintBoundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      // Clean up
      rootElement.unmount();

      return byteData?.buffer.asUint8List();
    } catch (e) {
      print('Error converting widget to image: $e');
      return null;
    }
  }
}

/// Widget that represents the payment reminder design
class PaymentReminderWidget extends StatelessWidget {
  final String customerName;
  final double totalAmount;
  final String companyName;
  final String? customMessage;

  const PaymentReminderWidget({
    super.key,
    required this.customerName,
    required this.totalAmount,
    required this.companyName,
    this.customMessage,
  });

  @override
  Widget build(BuildContext context) {
    final String formattedDate = DateFormat('dd MMM yyyy hh:mm a').format(DateTime.now());
    final String formattedAmount = AmountFormatter.formatCurrency(totalAmount);

    return Container(
      width: 400,
      height: 600,
      color: Colors.grey[100],
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            // Company Name Header
            Text(
              companyName,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            // Main Content Card
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Payment Reminder Header
                  Text(
                    'PAYMENT REMINDER',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                      letterSpacing: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 20),

                  // Amount
                  Text(
                    formattedAmount,
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 20),

                  // Message
                  Text(
                    customMessage ?? 'You owe $formattedAmount as on $formattedDate',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 20),

                  // Customer Name Button
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      customerName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Verification Section
            const Icon(
              Icons.check_circle,
              size: 40,
              color: Colors.black,
            ),
            
            const SizedBox(height: 15),
            
            Text(
              'Verified by $companyName',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.blue,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 10),
            
            Text(
              'Download from Google Play Store',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
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
