import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'dart:typed_data';
import '../services/pdf_operations_service.dart';
import '../../../core/theme/app_theme.dart';

class PDFToolsPage extends StatefulWidget {
  const PDFToolsPage({super.key});

  @override
  _PDFToolsPageState createState() => _PDFToolsPageState();
}

class _PDFToolsPageState extends State<PDFToolsPage> {
  List<PlatformFile> _pdfFiles = [];
  bool _isLoading = false;

  Future<void> _pickPdfFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: true,
    );

    if (result != null) {
      setState(() {
        _pdfFiles = result.files;
      });
    }
  }

  Future<void> _mergePdfs() async {
    if (_pdfFiles.isEmpty) {
      _showMessage('Please select PDF files first');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final bytes = await PDFOperationsService.mergePdfs(_pdfFiles);
      await PDFOperationsService.sharePdf(
        bytes,
        PDFOperationsService.generateFileName('merged'),
      );
      _showMessage('PDFs merged successfully!');
    } catch (e) {
      _showMessage('Error merging PDFs: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _performPdfOperation(String operation) async {
    if (_pdfFiles.isEmpty) {
      _showMessage('Please select a PDF file first');
      return;
    }

    setState(() => _isLoading = true);
    try {
      Uint8List? result;
      switch (operation) {
        case 'split':
          final pages = await PDFOperationsService.splitPdfByPages(
            _pdfFiles[0],
            [1, 2, 3], // Split first 3 pages as example
          );
          if (pages.isNotEmpty) {
            await PDFOperationsService.sharePdf(
              pages[0],
              PDFOperationsService.generateFileName('split_page_1'),
            );
          }
          break;
        case 'rotate':
          result = await PDFOperationsService.rotatePdf(_pdfFiles[0], 90);
          break;
        case 'compress':
          result = await PDFOperationsService.compressPdf(
            _pdfFiles[0],
            'best',
          );
          break;
        case 'watermark':
          result = await PDFOperationsService.addWatermark(
            _pdfFiles[0],
            'CONFIDENTIAL',
            opacity: 0.3,
          );
          break;
      }

      if (result != null) {
        await PDFOperationsService.sharePdf(
          result,
          PDFOperationsService.generateFileName(operation),
        );
        _showMessage('$operation completed successfully!');
      }
    } catch (e) {
      _showMessage('Error performing $operation: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'PDF Tools',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.picture_as_pdf,
                            size: 48,
                            color: AppTheme.primaryColor,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_pdfFiles.length} PDF(s) selected',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _pickPdfFiles,
                            icon: const Icon(Icons.file_upload),
                            label: const Text('Select PDF Files'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'PDF Operations',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildOperationButton(
                        'Merge PDFs',
                        Icons.merge,
                        _mergePdfs,
                        enabled: _pdfFiles.length > 1,
                      ),
                      _buildOperationButton(
                        'Split PDF',
                        Icons.content_cut,
                        () => _performPdfOperation('split'),
                        enabled: _pdfFiles.isNotEmpty,
                      ),
                      _buildOperationButton(
                        'Rotate PDF',
                        Icons.rotate_right,
                        () => _performPdfOperation('rotate'),
                        enabled: _pdfFiles.isNotEmpty,
                      ),
                      _buildOperationButton(
                        'Compress PDF',
                        Icons.compress,
                        () => _performPdfOperation('compress'),
                        enabled: _pdfFiles.isNotEmpty,
                      ),
                      _buildOperationButton(
                        'Add Watermark',
                        Icons.branding_watermark,
                        () => _performPdfOperation('watermark'),
                        enabled: _pdfFiles.isNotEmpty,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: _pdfFiles.isEmpty
                        ? const Center(
                            child: Text(
                              'No PDF files selected',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _pdfFiles.length,
                            itemBuilder: (context, index) {
                              return Card(
                                child: ListTile(
                                  leading: const Icon(
                                    Icons.picture_as_pdf,
                                    color: Colors.red,
                                  ),
                                  title: Text(
                                    path.basename(_pdfFiles[index].name),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${(_pdfFiles[index].size / 1024 / 1024).toStringAsFixed(2)} MB',
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      setState(() {
                                        _pdfFiles.removeAt(index);
                                      });
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildOperationButton(
    String label,
    IconData icon,
    VoidCallback onPressed, {
    bool enabled = true,
  }) {
    return ElevatedButton.icon(
      onPressed: enabled ? onPressed : null,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: enabled ? AppTheme.accentColor : Colors.grey[300],
        foregroundColor: enabled ? Colors.white : Colors.grey[600],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
