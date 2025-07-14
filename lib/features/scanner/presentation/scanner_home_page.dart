import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/permission_service.dart';
import '../data/repositories/scanner_repository_impl.dart';
import '../domain/usecases/scan_document_usecase.dart';
import '../../pdf_generator/data/repositories/pdf_repository_impl.dart';
import '../../pdf_generator/domain/usecases/pdf_usecases.dart';
import '../../../shared/models/scanned_document.dart';
import 'image_preview_page.dart';
import 'widgets/document_card.dart';
import 'widgets/empty_state_widget.dart';
import 'widgets/loading_widget.dart';

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
        _showSuccessSnackBar(
          'Successfully scanned ${documents.length} document(s)',
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error scanning document: $e');
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _generatePdf() async {
    if (scannedDocuments.isEmpty) {
      _showWarningSnackBar(AppConstants.noScannedImages);
      return;
    }
    
    setState(() => isLoading = true);

    try {
      final pdfPath = await pdfUsecase.call(scannedDocuments);
      if (mounted) {
        _showSuccessSnackBarWithAction(
          '${AppConstants.pdfSavedTo} $pdfPath',
          AppConstants.share,
          () => _sharePdf(pdfPath),
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error generating PDF: $e');
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _sharePdf(String pdfPath) async {
    try {
      await sharePdfUsecase.call(pdfPath);
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error sharing PDF: $e');
      }
    }
  }

  void _clearScannedDocuments() {
    setState(() => scannedDocuments.clear());
    _showInfoSnackBar('Cleared all scanned documents');
  }

  void _removeDocument(int index) {
    setState(() => scannedDocuments.removeAt(index));
  }

  void _previewImage(String imagePath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImagePreviewPage(
          imagePath: imagePath,
          imageIndex: scannedDocuments.indexWhere((doc) => doc.imagePath == imagePath) + 1,
          totalImages: scannedDocuments.length,
        ),
      ),
    );
  }

  // Helper methods for showing snackbars
  void _showSuccessSnackBar(String message) {
    _showSnackBar(message, Colors.green);
  }

  void _showErrorSnackBar(String message) {
    _showSnackBar(message, Colors.red);
  }

  void _showWarningSnackBar(String message) {
    _showSnackBar(message, Colors.orange);
  }

  void _showInfoSnackBar(String message) {
    _showSnackBar(message, Colors.blue);
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }

  void _showSuccessSnackBarWithAction(String message, String actionLabel, VoidCallback onPressed) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: actionLabel,
          onPressed: onPressed,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
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
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return _buildLoadingWidget();
    }
    
    if (scannedDocuments.isEmpty) {
      return _buildEmptyStateWidget();
    }
    
    return _buildDocumentsList();
  }

  Widget _buildLoadingWidget() {
    return const LoadingWidget();
  }

  Widget _buildEmptyStateWidget() {
    return const EmptyStateWidget();
  }

  Widget _buildDocumentsList() {
    return Column(
      children: [
        _buildDocumentsHeader(),
        Expanded(
          child: _buildDocumentsGrid(),
        ),
      ],
    );
  }

  Widget _buildDocumentsHeader() {
    return Container(
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
    );
  }

  Widget _buildDocumentsGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.7,
      ),
      itemCount: scannedDocuments.length,
      itemBuilder: (context, index) => _buildDocumentCard(index),
    );
  }

  Widget _buildDocumentCard(int index) {
    return DocumentCard(
      document: scannedDocuments[index],
      onPreview: () => _previewImage(scannedDocuments[index].imagePath),
      onDelete: () => _removeDocument(index),
    );
  }

  Widget _buildFloatingActionButton() {
    return SpeedDial(
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
    );
  }
}
