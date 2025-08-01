import 'package:equatable/equatable.dart';

abstract class ScannerEvent extends Equatable {
  const ScannerEvent();

  @override
  List<Object?> get props => [];
}

/// Event to trigger document scanning
class ScanDocumentEvent extends ScannerEvent {}

/// Event to scan document directly to PDF
class ScanDocumentToPdfEvent extends ScannerEvent {}

/// Event to handle scan cancellation
class ScanCancelledEvent extends ScannerEvent {}

class GeneratePdfEvent extends ScannerEvent {}

class ClearDocumentsEvent extends ScannerEvent {}

class RemoveDocumentEvent extends ScannerEvent {
  final int index;

  const RemoveDocumentEvent(this.index);

  @override
  List<Object> get props => [index];
}

class SharePdfEvent extends ScannerEvent {
  final String pdfPath;

  const SharePdfEvent(this.pdfPath);

  @override
  List<Object> get props => [pdfPath];
}
