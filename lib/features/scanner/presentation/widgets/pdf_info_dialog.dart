import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path/path.dart' as path;
import 'package:intl/intl.dart';

class PdfInfoDialog extends StatelessWidget {
  final String filePath;

  const PdfInfoDialog({
    super.key,
    required this.filePath,
  });

  @override
  Widget build(BuildContext context) {
    final file = File(filePath);
    final fileName = path.basename(filePath);
    final fileSize = _formatFileSize(file.lengthSync());
    final dateFormat = DateFormat('MMM dd, yyyy hh:mm a');
    final lastModified = dateFormat.format(file.lastModifiedSync());
    
    return AlertDialog(
      title: const Text('PDF Document Info'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(Icons.insert_drive_file, 'Name', fileName),
            SizedBox(height: 12.h),
            _buildInfoRow(Icons.folder, 'Location', path.dirname(filePath)),
            SizedBox(height: 12.h),
            _buildInfoRow(Icons.storage, 'Size', fileSize),
            SizedBox(height: 12.h),
            _buildInfoRow(Icons.access_time, 'Modified', lastModified),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20.r, color: Colors.grey[600]),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14.sp,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
