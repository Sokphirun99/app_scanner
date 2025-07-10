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
    final pdf = pw.Document();

    for (var document in documents) {
      final image = pw.MemoryImage(document.imageFile.readAsBytesSync());

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Center(child: pw.Image(image, fit: pw.BoxFit.contain));
          },
        ),
      );
    }

    final output = await getApplicationDocumentsDirectory();
    final pdfName = fileName ?? AppConstants.pdfFilePrefix + DateTime.now().millisecondsSinceEpoch.toString() + AppConstants.pdfExtension;
    final pdfPath = '${output.path}/$pdfName';
    final pdfFile = File(pdfPath);
    await pdfFile.writeAsBytes(await pdf.save());

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
