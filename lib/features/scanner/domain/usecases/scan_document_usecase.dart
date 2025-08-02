import '../../../../shared/models/scanned_document.dart';
import '../repositories/scanner_repository.dart';

class ScanDocumentUsecase {
  final ScannerRepository repository;

  ScanDocumentUsecase(this.repository);

  /// Scan documents and return ScannedDocument objects
  Future<List<ScannedDocument>> call() async {
    try {
      final imagePaths = await repository.scanDocuments();
      final documents = <ScannedDocument>[];

      for (String path in imagePaths) {
        if (path.isNotEmpty) {
          final document = ScannedDocument(
            id:
                DateTime.now().millisecondsSinceEpoch.toString() +
                path.hashCode.toString(),
            imagePath: path,
            createdAt: DateTime.now(),
          );

          await repository.addScannedDocument(document);
          documents.add(document);
        }
      }

      return documents;
    } catch (e) {
      final errorString = e.toString().toLowerCase();

      // Provide user-friendly error messages
      if (errorString.contains('permission')) {
        throw Exception('Camera permission is required to scan documents');
      }

      if (errorString.contains('avfoundation') ||
          errorString.contains('scan_error') ||
          errorString.contains('camera')) {
        throw Exception(
          'Camera error occurred. Please try restarting the app or check camera permissions',
        );
      }

      if (errorString.contains('no documents') ||
          errorString.contains('cancelled')) {
        return []; // Return empty list for cancellation
      }

      throw Exception('Scanning failed. Please try again');
    }
  }
}

class GetScannedDocumentsUsecase {
  final ScannerRepository repository;

  GetScannedDocumentsUsecase(this.repository);

  Future<List<ScannedDocument>> call() async {
    try {
      return await repository.getScannedDocuments();
    } catch (e) {
      throw Exception('Failed to get scanned documents: $e');
    }
  }
}

class RemoveDocumentUsecase {
  final ScannerRepository repository;

  RemoveDocumentUsecase(this.repository);

  Future<void> call(String documentId) async {
    try {
      await repository.removeScannedDocument(documentId);
    } catch (e) {
      throw Exception('Failed to remove document: $e');
    }
  }
}

class ClearAllDocumentsUsecase {
  final ScannerRepository repository;

  ClearAllDocumentsUsecase(this.repository);

  Future<void> call() async {
    try {
      await repository.clearAllDocuments();
    } catch (e) {
      throw Exception('Failed to clear all documents: $e');
    }
  }
}
