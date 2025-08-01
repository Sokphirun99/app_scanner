import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../shared/models/scanned_document.dart';
import 'bloc/scanner_bloc.dart';
import 'bloc/scanner_event.dart';
import 'bloc/scanner_state.dart';
import 'widgets/modern_document_card.dart';
import 'widgets/modern_loading_widget.dart';

class ScannerPage extends StatelessWidget {
  const ScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Document Scanner',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          BlocBuilder<ScannerBloc, ScannerState>(builder: (context, state) {
            final documents = _getDocuments(state);
            if (documents.isNotEmpty) {
              return IconButton(
                icon: Icon(Icons.delete_sweep_outlined),
                onPressed: () => context.read<ScannerBloc>().add(ClearDocumentsEvent()),
                tooltip: 'Clear All',
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: BlocConsumer<ScannerBloc, ScannerState>(
        listener: (context, state) {
          if (state is ScannerError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            );
          } else if (state is ScannerSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            );
          } else if (state is PdfGenerated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('PDF generated and saved successfully!'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                action: SnackBarAction(
                  label: 'Share',
                  textColor: Colors.white,
                  onPressed:
                      () => context.read<ScannerBloc>().add(
                        SharePdfEvent(state.pdfPath),
                      ),
                ),
                duration: const Duration(seconds: 4),
              ),
            );
          }
        },
        builder: (context, state) {
          return _buildBody(context, state);
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // PDF Scan Button
          FloatingActionButton.small(
            heroTag: 'pdf_scan',
            onPressed: () => context.read<ScannerBloc>().add(ScanDocumentToPdfEvent()),
            backgroundColor: Theme.of(context).colorScheme.tertiary,
            foregroundColor: Theme.of(context).colorScheme.onTertiary,
            child: const Icon(Icons.picture_as_pdf),
          ),
          SizedBox(height: 12.h),
          // Main Scan Button
          FloatingActionButton.extended(
            heroTag: 'scan',
            onPressed: () => context.read<ScannerBloc>().add(ScanDocumentEvent()),
            icon: Icon(Icons.document_scanner_outlined, size: 24.sp),
            label: Text('Scan Document', style: TextStyle(fontSize: 14.sp)),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, ScannerState state) {
    if (state is ScannerLoading) {
      return const ModernLoadingWidget(message: 'Loading documents...');
    }

    final documents = _getDocuments(state);

    if (documents.isEmpty) {
      return ModernEmptyStateWidget(
        icon: Icons.document_scanner_outlined,
        title: 'No Documents Yet',
        subtitle: 'No documents scanned yet. Tap the scan button to start.',
        actionText: 'Scan Document',
        onAction: () => context.read<ScannerBloc>().add(ScanDocumentEvent()),
      );
    }

    return Column(
      children: [
        _buildDocumentsHeader(context, documents),
        Expanded(
          child: AnimationLimiter(
            child: GridView.builder(
              padding: EdgeInsets.all(16.w),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.w,
                mainAxisSpacing: 16.h,
                childAspectRatio: 0.75,
              ),
              itemCount: documents.length,
              itemBuilder: (context, index) {
                return AnimationConfiguration.staggeredGrid(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  columnCount: 2,
                  child: ScaleAnimation(
                    child: FadeInAnimation(
                      child: ModernDocumentCard(
                        document: documents[index],
                        onPreview: () => _previewImage(context, documents[index].imagePath),
                        onDelete: () => context.read<ScannerBloc>().add(RemoveDocumentEvent(index)),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentsHeader(BuildContext context, List<ScannedDocument> documents) {
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
            onPressed: () => context.read<ScannerBloc>().add(GeneratePdfEvent()),
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

  List<ScannedDocument> _getDocuments(ScannerState state) {
    if (state is ScannerInitial) {
      return state.documents;
    } else if (state is ScannerLoaded) {
      return state.documents;
    } else if (state is ScannerSuccess) {
      return state.documents;
    } else if (state is ScannerError) {
      return state.documents;
    } else if (state is PdfGenerated) {
      return state.documents;
    } else if (state is ScannerLoading) {
      return state.documents;
    } else if (state is ScannerCancelled) {
      return state.documents;
    }
    return [];
  }
}
