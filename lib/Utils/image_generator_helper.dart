import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class ImageGeneratorHelper {
  /// Convert a widget to an image file
  static Future<File?> widgetToImageFile(
    Widget widget, {
    Size size = const Size(400, 600),
    double pixelRatio = 3.0,
    String? fileName,
  }) async {
    try {
      // Create a unique filename if not provided
      fileName ??= 'generated_image_${DateTime.now().millisecondsSinceEpoch}.png';
      
      // Create the image bytes
      final Uint8List? imageBytes = await widgetToImageBytes(
        widget,
        size: size,
        pixelRatio: pixelRatio,
      );
      
      if (imageBytes == null) return null;
      
      // Save to temporary directory
      final Directory tempDir = await getTemporaryDirectory();
      final File file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(imageBytes);
      
      return file;
    } catch (e) {
      print('Error converting widget to image file: $e');
      return null;
    }
  }

  /// Convert a widget to image bytes using modern Flutter approach
  static Future<Uint8List?> widgetToImageBytes(
    Widget widget, {
    Size size = const Size(400, 600),
    double pixelRatio = 3.0,
  }) async {
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
            data: MediaQueryData(
              size: size,
              devicePixelRatio: pixelRatio,
              textScaler: TextScaler.linear(1.0),
            ),
            child: Material(
              color: Colors.transparent,
              child: SizedBox(
                width: size.width,
                height: size.height,
                child: widget,
              ),
            ),
          ),
        ),
      ).attachToRenderTree(buildOwner);

      // Build and layout the widget tree
      buildOwner.buildScope(rootElement);
      buildOwner.finalizeTree();

      // Set the size for the repaint boundary
      repaintBoundary.layout(BoxConstraints(
        minWidth: size.width,
        maxWidth: size.width,
        minHeight: size.height,
        maxHeight: size.height,
      ));

      // Perform the rendering pipeline
      pipelineOwner.flushLayout();
      pipelineOwner.flushCompositingBits();
      pipelineOwner.flushPaint();

      // Convert to image
      final ui.Image image = await repaintBoundary.toImage(pixelRatio: pixelRatio);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      // Clean up
      rootElement.unmount();

      return byteData?.buffer.asUint8List();
    } catch (e) {
      print('Error converting widget to image bytes: $e');
      return null;
    }
  }

  /// Alternative method using a simpler approach
  static Future<File?> captureWidgetAsImage(
    Widget widget, {
    Size size = const Size(400, 600),
    String? fileName,
  }) async {
    try {
      fileName ??= 'captured_widget_${DateTime.now().millisecondsSinceEpoch}.png';
      
      // Note: This is a simplified approach for demonstration
      // In a real implementation, you'd need to render the widget properly

      // This is a simplified approach - in a real app, you'd need to
      // render this widget in a temporary context
      
      // For now, let's create a basic image file
      final Directory tempDir = await getTemporaryDirectory();
      final File file = File('${tempDir.path}/$fileName');
      
      // Create a simple placeholder image (you can replace this with actual rendering)
      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(recorder);
      final Paint paint = Paint()..color = Colors.white;
      
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
      
      final ui.Picture picture = recorder.endRecording();
      final ui.Image image = await picture.toImage(size.width.toInt(), size.height.toInt());
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData != null) {
        await file.writeAsBytes(byteData.buffer.asUint8List());
        return file;
      }
      
      return null;
    } catch (e) {
      print('Error capturing widget as image: $e');
      return null;
    }
  }

  /// Clean up temporary image files
  static Future<void> cleanupTempImages() async {
    try {
      final Directory tempDir = await getTemporaryDirectory();
      final List<FileSystemEntity> files = tempDir.listSync();
      
      for (final file in files) {
        if (file is File && 
            (file.path.contains('generated_image_') || 
             file.path.contains('captured_widget_') ||
             file.path.contains('payment_reminder_'))) {
          await file.delete();
        }
      }
    } catch (e) {
      print('Error cleaning up temp images: $e');
    }
  }
}
