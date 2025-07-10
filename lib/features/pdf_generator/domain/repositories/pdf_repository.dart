import '../../../../shared/models/scanned_document.dart';

abstract class PdfRepository {
  /// Generate PDF from scanned documents
  Future<String> generatePdf(List<ScannedDocument> documents, {String? fileName});
  
  /// Share PDF file
  Future<void> sharePdf(String pdfPath);
  
  /// Delete PDF file
  Future<void> deletePdf(String pdfPath);
  
  /// Check if PDF exists
  Future<bool> pdfExists(String pdfPath);
  
  /// Get PDF file size
  Future<int> getPdfSize(String pdfPath);
}
