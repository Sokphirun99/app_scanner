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
      print('DEBUG: Starting document scan...');
      final result = await FlutterDocScanner().getScanDocuments();
      print('DEBUG: Scanner result: $result');
      print('DEBUG: Scanner result type: ${result.runtimeType}');
      
      // Allow EGL cleanup
      await Future.delayed(AppConstants.eglCleanupDelay);
      
      if (result != null && result is Map) {
        print('DEBUG: Result is a Map');
        final paths = result['paths'];
        final count = result['count'];
        print('DEBUG: Paths from result: $paths');
        print('DEBUG: Count from result: $count');
        
        if (paths != null && paths is List) {
          final List<String> scannedPaths = List<String>.from(paths);
          print('DEBUG: Original scanned paths: $scannedPaths');
          
          // Check if original files exist
          for (String path in scannedPaths) {
            final file = File(path);
            print('DEBUG: Original file $path exists: ${file.existsSync()}');
            if (file.existsSync()) {
              print('DEBUG: Original file size: ${file.lengthSync()} bytes');
            }
          }
          
          // Copy images to cache storage
          final cachePaths = await _copyImagesToCacheStorage(scannedPaths);
          print('DEBUG: Copied to cache paths: $cachePaths');
          
          return cachePaths;
        } else {
          print('DEBUG: Paths is null or not a List: $paths');
        }
      } else {
        print('DEBUG: Result is null or not a Map');
      }
      
      // Return empty list if user cancelled or no documents were scanned
      print('DEBUG: Returning empty list');
      return [];
    } catch (e) {
      print('DEBUG: Exception in scanDocuments: $e');
      final errorMessage = e.toString().toLowerCase();
      if (errorMessage.contains('cancel') || errorMessage.contains('abort')) {
        // User cancelled - return empty list instead of throwing
        print('DEBUG: User cancelled scanning');
        return [];
      }
      throw Exception('Failed to scan documents: $e');
    }
  }
  
  Future<List<String>> _copyImagesToCacheStorage(List<String> tempPaths) async {
    try {
      // Get the app's cache directory
      final directory = await getTemporaryDirectory();
      final scannerDir = Directory('${directory.path}/cache/scanned_images');
      
      // Create the directory if it doesn't exist
      if (!scannerDir.existsSync()) {
        scannerDir.createSync(recursive: true);
      }
      
      final cachePaths = <String>[];
      
      for (int i = 0; i < tempPaths.length; i++) {
        final tempPath = tempPaths[i];
        final tempFile = File(tempPath);
        
        // Check if the temporary file exists
        if (!tempFile.existsSync()) {
          print('DEBUG: Temporary file does not exist: $tempPath');
          continue;
        }
        
        // Generate a unique filename
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final fileName = 'scanned_${timestamp}_$i.jpg';
        final cachePath = '${scannerDir.path}/$fileName';
        
        try {
          // Copy the file to cache storage
          await tempFile.copy(cachePath);
          cachePaths.add(cachePath);
          print('DEBUG: Successfully copied $tempPath to $cachePath');
          
          // Verify the copied file exists
          final copiedFile = File(cachePath);
          if (copiedFile.existsSync()) {
            print('DEBUG: Copied file verified at: $cachePath');
          } else {
            print('DEBUG: ERROR: Copied file does not exist at: $cachePath');
          }
        } catch (e) {
          print('DEBUG: Error copying file $tempPath: $e');
        }
      }
      
      return cachePaths;
    } catch (e) {
      print('DEBUG: Error in _copyImagesToCacheStorage: $e');
      rethrow;
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
