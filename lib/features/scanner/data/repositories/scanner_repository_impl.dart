import 'package:flutter_doc_scanner/flutter_doc_scanner.dart';
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
      
      if (result != null && result.isNotEmpty) {
        return result;
      }
      
      return [];
    } catch (e) {
      throw Exception('Failed to scan documents: $e');
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
