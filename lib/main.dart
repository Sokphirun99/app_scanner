import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import 'core/constants/app_constants.dart';
import 'core/services/permission_service.dart';
import 'features/scanner/data/repositories/scanner_repository_impl.dart';
import 'features/scanner/domain/usecases/scan_document_usecase.dart';
import 'features/pdf_generator/data/repositories/pdf_repository_impl.dart';
import 'features/pdf_generator/domain/usecases/pdf_usecases.dart';
import 'shared/models/scanned_document.dart';
import 'dart:io';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PDF Scanner App',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const ScannerHomePage(),
    );
  }
}

class ScannerHomePage extends StatefulWidget {
  const ScannerHomePage({super.key});

  @override
  State<ScannerHomePage> createState() => _ScannerHomePageState();
}

class _ScannerHomePageState extends State<ScannerHomePage> {
  final scannerUsecase = ScanDocumentUsecase(ScannerRepositoryImpl());
  final pdfUsecase = GeneratePdfUsecase(PdfRepositoryImpl());
  final sharePdfUsecase = SharePdfUsecase(PdfRepositoryImpl());

  List<ScannedDocument> scannedDocuments = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    PermissionService.requestPermissions();
  }

  Future<void> _scanDocuments() async {
    setState(() => isLoading = true);

    try {
      final documents = await scannerUsecase.call();
      setState(() => scannedDocuments.addAll(documents));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Successfully scanned ${documents.length} document(s)',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error scanning document: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _generatePdf() async {
    if (scannedDocuments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppConstants.noScannedImages),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    setState(() => isLoading = true);

    try {
      final pdfPath = await pdfUsecase.call(scannedDocuments);
      if (mounted) { // Check if widget is still mounted
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppConstants.pdfSavedTo} $pdfPath'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: AppConstants.share,
              onPressed: () => _sharePdf(pdfPath),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _sharePdf(String pdfPath) async {
    try {
      await sharePdfUsecase.call(pdfPath);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }


  void _clearScannedDocuments() {
    setState(() => scannedDocuments.clear());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cleared all scanned documents'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _removeDocument(int index) {
    setState(() {
      scannedDocuments.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Scanner'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (scannedDocuments.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: _clearScannedDocuments,
              tooltip: 'Clear All',
            ),
        ],
      ),
      body:
          isLoading
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Processing...'),
                  ],
                ),
              )
              : scannedDocuments.isEmpty
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.document_scanner_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No documents scanned yet',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tap the camera button to start scanning',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              )
              : Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                    'Scanned Documents (${scannedDocuments.length})',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _generatePdf,
                          icon: const Icon(Icons.picture_as_pdf),
                          label: const Text('Generate PDF'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 0.7,
                          ),
                      itemCount: scannedDocuments.length,
                      itemBuilder: (context, index) {
                        return Card(
                          elevation: 4,
                          child: Column(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(8),
                                  ),
                                  child: Image.file(
                                    scannedDocuments[index].imageFile,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.visibility),
                                      onPressed: () => _previewImage(scannedDocuments[index].imagePath),
                                      tooltip: 'Preview',
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () => _removeDocument(index),
                                      tooltip: 'Delete',
                                      color: Colors.red,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.document_scanner),
            label: 'Scan Document',
              onTap: _scanDocuments,
          ),
          if (scannedDocuments.isNotEmpty)
            SpeedDialChild(
              child: const Icon(Icons.picture_as_pdf),
              label: 'Generate PDF',
              onTap: _generatePdf,
            ),
        ],
      ),
    );
  }

  void _previewImage(String imagePath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ImagePreviewPage(
              imagePath: imagePath,
              imageIndex: scannedDocuments.indexWhere((doc) => doc.imagePath == imagePath) + 1,
              totalImages: scannedDocuments.length,
            ),
      ),
    );
  }
}

class ImagePreviewPage extends StatelessWidget {
  final String imagePath;
  final int imageIndex;
  final int totalImages;

  const ImagePreviewPage({
    super.key,
    required this.imagePath,
    required this.imageIndex,
    required this.totalImages,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image $imageIndex of $totalImages'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: InteractiveViewer(
          child: Image.file(File(imagePath), fit: BoxFit.contain),
        ),
      ),
    );
  }
}
