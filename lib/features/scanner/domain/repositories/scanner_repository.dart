import '../../../../shared/models/scanned_document.dart';

abstract class ScannerRepository {
  /// Scan documents using the device camera
  Future<List<String>> scanDocuments();
  
  /// Get all scanned documents
  Future<List<ScannedDocument>> getScannedDocuments();
  
  /// Add a scanned document
  Future<void> addScannedDocument(ScannedDocument document);
  
  /// Remove a scanned document
  Future<void> removeScannedDocument(String documentId);
  
  /// Clear all scanned documents
  Future<void> clearAllDocuments();
  
  /// Check if a document exists
  Future<bool> documentExists(String documentId);
}
