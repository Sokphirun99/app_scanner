import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ImagePreviewPage extends StatelessWidget {
  final String imagePath;
  final String? title;
  final Function? onDelete;
  final int? imageIndex;
  final int? totalImages;
  final Function(String)? onImageDeleted;

  const ImagePreviewPage({
    super.key, 
    required this.imagePath,
    this.title,
    this.onDelete,
    this.imageIndex,
    this.totalImages,
    this.onImageDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title ?? 'Document Preview',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (onDelete != null)
            IconButton(
              icon: Icon(Icons.delete_outline),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Delete Document'),
                    content: Text('Are you sure you want to delete this document?'),
                    actions: [
                      TextButton(
                        child: Text('Cancel'),
                        onPressed: () => Navigator.pop(context),
                      ),
                      TextButton(
                        child: Text(
                          'Delete',
                          style: TextStyle(color: Colors.red),
                        ),
                        onPressed: () {
                          Navigator.pop(context); // Close dialog
                          if (onImageDeleted != null) {
                            onImageDeleted!(imagePath);
                          } else if (onDelete != null) {
                            onDelete!();
                          }
                          Navigator.pop(context); // Go back to previous screen
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: _buildPreviewBody(context),
    );
  }

  Widget _buildPreviewBody(BuildContext context) {
    if (imagePath.toLowerCase().endsWith('.pdf')) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.picture_as_pdf,
              size: 100.r,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(height: 20.h),
            Text(
              'PDF Document',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (totalImages != null && imageIndex != null)
              Text(
                'Document ${imageIndex! + 1} of $totalImages',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey[600],
                ),
              ),
            SizedBox(height: 10.h),
            ElevatedButton.icon(
              icon: Icon(Icons.open_in_new),
              label: Text('Open PDF'),
              onPressed: () {
                // Here you would implement PDF viewing functionality
                // This could be done with a PDF viewer package
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('PDF viewing will be implemented soon'),
                  ),
                );
              },
            ),
          ],
        ),
      );
    } else {
      // For image files
      return Container(
        color: Colors.black,
        child: Stack(
          children: [
            InteractiveViewer(
              panEnabled: true,
              boundaryMargin: EdgeInsets.all(80),
              minScale: 0.5,
              maxScale: 4,
              child: Center(
                child: Image.file(
                  File(imagePath),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            if (totalImages != null && imageIndex != null)
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 153, red: 0, green: 0, blue: 0),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      'Image ${imageIndex! + 1} of $totalImages',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    }
  }
}
