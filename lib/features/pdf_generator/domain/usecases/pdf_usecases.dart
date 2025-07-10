import '../../../../shared/models/scanned_document.dart';
import '../repositories/pdf_repository.dart';

class GeneratePdfUsecase {
  final PdfRepository repository;

  GeneratePdfUsecase(this.repository);

  Future<String> call(List<ScannedDocument> documents, {String? fileName}) async {
    if (documents.isEmpty) {
      throw Exception('No documents provided for PDF generation');
    }

    try {
      return await repository.generatePdf(documents, fileName: fileName);
    } catch (e) {
      throw Exception('Failed to generate PDF: $e');
    }
  }
}

class SharePdfUsecase {
  final PdfRepository repository;

  SharePdfUsecase(this.repository);

  Future<void> call(String pdfPath) async {
    try {
      final exists = await repository.pdfExists(pdfPath);
      if (!exists) {
        throw Exception('PDF file does not exist');
      }
      
      await repository.sharePdf(pdfPath);
    } catch (e) {
      throw Exception('Failed to share PDF: $e');
    }
  }
}

class DeletePdfUsecase {
  final PdfRepository repository;

  DeletePdfUsecase(this.repository);

  Future<void> call(String pdfPath) async {
    try {
      await repository.deletePdf(pdfPath);
    } catch (e) {
      throw Exception('Failed to delete PDF: $e');
    }
  }
}

class GetPdfInfoUsecase {
  final PdfRepository repository;

  GetPdfInfoUsecase(this.repository);

  Future<Map<String, dynamic>> call(String pdfPath) async {
    try {
      final exists = await repository.pdfExists(pdfPath);
      if (!exists) {
        return {'exists': false};
      }

      final size = await repository.getPdfSize(pdfPath);
      return {
        'exists': true,
        'size': size,
        'path': pdfPath,
      };
    } catch (e) {
      throw Exception('Failed to get PDF info: $e');
    }
  }
}
