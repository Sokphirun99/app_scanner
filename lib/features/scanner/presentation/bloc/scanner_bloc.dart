import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/models/scanned_document.dart';
import '../../domain/usecases/scan_document_usecase.dart';
import '../../../pdf_generator/domain/usecases/pdf_usecases.dart';
import 'scanner_event.dart';
import 'scanner_state.dart';

class ScannerBloc extends Bloc<ScannerEvent, ScannerState> {
  final ScanDocumentUsecase scanDocumentUsecase;
  final GeneratePdfUsecase generatePdfUsecase;
  final SharePdfUsecase sharePdfUsecase;

  // ignore: prefer_final_fields
  List<ScannedDocument> _documents = [];

  ScannerBloc({
    required this.scanDocumentUsecase,
    required this.generatePdfUsecase,
    required this.sharePdfUsecase,
  }) : super(ScannerInitial()) {
    on<ScanDocumentEvent>(_onScanDocument);
    on<ScanCancelledEvent>(_onScanCancelled);
    on<GeneratePdfEvent>(_onGeneratePdf);
    on<ClearDocumentsEvent>(_onClearDocuments);
    on<RemoveDocumentEvent>(_onRemoveDocument);
    on<SharePdfEvent>(_onSharePdf);
  }

  Future<void> _onScanDocument(
    ScanDocumentEvent event,
    Emitter<ScannerState> emit,
  ) async {
    emit(ScannerLoading());

    try {
      final documents = await scanDocumentUsecase.call();
      
      // Handle case where user cancels scanning or no documents are scanned
      if (documents.isEmpty) {
        emit(ScannerLoaded(List.from(_documents))); // Just reload current state
        return;
      }
      
      final newDocuments = documents.map((doc) {
        final isPdf = doc.imagePath.toLowerCase().endsWith('.pdf');
        print('DEBUG: Scanned document path: ${doc.imagePath}');
        print('DEBUG: File exists: ${doc.exists}');
        return ScannedDocument(
          id: doc.id,
          imagePath: doc.imagePath,
          createdAt: doc.createdAt,
          isPdf: isPdf,
        );
      }).toList();

      _documents.addAll(newDocuments);
      
      // Show success message first
      emit(ScannerSuccess(
        'Successfully scanned ${documents.length} document(s)',
        List.from(_documents),
      ));
      
      // Auto-generate PDF after scanning
      await _generatePdfAutomatically(emit);
      
    } catch (e) {
      final errorMessage = e.toString();
      if (errorMessage.contains('User cancelled') || errorMessage.contains('cancelled')) {
        // User cancelled scanning - just reload current state without error
        emit(ScannerLoaded(List.from(_documents)));
      } else {
        emit(ScannerError('Error scanning document: $e', List.from(_documents)));
      }
    }
  }
  
  Future<void> _generatePdfAutomatically(Emitter<ScannerState> emit) async {
    try {
      // Debug: Check if all documents exist
      final validDocuments = _documents.where((doc) => doc.exists).toList();
      print('DEBUG: Auto-generating PDF...');
      print('DEBUG: Total documents: ${_documents.length}');
      print('DEBUG: Valid documents: ${validDocuments.length}');
      
      if (validDocuments.isEmpty) {
        print('DEBUG: No valid documents for PDF generation');
        return;
      }
      
      final pdfPath = await generatePdfUsecase.call(_documents);
      print('DEBUG: PDF auto-generated at: $pdfPath');
      emit(PdfGenerated(pdfPath, List.from(_documents)));
    } catch (e) {
      print('DEBUG: Auto PDF generation error: $e');
      // Don't emit error for auto-generation failure, just log it
      // The user can still manually generate PDF later
    }
  }

  Future<void> _onScanCancelled(
    ScanCancelledEvent event,
    Emitter<ScannerState> emit,
  ) async {
    // Just reload the current state without any error message
    emit(ScannerLoaded(List.from(_documents)));
  }

  Future<void> _onGeneratePdf(
    GeneratePdfEvent event,
    Emitter<ScannerState> emit,
  ) async {
    if (_documents.isEmpty) {
      emit(ScannerError('No scanned images to generate PDF', List.from(_documents)));
      return;
    }

    emit(ScannerLoading());

    try {
      // Debug: Check if all documents exist
      final validDocuments = _documents.where((doc) => doc.exists).toList();
      print('DEBUG: Total documents: ${_documents.length}');
      print('DEBUG: Valid documents: ${validDocuments.length}');
      
      for (var doc in _documents) {
        print('DEBUG: Document ${doc.id}: path=${doc.imagePath}, exists=${doc.exists}');
      }
      
      if (validDocuments.isEmpty) {
        emit(ScannerError('No valid image files found for PDF generation', List.from(_documents)));
        return;
      }
      
      if (validDocuments.length != _documents.length) {
        emit(ScannerError('Some scanned images are missing from storage', List.from(_documents)));
        return;
      }
      
      final pdfPath = await generatePdfUsecase.call(_documents);
      print('DEBUG: PDF generated at: $pdfPath');
      emit(PdfGenerated(pdfPath, List.from(_documents)));
    } catch (e) {
      print('DEBUG: PDF generation error: $e');
      emit(ScannerError('Error generating PDF: $e', List.from(_documents)));
    }
  }

  Future<void> _onClearDocuments(
    ClearDocumentsEvent event,
    Emitter<ScannerState> emit,
  ) async {
    _documents.clear();
    emit(ScannerSuccess('Cleared all scanned documents', List.from(_documents)));
  }

  Future<void> _onRemoveDocument(
    RemoveDocumentEvent event,
    Emitter<ScannerState> emit,
  ) async {
    if (event.index >= 0 && event.index < _documents.length) {
      _documents.removeAt(event.index);
      emit(ScannerLoaded(List.from(_documents)));
    }
  }

  Future<void> _onSharePdf(
    SharePdfEvent event,
    Emitter<ScannerState> emit,
  ) async {
    try {
      await sharePdfUsecase.call(event.pdfPath);
    } catch (e) {
      emit(ScannerError('Error sharing PDF: $e', List.from(_documents)));
    }
  }
}
