import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../../shared/models/scanned_document.dart';
import '../../domain/repositories/scanner_repository.dart';
import '../services/doc_scanner_service.dart';
import '../services/fallback_scanner_service.dart';

class ScannerRepositoryImpl implements ScannerRepository {
  static const String _documentsKey = 'scanned_documents';
  final DocScannerService _docScannerService = DocScannerService();
  final FallbackScannerService _fallbackScannerService =
      FallbackScannerService();

  @override
  Future<List<String>> scanDocuments() async {
    try {
      // Try the main document scanner first
      final scannedPaths = await _docScannerService.scanDocuments(
        pageLimit: 10,
      );

      // If successful and not empty, return the results
      if (scannedPaths.isNotEmpty) {
        return scannedPaths;
      }

      // If main scanner returns empty (could be due to errors), try fallback
      final fallbackPaths = await _fallbackScannerService
          .scanDocumentsWithCamera(maxImages: 5);
      return fallbackPaths;
    } catch (e) {
      if (e.toString().contains('User cancelled') ||
          e.toString().contains('cancelled')) {
        return []; // Return empty list for cancellation
      }

      // If main scanner fails completely, try fallback
      try {
        final fallbackPaths = await _fallbackScannerService
            .scanDocumentsWithCamera(maxImages: 5);
        return fallbackPaths;
      } catch (fallbackError) {
        throw Exception('Scanning failed: ${e.toString()}');
      }
    }
  }

  @override
  Future<List<ScannedDocument>> getScannedDocuments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final documentsJson = prefs.getStringList(_documentsKey) ?? [];

      return documentsJson.map((json) {
        final map = jsonDecode(json) as Map<String, dynamic>;
        return ScannedDocument.fromJson(map);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get scanned documents: $e');
    }
  }

  @override
  Future<void> addScannedDocument(ScannedDocument document) async {
    try {
      final documents = await getScannedDocuments();
      documents.add(document);
      await _saveDocuments(documents);
    } catch (e) {
      throw Exception('Failed to add scanned document: $e');
    }
  }

  @override
  Future<void> removeScannedDocument(String documentId) async {
    try {
      final documents = await getScannedDocuments();
      documents.removeWhere((doc) => doc.id == documentId);
      await _saveDocuments(documents);
    } catch (e) {
      throw Exception('Failed to remove scanned document: $e');
    }
  }

  @override
  Future<void> clearAllDocuments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_documentsKey);
    } catch (e) {
      throw Exception('Failed to clear all documents: $e');
    }
  }

  @override
  Future<bool> documentExists(String documentId) async {
    try {
      final documents = await getScannedDocuments();
      return documents.any((doc) => doc.id == documentId);
    } catch (e) {
      throw Exception('Failed to check document existence: $e');
    }
  }

  Future<void> _saveDocuments(List<ScannedDocument> documents) async {
    final prefs = await SharedPreferences.getInstance();
    final documentsJson =
        documents.map((doc) => jsonEncode(doc.toJson())).toList();
    await prefs.setStringList(_documentsKey, documentsJson);
  }
}
