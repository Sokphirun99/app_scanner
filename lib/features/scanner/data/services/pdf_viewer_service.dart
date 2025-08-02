import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class PdfViewerService {
  /// Open a PDF file with an external application
  Future<bool> openPdfWithExternalApp(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return false;
      }
      
      // Create a Uri from the file path
      final uri = Uri.file(filePath);
      
      // Check if we can launch the URI
      if (await canLaunchUrl(uri)) {
        return await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        return false;
      }
    } catch (e) {
      debugPrint('Error opening PDF: $e');
      return false;
    }
  }

  /// Share a PDF file with other apps
  Future<void> sharePdf(String filePath) async {
    try {
      // Create XFile from the file path
      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'Sharing PDF document',
      );
    } catch (e) {
      debugPrint('Error sharing PDF: $e');
    }
  }

  /// Get a temporary file path for saving a PDF
  Future<String> getTemporaryPdfPath() async {
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${tempDir.path}/scan_$timestamp.pdf';
  }
}
