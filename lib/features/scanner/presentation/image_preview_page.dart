import 'package:flutter/material.dart';
import 'dart:io';

class ImagePreviewPage extends StatelessWidget {
  final String imagePath;
  final int imageIndex;
  final int totalImages;
  final Function(String)? onImageDeleted;

  const ImagePreviewPage({
    super.key,
    required this.imagePath,
    required this.imageIndex,
    required this.totalImages,
    this.onImageDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: Colors.black,
      body: _buildBody(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text('Image $imageIndex of $totalImages'),
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
    );
  }

  Widget _buildBody() {
    return Center(
      child: Hero(
        tag: imagePath,
        child: InteractiveViewer(
          panEnabled: true,
          boundaryMargin: const EdgeInsets.all(20),
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.file(
            File(imagePath),
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return _buildErrorWidget();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.white,
          ),
          SizedBox(height: 16),
          Text(
            'Error loading image',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
