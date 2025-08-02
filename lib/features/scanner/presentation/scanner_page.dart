import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../shared/models/scanned_document.dart';
import 'providers/scanner_providers.dart';
import 'widgets/modern_document_card_optimized.dart' as optimized;
import 'widgets/modern_loading_widget.dart';

class ScannerPage extends ConsumerWidget {
  const ScannerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scannerState = ref.watch(scannerNotifierProvider);

    // Listen for state changes and show notifications
    ref.listen<ScannerState>(scannerNotifierProvider, (previous, next) {
      if (previous != null && next.hasError && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        );
      } else if (previous != null &&
          next.status == ScannerStatus.success &&
          next.lastSuccessMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.lastSuccessMessage!),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        );
      } else if (previous != null &&
          next.status == ScannerStatus.pdfGenerated) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('PDF generated and saved successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
            action:
                next.lastGeneratedPdfPath != null
                    ? SnackBarAction(
                      label: 'Share',
                      textColor: Colors.white,
                      onPressed:
                          () => ref
                              .read(scannerNotifierProvider.notifier)
                              .sharePdf(next.lastGeneratedPdfPath!),
                    )
                    : null,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Document Scanner',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          if (scannerState.documents.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed:
                  () =>
                      ref
                          .read(scannerNotifierProvider.notifier)
                          .clearDocuments(),
              tooltip: 'Clear All',
            ),
        ],
      ),
      body: _buildBody(context, ref, scannerState),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Main Scan Button
          FloatingActionButton.extended(
            heroTag: 'scan',
            onPressed: () => ref.read(scannerNotifierProvider.notifier).scanDocument(),
            icon: Icon(Icons.document_scanner_outlined, size: 24.sp),
            label: Text('Scan Document', style: TextStyle(fontSize: 14.sp)),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
          ),
          SizedBox(height: 12.h),
          // PDF Scan Button
          FloatingActionButton.small(
            heroTag: 'pdf_scan',
            onPressed:
                () =>
                    ref
                        .read(scannerNotifierProvider.notifier)
                        .scanDocumentToPdf(),
            backgroundColor: Theme.of(context).colorScheme.tertiary,
            foregroundColor: Theme.of(context).colorScheme.onTertiary,
            child: const Icon(Icons.picture_as_pdf),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, ScannerState state) {
    if (state.isLoading) {
      return const ModernLoadingWidget(message: 'Loading documents...');
    }

    if (state.documents.isEmpty) {
      return optimized.ModernEmptyStateWidget(
        icon: Icons.document_scanner_outlined,
        title: 'No Documents Yet',
        subtitle: 'No documents scanned yet. Tap the scan button to start.',
        actionText: 'Scan Document',
        onAction:
            () => ref.read(scannerNotifierProvider.notifier).scanDocument(),
      );
    }

    return Column(
      children: [
        _buildDocumentsHeader(context, ref, state.documents),
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.all(16.w),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16.w,
              mainAxisSpacing: 16.h,
              childAspectRatio: 0.75,
            ),
            itemCount: state.documents.length,
            // Add performance optimizations
            cacheExtent: 1000, // Pre-cache more items
            physics: const BouncingScrollPhysics(), // Smoother scrolling
            itemBuilder: (context, index) {
              // Remove heavy animations for better performance
              return optimized.ModernDocumentCard(
                key: ValueKey(
                  state.documents[index].id,
                ), // Add key for better widget recycling
                document: state.documents[index],
                onPreview:
                    () => _previewImage(
                      context,
                      state.documents[index].imagePath,
                    ),
                onDelete:
                    () => ref
                        .read(scannerNotifierProvider.notifier)
                        .removeDocument(index),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentsHeader(
    BuildContext context,
    WidgetRef ref,
    List<ScannedDocument> documents,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Scanned Documents (${documents.length})',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          ElevatedButton.icon(
            onPressed:
                () => ref.read(scannerNotifierProvider.notifier).generatePdf(),
            icon: Icon(Icons.picture_as_pdf_outlined, size: 18.sp),
            label: Text('Generate PDF', style: TextStyle(fontSize: 14.sp)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Theme.of(context).colorScheme.onSecondary,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _previewImage(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.all(10.w),
            child: InteractiveViewer(
              panEnabled: false,
              boundaryMargin: const EdgeInsets.all(80),
              minScale: 0.5,
              maxScale: 4,
              child: Image.file(File(imagePath), fit: BoxFit.contain),
            ),
          ),
    );
  }
}
