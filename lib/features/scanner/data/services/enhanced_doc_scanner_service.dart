// Enhanced DocScannerService with better error handling and organization
import 'package:flutter_doc_scanner/flutter_doc_scanner.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

/// Service class to handle document scanning using flutter_doc_scanner
class DocScannerService {
  final FlutterDocScanner _scanner = FlutterDocScanner();
  final _uuid = const Uuid();

  // Constants
  static const int _defaultPageLimit = 10;
  static const String _scanDirName = 'scanned_docs';

  /// Start the document scanning process and return image paths
  /// [pageLimit] - Maximum number of pages to scan (default: 10)
  Future<List<String>> scanDocuments({
    int pageLimit = _defaultPageLimit,
  }) async {
    try {
      final scanDir = await _createScanDirectory();

      // Start the scanner - get images explicitly
      final result = await _scanner.getScannedDocumentAsImages(page: pageLimit);

      if (result != null && result is List) {
        return await _processScanResults(result, scanDir);
      } else {
        // User cancelled scanning or no pages scanned
        return [];
      }
    } catch (e) {
      if (_isUserCancellation(e)) {
        return [];
      }
      throw Exception('Error during document scanning: $e');
    }
  }

  /// Scan documents and get the result as a PDF directly
  /// [pageLimit] - Maximum number of pages to scan (default: 10)
  Future<String?> scanDocumentsAsPdf({
    int pageLimit = _defaultPageLimit,
  }) async {
    try {
      final result = await _scanner.getScannedDocumentAsPdf(page: pageLimit);
      return result;
    } catch (e) {
      if (_isUserCancellation(e)) {
        return null;
      }
      throw Exception('Error during PDF document scanning: $e');
    }
  }

  /// Create the directory for storing scanned documents
  Future<Directory> _createScanDirectory() async {
    final tempDir = await getTemporaryDirectory();
    final scanDir = Directory(path.join(tempDir.path, _scanDirName));

    if (!await scanDir.exists()) {
      await scanDir.create(recursive: true);
    }

    return scanDir;
  }

  /// Process the scan results and save files to app directory
  Future<List<String>> _processScanResults(
    List<dynamic> results,
    Directory scanDir,
  ) async {
    final List<String> savedImagePaths = [];

    for (final imagePath in results) {
      if (imagePath != null && imagePath is String) {
        final savedPath = await _saveScannedImage(imagePath, scanDir);
        if (savedPath != null) {
          savedImagePaths.add(savedPath);
        }
      }
    }

    return savedImagePaths;
  }

  /// Save a scanned image to the app directory with a unique filename
  Future<String?> _saveScannedImage(String imagePath, Directory scanDir) async {
    try {
      // Generate a unique filename
      final uuid = _uuid.v4();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final newFilename = 'scan_${timestamp}_$uuid.jpg';
      final savedPath = path.join(scanDir.path, newFilename);

      // Copy the file to our app's directory
      final file = File(imagePath);
      if (await file.exists()) {
        await file.copy(savedPath);
        return savedPath;
      }
    } catch (e) {
      // Log error but don't throw - continue with other images
      debugPrint('Error saving scanned image: $e');
    }
    return null;
  }

  /// Check if the error is due to user cancellation
  bool _isUserCancellation(dynamic error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('cancel') ||
        errorString.contains('cancelled') ||
        errorString.contains('user cancel');
  }

  /// Clean up old scanned documents (optional utility method)
  Future<void> cleanupOldScans({
    Duration olderThan = const Duration(days: 7),
  }) async {
    try {
      final scanDir = await _createScanDirectory();
      final cutoffTime = DateTime.now().subtract(olderThan);

      final files = scanDir.listSync();
      for (final file in files) {
        if (file is File) {
          final stat = await file.stat();
          if (stat.modified.isBefore(cutoffTime)) {
            await file.delete();
          }
        }
      }
    } catch (e) {
      debugPrint('Error cleaning up old scans: $e');
    }
  }
}
