import 'dart:io';
import 'package:flutter_doc_scanner/flutter_doc_scanner.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/models/scanned_document.dart';
import '../../domain/repositories/scanner_repository.dart';

class ScannerRepositoryImpl implements ScannerRepository {
  final List<ScannedDocument> _documents = [];

  @override
  Future<List<String>> scanDocuments() async {
    try {
      final result = await FlutterDocScanner().getScanDocuments();
      
      // Allow EGL cleanup
      await Future.delayed(AppConstants.eglCleanupDelay);
      
      
      if (result != null) {
        // Check for PDF URI
        if (result is Map && result.containsKey('pdfUri')) {
          final pdfUri = result['pdfUri'] as String?;
          if (pdfUri != null) {
            return await _copyPdfToAppDirectory(pdfUri);
          }
        } else if (result is List<String>) {
          return await _validateAndCopyImageFiles(result);
        } else if (result is List) {
          final paths = result.map((item) => item.toString()).toList();
          final validPaths = paths.where((path) => path.isNotEmpty && path != 'null').toList();
          return await _validateAndCopyImageFiles(validPaths);
        } else {
          return [];
        }
      }
      
      return [];
    } catch (e) {
      throw Exception('Failed to scan documents: $e');
    }
  }

  /// Validate and copy image files to app directory
  Future<List<String>> _validateAndCopyImageFiles(List<String> imagePaths) async {
    final validPaths = <String>[];
    
    try {
      // Get app temporary directory for caching
      final tempDir = await getTemporaryDirectory();
      
      for (final path in imagePaths) {
        try {
          // Clean the path and create source file
          final cleanPath = path.replaceFirst('file://', '');
          final sourceFile = File(cleanPath);
          
          // Check if source file exists
          if (!await sourceFile.exists()) {
            print('Source file does not exist: $cleanPath');
            continue;
          }
          
          // Check if it's a valid image file
          final extension = cleanPath.split('.').last.toLowerCase();
          if (!['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension)) {
            print('Invalid image extension: $extension');
            continue;
          }
          
          // Generate new filename and destination path
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final fileName = 'scanned_image_${timestamp}_${validPaths.length}.$extension';
          final destinationPath = '${tempDir.path}/$fileName';
          
          // Copy the file to the cache directory
          final destinationFile = await sourceFile.copy(destinationPath);
          
          // Verify the copied file exists and is readable
          if (await destinationFile.exists()) {
            validPaths.add(destinationFile.path);
            print('Successfully copied image: ${destinationFile.path}');
          } else {
            print('Failed to copy image: $cleanPath');
          }
        } catch (e) {
          print('Error processing image path $path: $e');
        }
      }
      
      return validPaths;
    } catch (e) {
      print('Error in _validateAndCopyImageFiles: $e');
      return [];
    }
  }
  
  /// Copy PDF from temporary location to app directory
  Future<List<String>> _copyPdfToAppDirectory(String pdfUri) async {
    try {
      final sourceFile = File(pdfUri.replaceFirst('file://', ''));
      if (!await sourceFile.exists()) {
        return [];
      }

      // Get app temporary directory for caching
      final tempDir = await getTemporaryDirectory();
      final fileName = 'scanned_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final destinationPath = '${tempDir.path}/$fileName';
      
      // Copy the file to the cache directory
      final destinationFile = await sourceFile.copy(destinationPath);
      
      return [destinationFile.path];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<ScannedDocument>> getScannedDocuments() async {
    // Filter out documents that no longer exist on the file system
    _documents.removeWhere((doc) => !doc.exists);
    return List.from(_documents);
  }

  @override
  Future<void> addScannedDocument(ScannedDocument document) async {
    if (!_documents.any((doc) => doc.id == document.id)) {
      _documents.add(document);
    }
  }

  @override
  Future<void> removeScannedDocument(String documentId) async {
    _documents.removeWhere((doc) => doc.id == documentId);
  }

  @override
  Future<void> clearAllDocuments() async {
    _documents.clear();
  }

  @override
  Future<bool> documentExists(String documentId) async {
    return _documents.any((doc) => doc.id == documentId && doc.exists);
  }
}
