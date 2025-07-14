import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/models/scanned_document.dart';
import '../../domain/repositories/pdf_repository.dart';

class PdfRepositoryImpl implements PdfRepository {
  @override
  Future<String> generatePdf(List<ScannedDocument> documents, {String? fileName}) async {
    if (documents.isEmpty) {
      throw Exception('No documents provided for PDF generation');
    }

    final pdf = pw.Document();

    for (var document in documents) {
      try {
        print('DEBUG: Processing document: ${document.imagePath}');
        
        // Check if the image file exists
        if (!document.exists) {
          print('DEBUG: Image file does not exist: ${document.imagePath}');
          throw Exception('Image file does not exist: ${document.imagePath}');
        }
        
        print('DEBUG: Image file exists, reading bytes...');
        
        // Read the image file
        final imageBytes = document.imageFile.readAsBytesSync();
        if (imageBytes.isEmpty) {
          print('DEBUG: Image file is empty: ${document.imagePath}');
          throw Exception('Image file is empty: ${document.imagePath}');
        }
        
        print('DEBUG: Image bytes read successfully, size: ${imageBytes.length}');

        final image = pw.MemoryImage(imageBytes);

        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            build: (pw.Context context) {
              return pw.Center(child: pw.Image(image, fit: pw.BoxFit.contain));
            },
          ),
        );
        
        print('DEBUG: Added page to PDF for ${document.imagePath}');
      } catch (e) {
        print('DEBUG: Error processing image ${document.imagePath}: $e');
        throw Exception('Error processing image ${document.imagePath}: $e');
      }
    }

    final output = await getTemporaryDirectory();
    final pdfName = fileName ?? AppConstants.pdfFilePrefix + DateTime.now().millisecondsSinceEpoch.toString() + AppConstants.pdfExtension;
    final pdfPath = '${output.path}/cache/$pdfName';
    
    print('DEBUG: PDF will be saved to: $pdfPath');
    
    // Create cache directory if it doesn't exist
    final cacheDir = Directory('${output.path}/cache');
    if (!cacheDir.existsSync()) {
      print('DEBUG: Creating cache directory: ${cacheDir.path}');
      cacheDir.createSync(recursive: true);
    }
    
    final pdfFile = File(pdfPath);
    
    try {
      final pdfBytes = await pdf.save();
      print('DEBUG: PDF generated, size: ${pdfBytes.length} bytes');
      await pdfFile.writeAsBytes(pdfBytes);
      print('DEBUG: PDF saved successfully to: $pdfPath');
      
      // Verify the PDF file exists
      if (pdfFile.existsSync()) {
        print('DEBUG: PDF file verified at: $pdfPath');
        print('DEBUG: PDF file size: ${pdfFile.lengthSync()} bytes');
      } else {
        print('DEBUG: ERROR: PDF file does not exist at: $pdfPath');
      }
    } catch (e) {
      print('DEBUG: Error saving PDF: $e');
      throw Exception('Error saving PDF to $pdfPath: $e');
    }

    return pdfPath;
  }

  @override
  Future<void> sharePdf(String pdfPath) async {
    await Share.shareXFiles([XFile(pdfPath)]);
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
