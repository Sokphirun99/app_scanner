import 'package:flutter_doc_scanner/flutter_doc_scanner.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

class DocScannerService {
  final FlutterDocScanner _scanner = FlutterDocScanner();
  final _uuid = Uuid();

  /// Start the document scanning process with a page limit
  Future<List<String>> scanDocuments({int pageLimit = 5}) async {
    try {
      // Create a directory to store scanned images
      final tempDir = await getTemporaryDirectory();
      final scanDir = Directory('${tempDir.path}/scanned_docs');
      if (!await scanDir.exists()) {
        await scanDir.create(recursive: true);
      }

      // Start the scanner - get images explicitly
      final result = await _scanner.getScannedDocumentAsImages(page: pageLimit);

      if (result != null && result is List) {
        // Process the scanned images
        final List<String> savedImagePaths = [];

        for (final imagePath in result) {
          if (imagePath != null && imagePath is String) {
            // Generate a unique filename
            final uuid = _uuid.v4();
            final timestamp = DateTime.now().millisecondsSinceEpoch;
            final newFilename = 'scan_${timestamp}_$uuid.jpg';
            final savedPath = path.join(scanDir.path, newFilename);

            // Copy the file to our app's directory
            final file = File(imagePath);
            if (await file.exists()) {
              await file.copy(savedPath);
              savedImagePaths.add(savedPath);
            }
          }
        }

        return savedImagePaths;
      } else {
        // User cancelled scanning or no pages scanned
        return [];
      }
    } catch (e) {
      final errorString = e.toString().toLowerCase();

      // Handle various types of cancellation
      if (errorString.contains('cancel') ||
          errorString.contains('cancelled') ||
          errorString.contains('user cancel')) {
        return [];
      }

      // Handle iOS-specific errors
      if (errorString.contains('avfoundation') ||
          errorString.contains('scan_error') ||
          errorString.contains('couldn\'t be completed')) {
        // Return empty list for iOS camera errors to prevent crash
        print('iOS Camera Error: $e');
        return [];
      }

      throw Exception('Error during document scanning: $e');
    }
  }

  /// Scan documents and get the result as a PDF
  Future<String?> scanDocumentsAsPdf({int pageLimit = 5}) async {
    try {
      final result = await _scanner.getScannedDocumentAsPdf(page: pageLimit);
      return result;
    } catch (e) {
      final errorString = e.toString().toLowerCase();

      // Handle various types of cancellation
      if (errorString.contains('cancel') ||
          errorString.contains('cancelled') ||
          errorString.contains('user cancel')) {
        return null;
      }

      // Handle iOS-specific errors
      if (errorString.contains('avfoundation') ||
          errorString.contains('scan_error') ||
          errorString.contains('couldn\'t be completed')) {
        // Return null for iOS camera errors to prevent crash
        print('iOS Camera Error in PDF scan: $e');
        return null;
      }

      throw Exception('Error during PDF document scanning: $e');
    }
  }
}
