import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../data/services/pdf_viewer_service.dart';
import 'widgets/pdf_info_dialog.dart';

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
      return Stack(
        children: [
          SfPdfViewer.file(
            File(imagePath),
            enableDoubleTapZooming: true,
            canShowScrollHead: true,
            canShowScrollStatus: true,
            pageSpacing: 4.0,
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
                    'Document ${imageIndex! + 1} of $totalImages',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            top: 20,
            right: 20,
            child: FloatingActionButton(
              heroTag: 'open_external',
              mini: true,
              backgroundColor: Theme.of(context).colorScheme.secondary,
              onPressed: () async {
                final service = PdfViewerService();
                final opened = await service.openPdfWithExternalApp(imagePath);
                if (!opened && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('No app found to open PDF files'),
                    ),
                  );
                }
              },
              child: const Icon(Icons.open_in_new),
            ),
          ),
          Positioned(
            top: 20,
            right: 140,
            child: FloatingActionButton(
              heroTag: 'pdf_info',
              mini: true,
              backgroundColor: Theme.of(context).colorScheme.tertiary,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => PdfInfoDialog(filePath: imagePath),
                );
              },
              child: const Icon(Icons.info_outline),
            ),
          ),
          Positioned(
            top: 20,
            right: 80,
            child: FloatingActionButton(
              heroTag: 'share_pdf',
              mini: true,
              backgroundColor: Theme.of(context).colorScheme.primary,
              onPressed: () async {
                final service = PdfViewerService();
                await service.sharePdf(imagePath);
              },
              child: const Icon(Icons.share),
            ),
          ),
        ],
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
