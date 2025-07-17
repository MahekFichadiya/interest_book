import 'package:flutter/material.dart';
import '../Api/UrlConstant.dart';

class FullScreenImageViewer extends StatelessWidget {
  final String imagePath;
  final String customerName;

  const FullScreenImageViewer({
    Key? key,
    required this.imagePath,
    required this.customerName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[300],
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          customerName,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.network(
            "${UrlConstant.showImage}/$imagePath",
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const CircularProgressIndicator(color: Colors.white);
            },
            errorBuilder: (context, error, stackTrace) => const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.white, size: 64),
                SizedBox(height: 16),
                Text(
                  'Failed to load image',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
