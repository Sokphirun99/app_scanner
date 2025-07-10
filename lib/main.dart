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
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  await SentryFlutter.init(
    (options) {
      options.dsn = 'https://1b45803ca28e2a641c47f6679ee7edaa@o4509645142425600.ingest.us.sentry.io/4509645143801856';
      // Set tracesSampleRate to 1.0 to capture 100% of transactions for tracing.
      // We recommend adjusting this value in production.
      options.tracesSampleRate = 1.0;
      // The sampling rate for profiling is relative to tracesSampleRate
      // Setting to 1.0 will profile 100% of sampled transactions:
      options.profilesSampleRate = 1.0;
    },
    appRunner: () => runApp(SentryWidget(child: const MyApp())),
  );
  // TODO: Remove this line after sending the first sample event to sentry.
  await Sentry.captureException(Exception('This is a sample exception.'));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PDF Scanner App',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),
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
      final newDocuments = documents.map((doc) {
        final isPdf = doc.imagePath.toLowerCase().endsWith('.pdf');
        return ScannedDocument(
          id: doc.id,
          imagePath: doc.imagePath,
          createdAt: doc.createdAt,
          isPdf: isPdf,
        );
      }).toList();

      setState(() => scannedDocuments.addAll(newDocuments));

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
      if (mounted) {
        // Check if widget is still mounted
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
        title: const Text('PDF Scanner', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          if (scannedDocuments.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: _clearScannedDocuments,
              tooltip: 'Clear All',
            ),
        ],
      ),
      body: isLoading
          ? _buildLoadingState()
          : scannedDocuments.isEmpty
              ? _buildEmptyState()
              : _buildDocumentsGrid(),
      floatingActionButton: SpeedDial(
        icon: Icons.camera_alt_outlined,
        activeIcon: Icons.close,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.document_scanner_outlined),
            label: 'Scan Document',
            onTap: _scanDocuments,
          ),
          if (scannedDocuments.isNotEmpty)
            SpeedDialChild(
              child: const Icon(Icons.picture_as_pdf_outlined),
              label: 'Generate PDF',
              onTap: _generatePdf,
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 20),
          Text('Processing...', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.scanner_outlined,
            size: 100,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 20),
          const Text(
            'No Documents Scanned',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 10),
          Text(
            'Tap the camera button to start scanning',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsGrid() {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16.0),
          sliver: SliverToBoxAdapter(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${scannedDocuments.length} Scanned Document(s)',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: _generatePdf,
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  label: const Text('Generate PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final document = scannedDocuments[index];
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                          child: document.isPdf
                              ? const Icon(Icons.picture_as_pdf, size: 80, color: Colors.red)
                              : Image.file(
                                  document.imageFile,
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.visibility_outlined),
                              onPressed: () => _previewImage(document.imagePath),
                              tooltip: 'Preview',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                              onPressed: () => _removeDocument(index),
                              tooltip: 'Delete',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
              childCount: scannedDocuments.length,
            ),
          ),
        ),
      ],
    );
  }

  void _previewImage(String imagePath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ImagePreviewPage(
              imagePath: imagePath,
              imageIndex:
                  scannedDocuments.indexWhere(
                    (doc) => doc.imagePath == imagePath,
                  ) +
                  1,
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
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Close',
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: InteractiveViewer(
          maxScale: 5.0,
          minScale: 0.5,
          child: Image.file(
            File(imagePath),
            fit: BoxFit.contain,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
      ),
    );
  }
}
