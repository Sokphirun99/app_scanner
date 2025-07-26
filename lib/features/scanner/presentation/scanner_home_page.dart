import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../shared/models/scanned_document.dart';
import 'bloc/scanner_bloc.dart';
import 'bloc/scanner_event.dart';
import 'bloc/scanner_state.dart';
import 'widgets/document_card.dart';
import 'widgets/empty_state_widget.dart';
import 'widgets/loading_widget.dart';

class ScannerHomePage extends StatelessWidget {
  const ScannerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ScannerBloc, ScannerState>(
      listener: (context, state) {
        if (state is ScannerError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
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
              content: Text('PDF generated and saved successfully!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              action: SnackBarAction(
                label: 'Share',
                textColor: Colors.white,
                onPressed: () => context.read<ScannerBloc>().add(SharePdfEvent(state.pdfPath)),
              ),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: _buildAppBar(context, state),
          body: _buildBody(context, state),
          floatingActionButton: _buildFloatingActionButton(context, state),
        );
      },
    );
  }

  AppBar _buildAppBar(BuildContext context, ScannerState state) {
    final documents = _getDocuments(state);
    
    return AppBar(
      title: Text(
        'PDF Scanner',
        style: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      elevation: 0,
      actions: [
        if (documents.isNotEmpty)
          IconButton(
            icon: Icon(Icons.delete_sweep_outlined, size: 24.sp),
            onPressed: () => context.read<ScannerBloc>().add(ClearDocumentsEvent()),
            tooltip: 'Clear All',
          ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, ScannerState state) {
    if (state is ScannerLoading) {
      return const LoadingWidget();
    }

    final documents = _getDocuments(state);

    if (documents.isEmpty) {
      return const EmptyStateWidget();
    }

    return _buildDocumentsList(context, documents);
  }

  Widget _buildDocumentsList(BuildContext context, List<ScannedDocument> documents) {
    return Column(
      children: [
        _buildDocumentsHeader(context, documents),
        Expanded(
          child: _buildDocumentsGrid(context, documents),
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
              color: Colors.black87,
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => context.read<ScannerBloc>().add(GeneratePdfEvent()),
            icon: Icon(Icons.picture_as_pdf_outlined, size: 18.sp),
            label: Text('Generate PDF', style: TextStyle(fontSize: 14.sp)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
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

  Widget _buildDocumentsGrid(BuildContext context, List<ScannedDocument> documents) {
    return GridView.builder(
      padding: EdgeInsets.all(16.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 0.8,
      ),
      itemCount: documents.length,
      itemBuilder: (context, index) {
        return DocumentCard(
          document: documents[index],
          onPreview: () => _previewImage(context, documents[index].imagePath, documents, index),
          onDelete: () => context.read<ScannerBloc>().add(RemoveDocumentEvent(index)),
        );
      },
    );
  }

  Widget _buildFloatingActionButton(BuildContext context, ScannerState state) {
    return FloatingActionButton.extended(
      onPressed: () => context.read<ScannerBloc>().add(ScanDocumentEvent()),
      icon: Icon(Icons.document_scanner_outlined, size: 24.sp),
      label: Text('Scan Document', style: TextStyle(fontSize: 14.sp)),
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
    );
  }

  void _previewImage(BuildContext context, String imagePath, List<ScannedDocument> documents, int index) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: InteractiveViewer(
          child: Image.file(
            File(imagePath),
            fit: BoxFit.contain,
          ),
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
    }
    return [];
  }
}
