import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../shared/models/scanned_document.dart';
import '../../domain/usecases/scan_document_usecase.dart';
import '../../domain/repositories/scanner_repository.dart';
import '../../data/repositories/scanner_repository_impl.dart';

// State enum
enum ScannerStatus {
  initial,
  loading,
  loaded,
  success,
  error,
  pdfGenerated,
  cancelled,
}

// State class
class ScannerState {
  final ScannerStatus status;
  final List<ScannedDocument> documents;
  final String? errorMessage;
  final String? lastSuccessMessage;
  final String? lastGeneratedPdfPath;

  const ScannerState({
    required this.status,
    required this.documents,
    this.errorMessage,
    this.lastSuccessMessage,
    this.lastGeneratedPdfPath,
  });

  bool get isLoading => status == ScannerStatus.loading;
  bool get hasError => status == ScannerStatus.error;

  ScannerState copyWith({
    ScannerStatus? status,
    List<ScannedDocument>? documents,
    String? errorMessage,
    String? lastSuccessMessage,
    String? lastGeneratedPdfPath,
  }) {
    return ScannerState(
      status: status ?? this.status,
      documents: documents ?? this.documents,
      errorMessage: errorMessage,
      lastSuccessMessage: lastSuccessMessage,
      lastGeneratedPdfPath: lastGeneratedPdfPath,
    );
  }
}

// StateNotifier
class ScannerNotifier extends StateNotifier<ScannerState> {
  final ScanDocumentUsecase _scanDocumentUsecase;

  ScannerNotifier(this._scanDocumentUsecase)
    : super(const ScannerState(status: ScannerStatus.initial, documents: []));

  Future<void> scanDocument() async {
    state = state.copyWith(status: ScannerStatus.loading);

    try {
      // Check camera permission
      final cameraPermission = await Permission.camera.status;
      if (cameraPermission.isDenied) {
        final result = await Permission.camera.request();
        if (result.isDenied) {
          state = state.copyWith(
            status: ScannerStatus.error,
            errorMessage: 'Camera permission is required to scan documents',
          );
          return;
        }
      }

      final documents = await _scanDocumentUsecase.call();
      state = state.copyWith(
        status: ScannerStatus.success,
        documents: [...state.documents, ...documents],
        lastSuccessMessage: 'Document scanned successfully!',
      );
    } catch (e) {
      state = state.copyWith(
        status: ScannerStatus.error,
        errorMessage: 'Failed to scan document: $e',
      );
    }
  }

  Future<void> scanDocumentToPdf() async {
    state = state.copyWith(status: ScannerStatus.loading);

    try {
      // Check camera permission
      final cameraPermission = await Permission.camera.status;
      if (cameraPermission.isDenied) {
        final result = await Permission.camera.request();
        if (result.isDenied) {
          state = state.copyWith(
            status: ScannerStatus.error,
            errorMessage: 'Camera permission is required to scan documents',
          );
          return;
        }
      }

      await _scanDocumentUsecase.call();

      // Simulate PDF generation
      await Future.delayed(const Duration(seconds: 2));

      state = state.copyWith(
        status: ScannerStatus.pdfGenerated,
        documents: [], // Clear documents after PDF generation
        lastGeneratedPdfPath: '/path/to/generated.pdf',
      );
    } catch (e) {
      state = state.copyWith(
        status: ScannerStatus.error,
        errorMessage: 'Failed to scan document to PDF: $e',
      );
    }
  }

  Future<void> generatePdf() async {
    if (state.documents.isEmpty) {
      state = state.copyWith(
        status: ScannerStatus.error,
        errorMessage: 'No documents to generate PDF',
      );
      return;
    }

    state = state.copyWith(status: ScannerStatus.loading);

    try {
      // Simulate PDF generation
      await Future.delayed(const Duration(seconds: 2));

      state = state.copyWith(
        status: ScannerStatus.pdfGenerated,
        lastGeneratedPdfPath: '/path/to/generated.pdf',
      );
    } catch (e) {
      state = state.copyWith(
        status: ScannerStatus.error,
        errorMessage: 'Failed to generate PDF: $e',
      );
    }
  }

  Future<void> sharePdf(String pdfPath) async {
    try {
      // Simulate sharing - this would normally use the share_plus package
      await Future.delayed(const Duration(milliseconds: 500));
      // Success is handled by the share dialog
    } catch (e) {
      state = state.copyWith(
        status: ScannerStatus.error,
        errorMessage: 'Failed to share PDF: $e',
      );
    }
  }

  void removeDocument(int index) {
    if (index >= 0 && index < state.documents.length) {
      final updatedDocuments = List<ScannedDocument>.from(state.documents);

      // Delete the file if it exists
      try {
        final file = File(updatedDocuments[index].imagePath);
        if (file.existsSync()) {
          file.deleteSync();
        }
      } catch (e) {
        // Log error but continue with removal
        debugPrint('Error deleting file: $e');
      }

      updatedDocuments.removeAt(index);
      state = state.copyWith(
        status: ScannerStatus.loaded,
        documents: updatedDocuments,
      );
    }
  }

  void clearDocuments() {
    // Delete all files
    for (final document in state.documents) {
      try {
        final file = File(document.imagePath);
        if (file.existsSync()) {
          file.deleteSync();
        }
      } catch (e) {
        // Log error but continue
        debugPrint('Error deleting file: $e');
      }
    }

    state = state.copyWith(
      status: ScannerStatus.initial,
      documents: [],
      errorMessage: null,
      lastSuccessMessage: null,
      lastGeneratedPdfPath: null,
    );
  }
}

// Repository provider
final scannerRepositoryProvider = Provider<ScannerRepository>((ref) {
  return ScannerRepositoryImpl();
});

// Use case provider
final scanDocumentUsecaseProvider = Provider<ScanDocumentUsecase>((ref) {
  return ScanDocumentUsecase(ref.read(scannerRepositoryProvider));
});

// Main provider
final scannerNotifierProvider =
    StateNotifierProvider<ScannerNotifier, ScannerState>((ref) {
      return ScannerNotifier(ref.read(scanDocumentUsecaseProvider));
    });
