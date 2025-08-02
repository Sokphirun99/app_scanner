// Clean and optimized Document Scanner Service
import 'package:flutter_doc_scanner/flutter_doc_scanner.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

/// Enhanced service for document scanning with improved error handling
class CleanDocScannerService {
  final FlutterDocScanner _scanner = FlutterDocScanner();
  final _uuid = const Uuid();

  // Configuration constants
  static const int defaultPageLimit = 10;
  static const String scanFolderName = 'scanned_docs';

  /// Scan documents and return image file paths
  Future<ScanResult> scanDocuments({int pageLimit = defaultPageLimit}) async {
    try {
      final scanDir = await _ensureScanDirectory();
      final result = await _scanner.getScannedDocumentAsImages(page: pageLimit);

      if (result == null || (result is List && result.isEmpty)) {
        return ScanResult.cancelled();
      }

      final savedPaths = await _saveScannedImages(result as List, scanDir);
      return ScanResult.success(savedPaths);
    } catch (e) {
      if (_isUserCancellation(e)) {
        return ScanResult.cancelled();
      }
      return ScanResult.error('Scanning failed: ${e.toString()}');
    }
  }

  /// Scan documents directly to PDF
  Future<PdfScanResult> scanToPdf({int pageLimit = defaultPageLimit}) async {
    try {
      final pdfPath = await _scanner.getScannedDocumentAsPdf(page: pageLimit);

      if (pdfPath == null || pdfPath.isEmpty) {
        return PdfScanResult.cancelled();
      }

      return PdfScanResult.success(pdfPath);
    } catch (e) {
      if (_isUserCancellation(e)) {
        return PdfScanResult.cancelled();
      }
      return PdfScanResult.error('PDF scanning failed: ${e.toString()}');
    }
  }

  // Private helper methods
  Future<Directory> _ensureScanDirectory() async {
    final tempDir = await getTemporaryDirectory();
    final scanDir = Directory(path.join(tempDir.path, scanFolderName));

    if (!await scanDir.exists()) {
      await scanDir.create(recursive: true);
    }

    return scanDir;
  }

  Future<List<String>> _saveScannedImages(
    List<dynamic> results,
    Directory scanDir,
  ) async {
    final savedPaths = <String>[];

    for (final imagePath in results) {
      if (imagePath is String && imagePath.isNotEmpty) {
        final savedPath = await _saveImage(imagePath, scanDir);
        if (savedPath != null) {
          savedPaths.add(savedPath);
        }
      }
    }

    return savedPaths;
  }

  Future<String?> _saveImage(String sourcePath, Directory scanDir) async {
    try {
      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) return null;

      final fileName =
          'scan_${DateTime.now().millisecondsSinceEpoch}_${_uuid.v4()}.jpg';
      final targetPath = path.join(scanDir.path, fileName);

      await sourceFile.copy(targetPath);
      return targetPath;
    } catch (e) {
      debugPrint('Warning: Failed to save image $sourcePath: $e');
      return null;
    }
  }

  bool _isUserCancellation(dynamic error) {
    final errorStr = error.toString().toLowerCase();
    return errorStr.contains('cancel') ||
        errorStr.contains('cancelled') ||
        errorStr.contains('user cancel');
  }
}

/// Result class for scan operations
class ScanResult {
  final bool isSuccess;
  final bool isCancelled;
  final List<String> imagePaths;
  final String? errorMessage;

  ScanResult._(
    this.isSuccess,
    this.isCancelled,
    this.imagePaths,
    this.errorMessage,
  );

  factory ScanResult.success(List<String> paths) =>
      ScanResult._(true, false, paths, null);

  factory ScanResult.cancelled() => ScanResult._(false, true, [], null);

  factory ScanResult.error(String message) =>
      ScanResult._(false, false, [], message);
}

/// Result class for PDF scan operations
class PdfScanResult {
  final bool isSuccess;
  final bool isCancelled;
  final String? pdfPath;
  final String? errorMessage;

  PdfScanResult._(
    this.isSuccess,
    this.isCancelled,
    this.pdfPath,
    this.errorMessage,
  );

  factory PdfScanResult.success(String path) =>
      PdfScanResult._(true, false, path, null);

  factory PdfScanResult.cancelled() => PdfScanResult._(false, true, null, null);

  factory PdfScanResult.error(String message) =>
      PdfScanResult._(false, false, null, message);
}
