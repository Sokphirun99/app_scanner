import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:path/path.dart' as p;
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/models/scanned_document.dart';
import '../../domain/repositories/pdf_repository.dart';

class PdfRepositoryImpl implements PdfRepository {
  @override
  Future<String> generatePdf(
    List<ScannedDocument> documents, {
    String? fileName,
  }) async {
    if (documents.isEmpty) {
      throw Exception('No documents provided for PDF generation');
    }

    final pdf = pw.Document();

    for (var document in documents) {
      try {
        // Processing document
        if (!document.exists) {
          continue; // Skip this document instead of throwing
        }

        final rawImage = document.imageFile.readAsBytesSync();
        final image = img.decodeImage(rawImage);

        if (image == null) {
          continue; // Skip this image if it can't be decoded
        }

        final encodedImage = img.encodePng(image);
        final pdfImage = pw.MemoryImage(encodedImage);

        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            build: (pw.Context context) {
              return pw.Center(
                child: pw.Image(pdfImage, fit: pw.BoxFit.contain),
              );
            },
          ),
        );
      } catch (e) {
        continue; // Skip this image and continue with others
      }
    }

    final output = await getTemporaryDirectory();
    final pdfName =
        fileName ??
        '${AppConstants.pdfFilePrefix}${DateTime.now().millisecondsSinceEpoch}${AppConstants.pdfExtension}';
    final pdfPath = p.join(output.path, pdfName);

    final pdfFile = File(pdfPath);

    try {
      final pdfBytes = await pdf.save();
      await pdfFile.writeAsBytes(pdfBytes);
      // Verify the PDF file exists
      if (pdfFile.existsSync()) {
        // File verification
      } else {
        // Handle file not found error
      }
    } catch (e) {
      throw Exception('Error saving PDF to $pdfPath: $e');
    }

    return pdfPath;
  }

  @override
  Future<void> sharePdf(String pdfPath) async {
    try {
      await Share.shareXFiles([XFile(pdfPath)]);
    } catch (e) {
      throw Exception('Failed to share PDF: $e');
    }
  }

  @override
  Future<void> deletePdf(String pdfPath) async {
    final file = File(pdfPath);
    if (file.existsSync()) {
      await file.delete();
    }
  }

  @override
  Future<bool> pdfExists(String pdfPath) async {
    return File(pdfPath).existsSync();
  }

  @override
  Future<int> getPdfSize(String pdfPath) async {
    return File(pdfPath).lengthSync();
  }
}
